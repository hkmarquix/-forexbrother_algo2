#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseRecovery.mqh"

class Martingale : public BaseRecovery {
    protected:
      int strict_level;
      double price_distance;
      bool sellAfterBandClosed;
      bool buyAfterBandClosed;
      datetime lastchecking;
      
      

    public:
      int ordertype;
      double lastbuystoploss;
      double lastsellstoploss;

    Martingale() {

        initHelper();
    }

    void initHelper() {
    lastbuystoploss= 0;
    lastsellstoploss = 0;
    lastchecking = TimeCurrent();
    ordertype = -1;
    sellAfterBandClosed = false;
    buyAfterBandClosed = false;
         strict_level = 1;
        recoveryname = "Martin";
        recoveryid = martingale;
    }

    ~Martingale() {
        
    }

    int simplyDoRecovery()
    {
        double topenorders = tf_countAllOrdersWithOrderType(symbol, magicNumber, ordertype);
        if (!of_selectlastorderWithOrderType(symbol, magicNumber, ordertype))
            return -1;

        string param[];
        tf_commentdecode(OrderComment(), param);
        int orderi = StrToInteger(param[2]);

        datetime lastopentime = OrderOpenTime();
        
        if (TimeCurrent() - lastopentime < 1 * 60)//PeriodSeconds(period) * 3)
            return -1;

        int neworderi = StrToInteger(param[2]) + 1;
        double newlots = wilsonNewMartingaleLotsizeCalculation(topenorders, OrderLots());

        tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, param[1], magicNumber);
        return 1;

    }

    bool timeProtection(int nooforder, datetime lastopentime)
    {
        if (nooforder == 1 && TimeCurrent() - lastopentime < martingale_startrecover * 60)
            return true;
        if (nooforder > 1 && TimeCurrent() - lastopentime < martingale_lastordermin * 60)
            return true;
        return false;
    }

    int doRecovery() {
        double topenorders = tf_countAllOrdersWithOrderType(symbol, magicNumber, ordertype);
        if (!of_selectlastorderWithOrderType(symbol, magicNumber, ordertype))
        {
            return -1;
        }
        
        checkLastOrderForProfitProtection();
        
        if (OrderProfit() > 0) {
            return -1;
        }

        string param[];
        tf_commentdecode(OrderComment(), param);
        int orderi = StrToInteger(param[2]);
        datetime lastopentime = OrderOpenTime();
        
        if (timeProtection(orderi, lastopentime))
        {
            return -1;
        }
        
        
        //Print("Last open time: " + lastopentime + " C: " + OrderComment());
        double lastprice = OrderOpenPrice();

        

        double cprice = 0;
        if (OrderType() == OP_BUY) {
            cprice = MarketInfo(symbol, MODE_ASK);
        }
        else
        {
            cprice = MarketInfo(symbol, MODE_BID);
        }

        double diff = MathAbs(cprice - lastprice) * of_getcurrencrymultipier(symbol);

        if (diff <= curzone)
         return -1;
        //writelog_writeline("Checking recovery criteria... " + diff);
        //if (checkGiveupMartingaleAndChangeToZoneCap(OrderType(), cprice))
        //    return 2;
        if (needRecoveryAction(cprice))
        {
            int neworderi = StrToInteger(param[2]) + 1;
            double newlots = wilsonNewMartingaleLotsizeCalculation(topenorders, OrderLots());
            writelog_writeline("Do martingale now..." + neworderi);
            tf_createorder(symbol, OrderType(), newlots, IntegerToString(neworderi), "", 0, 0, recoveryname, magicNumber);
            of_calTakeProfitOnAllOrdersWithOrderType(symbol, magicNumber, ordertype);
            return 1;
        }
        
        

        return -1;
    }

    bool checkGiveupMartingaleAndChangeToZoneCap(int actiontype, double cprice)
    {
       if (!of_selectfirstorder(symbol, magicNumber))
       {
          return false;
       }
       double diff = MathAbs(cprice - OrderOpenPrice()) * of_getcurrencrymultipier(symbol);
       if (diff <= currecover)
          return false;

      int flipactiontype = OP_BUY;
      if (actiontype == OP_BUY)
      flipactiontype = OP_SELL;
      // check macd H1 cross over
      //int checksignal = macdjustcross(flipactiontype, symbol, PERIOD_H1, 4, 0, true, 0);
      //if (checksignal == flipactiontype)
      //  return true;
        
      return false;
    }
    

    void takeProfit()
    {
        // when martingale_targetProfitTotalPips > 0, tp will cut the order for you
        /*if (martingale_targetProfitTotalPips > 0) {
            takeProfitWithTakeProfitPips();
        }*/
        if (martingale_targetProfitForEachOrder > 0)
        {
            takeProfitForEachOrder();
        }
        if (martingale_targetProfitForEachLot > 0)
        {
            takeProfitForEachLot();
        }
    }

    int takeProfitForEachLot()
    {
        double tlots = tf_countAllLotsWithOrderType(symbol, magicNumber, ordertype) * 100;
        double targetprofit = tlots * martingale_targetProfitForEachLot;
        double totalprofit = tf_orderTotalProfit(symbol, magicNumber);
        if (totalprofit >= targetprofit)
        {
            tf_closeAllOrdersWithOrderType(symbol, magicNumber, ordertype);
            return 1;
        }
        return -1;
    }

    int takeProfitForEachOrder()
    {
        int torders = tf_countAllOrdersWithOrderType(symbol, magicNumber, ordertype);
        double targetprofit = torders * martingale_targetProfitForEachOrder;
        double totalprofit = tf_orderTotalProfit(symbol, magicNumber);
        if (totalprofit >= targetprofit)
        {
            tf_closeAllOrdersWithOrderType(symbol, magicNumber, ordertype);
            return 1;
        }
        return -1;
    }

    int takeProfitWithTakeProfitPips()
    {
        if (!of_selectlastorderWithOrderType(symbol, magicNumber, ordertype))
            return -1;
        //martingale_targetProfitTotalPips
        double averageopenprice = tf_averageOpenPriceWithOrderType(symbol, magicNumber, ordertype);
        if (averageopenprice == 0)
        {
            Print("Invalid average open price");
            return -1;
        }
        double closeprice = 0;
        double diff = 0;
        if (OrderType() == OP_BUY)
        {
            closeprice = MarketInfo(symbol, MODE_BID);
            diff = closeprice - averageopenprice;
        }
        else if (OrderType() == OP_SELL)
        {
            closeprice = MarketInfo(symbol, MODE_ASK);
            diff = averageopenprice - closeprice;
        }
        if (closeprice == 0)
            return -1;
        //Print("Diff: " + diff * tf_getCurrencryMultipier(symbol) + "  " + martingale_targetProfitTotalPips * 10);

        if (diff * tf_getCurrencryMultipier(symbol) > martingale_targetProfitTotalPips * 10)
        {
            tf_closeAllOrdersWithOrderType(symbol, magicNumber, ordertype);
            return 1;
        }
        
        return -1;
    }

    int determineTimeFrameToUseForRecovery(double cprice, int actiontype)
    {
        int torder = tf_countAllOrdersWithOrderType(symbol, magicNumber, actiontype);
        of_selectfirstorder(symbol, magicNumber);
        double openprice = OrderOpenPrice();
        // M1 cross over , around $2 // distance $5
        // M5 cross over, around $6 // distance $10
        // M15 cross over, around $10 // distance $20
        double distance =  MathAbs(cprice - openprice) * tf_getCurrencryMultipier(symbol);
         price_distance = distance;
        if (distance < 5000 && torder <= 5)
        {
            strict_level = 1;
            if (distance > 500)
               strict_level++;
            return PERIOD_M1;
        }
        if (distance < 15000 && torder <= 15) {
            strict_level = 1;
            if (distance > 1500)
               strict_level++;
            return PERIOD_M5;
        }
        if (distance < 50000 && torder <= 99) {
            strict_level = 2;
            return PERIOD_M15;
        }
        if (distance < 30000) {
            strict_level = 2;
            return PERIOD_M30;
        }
        else
            return PERIOD_H1;
    }

    virtual bool needRecoveryAction(double cprice)
    {
    
        return true;
        
    }

    /*

        0.01 0.02 0.04 0.08 -> 0.16
        0.01 0.04 0.08 -> 0.8
        0.01 0.02 0.08 -> 0.8
        0.01 0.02 0.04 -> 0.8
        0.01 0.08 -> 0.08
        0.01 0.04 -> 0.04

    */
    double wilsonNewMartingaleLotsizeCalculation(int torder, double lastOpenLots)
    {
        double ntlots = initlotstep;

        Print("wilsonNewMartingaleLotsizeCalculation " + martingaletype);
        if (martingaletype == 1)
        {
            ntlots =  initlots + initlotstep + torder * lotincrease_step;
        }
        else if (martingaletype == 2)
        {
            for (int i = 0; i < torder; i++)
            {
                ntlots = ntlots * martingalefactor;
                Print("New lots: " + ntlots);
            }
        }



        if (!boundMartingaleLotsizenotsmallerthanLastOrder && ntlots < lastOpenLots)
        {
            ntlots = lastOpenLots;
        }

        return ntlots;
    }
    
    bool checkLastOrderForProfitProtection()
    {
         if (TimeCurrent() - lastchecking <= 3)
            return false;
         lastchecking = TimeCurrent();
      
         double closeprice;
         double diff;
         
         double triggervalue = 0;
         double addonvalue = 0;
         
         int order_count = tf_countAllOrdersWithOrderType(symbol, magicNumber, OrderType());
         if (order_count == 1)
         {
            triggervalue = single_profitprotectiontrigger;
            addonvalue = single_profitprotectionaddon;
         }
         else
         {
            triggervalue = martingale_profitprotectiontrigger;
            addonvalue = martingale_profitprotectionaddon;
         }
         
         
         double averageopenprice = tf_averageOpenPriceWithOrderType(symbol, magicNumber, OrderType());
         
         if (!of_selectlastorderWithOrderType(symbol, magicNumber, ordertype))
            return false;
            
            
         if (OrderType() == OP_BUY)
        {
            closeprice = MarketInfo(symbol, MODE_BID);
            diff = closeprice - averageopenprice;
        }
        else if (OrderType() == OP_SELL)
        {
            closeprice = MarketInfo(symbol, MODE_ASK);
            diff = averageopenprice - closeprice;

        }
        
        
        if (diff *  tf_getCurrencryMultipier(symbol) > triggervalue * 10)
        {
        }
        else
        {
            return false;
        }
        
        
        
        double newprice = 0;
        if (OrderType() == OP_BUY) {
            newprice = closeprice - addonvalue * 10 /  tf_getCurrencryMultipier(symbol);
            //if (newprice <= lastbuystoploss && lastbuystoploss > 0)
            if (newprice <= OrderStopLoss() && OrderStopLoss() > 0)
               return false;
            lastbuystoploss= newprice;
        }
        else {
            newprice = closeprice + addonvalue * 10 /  tf_getCurrencryMultipier(symbol);
            //if (newprice >= lastsellstoploss && lastsellstoploss > 0)
            if (newprice >= OrderStopLoss() && OrderStopLoss() > 0)
               return false;
            lastsellstoploss = newprice;
        }
        
               
        
        if (diff *  tf_getCurrencryMultipier(symbol) > triggervalue * 10)
        {
            // set order protection
            //writelog_writeline(OrderTicket() + " ::: " + OrderType() + " Open Price: " + OrderOpenPrice() + " new price: " + newprice + " Set stop loss  current: " + OrderStopLoss());
            //Print("Update now");
            //OrderModify(OrderTicket(), OrderOpenPrice(), newprice, 0, 0, Green);
            tf_setTakeProfitStopLoss(symbol, OrderType(), magicNumber, newprice, 0);
            //simplyDoRecovery();
            return true;
        }
        return false;
    }
    
    

};