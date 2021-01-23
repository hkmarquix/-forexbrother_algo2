#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseRecovery.mqh"

class Martingale : public BaseRecovery {
    private:
      int strict_level;
      double price_distance;
      bool sellAfterBandClosed;
      bool buyAfterBandClosed;

    public:

    Martingale() {

        initHelper();
    }

    void initHelper() {
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
        double topenorders = tf_countAllOrders(symbol, magicNumber);
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;

        if (OrderProfit() > 0)
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
        double topenorders = tf_countAllOrders(symbol, magicNumber);
        if (!of_selectlastorder(symbol, magicNumber))
        {
            return -1;
        }

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
            of_calTakeProfitOnAllOrders(symbol, magicNumber);
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
        double tlots = tf_countAllLots(symbol, magicNumber) * 100;
        double targetprofit = tlots * martingale_targetProfitForEachLot;
        double totalprofit = tf_orderTotalProfit(symbol, magicNumber);
        if (totalprofit >= targetprofit)
        {
            tf_closeAllOrders(symbol, magicNumber);
            return 1;
        }
        return -1;
    }

    int takeProfitForEachOrder()
    {
        int torders = tf_countAllOrders(symbol, magicNumber);
        double targetprofit = torders * martingale_targetProfitForEachOrder;
        double totalprofit = tf_orderTotalProfit(symbol, magicNumber);
        if (totalprofit >= targetprofit)
        {
            tf_closeAllOrders(symbol, magicNumber);
            return 1;
        }
        return -1;
    }

    int takeProfitWithTakeProfitPips()
    {
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;
        //martingale_targetProfitTotalPips
        double averageopenprice = tf_averageOpenPrice(symbol, magicNumber);
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
            tf_closeAllOrders(symbol, magicNumber);
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

    bool needRecoveryAction(double cprice)
    {
        of_selectlastorder(symbol, magicNumber);
        int actiontype = OrderType(); 
        period = determineTimeFrameToUseForRecovery(cprice, actiontype);
        //period = PERIOD_M1;
        
        of_selectlastorder(symbol, magicNumber);
        if (TimeCurrent() - OrderOpenTime() < period * 2 * 60) {
            return false;
        }
            
            
        double macdm_s0 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds_s0 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
        double macdm_s1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds_s1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        double macdm_s2 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 2);
        double macds_s2 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 2);
        double macdm_s3 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 3);
        double macds_s3 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 3);
        
        
        
        double uval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
         double mval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
         double lval = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
               
         double uval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
         double mval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
         double lval1 = iBands(symbol, period, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
         
         double iatr = iATR(symbol, period, 14, 0) / 2;
         
         double vol0 = iVolume(symbol, period, 0);
         double vol1 = iVolume(symbol, period, 1);
        
         //writelog_writeline(StringFormat("macd: %f,%f macd1: %f,%f macd2: %f,%f", 
         //                              macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s2, macds_s2));
         //writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f ", 
         //                              uval, uval1, lval, lval1));   
         
         if (!(uval > uval1 && lval < lval1))
        {
            if (buyAfterBandClosed || sellAfterBandClosed){
               writelog_writeline("ban closed, can do now");
               buyAfterBandClosed = false;
               sellAfterBandClosed = false;
               return true;
           }
        }
         

        if (actiontype == OP_BUY)
        {
            int checksignal = macdjustcross(OP_SELL, symbol, period, 2, 0, false, 0);
            if (checksignal == OP_SELL) {
               //writelog_writeline("just cross (sell)... " + macdm_s0 + "," + macds_s0);
               return false;
            }
            if (macdjustcross(OP_BUY, symbol, period, 2, 0, true, 0) == OP_BUY && vol0 * 0.85 > vol1) {
               writelog_writeline("weak cross, buy now " + macdm_s0 + "," + macds_s0 + "   " + vol0 + "," + vol1);
               return true;
            }
        }
        if (actiontype == OP_SELL)
        {
            int checksignal = macdjustcross(OP_BUY, symbol, period, 2, 0, false, 0);
            if (checksignal == OP_BUY) {
               //writelog_writeline("just cross (buy)..." + macdm_s0 + "," + macds_s0);
               return false;
            }
            if (macdjustcross(OP_SELL, symbol, period, 2, 0, true, 0) == OP_SELL && vol0 * 0.85 > vol1) {
               writelog_writeline("weak cross, sell now" + macdm_s0 + "," + macds_s0 + "   " + vol0 + "," + vol1);
               return true;
            }
        }
        
        
        
         /*
         if (MathAbs(macdm_s0) > MathAbs(macdm_s1))
            return false;
         if (MathAbs(macdm_s0 - macds_s0) > MathAbs(macdm_s1 - macds_s1))
            return false;
        */
        if (actiontype == OP_BUY && cprice < lval - iatr && macdm_s0 < 0)
        {
            writelog_writeline("martin buy " + period);
            buyAfterBandClosed = true;
            //writelog_writeline(StringFormat("macd: %f,%f macd1: %f,%f macd2: %f,%f", 
            //                           macdm_s1, macds_s1, macdm_s2, macds_s2, macdm_s3, macds_s3));
            //writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f ", 
            //                           uval, uval1, lval, lval1));                           
            if (uval > uval1 && lval < lval1)
              {
                  //writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f ", 
                  //                           uval, uval1, lval, lval1));   
                  //writelog_writeline("band opened... wait");
                  return false;
              }
            return true;
        }
        
        if (actiontype == OP_SELL && cprice > uval + iatr && macdm_s0 > 0)
        {
            writelog_writeline("martin sell " + period);
            sellAfterBandClosed = true;
            //writelog_writeline(StringFormat("macd: %f,%f macd1: %f,%f macd2: %f,%f", 
            //                           macdm_s1, macds_s1, macdm_s2, macds_s2, macdm_s3, macds_s3));
            //writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f ", 
            //                           uval, uval1, lval, lval1));                           
            if (uval > uval1 && lval < lval1)
           {
               //writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f ", 
               //                           uval, uval1, lval, lval1));   
               //writelog_writeline("band opened... wait");
               return false;
           }
           return true;
        }

        
        return false;
         
        
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

};