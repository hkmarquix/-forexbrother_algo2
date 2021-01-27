#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BasicEntry.mqh"
#include "BaseSignal.mqh"
#include "tradefunction.mqh"
#include "../RecoverAction/Martingale.mqh"
#include "../RecoverAction/ZoneCap.mqh"
#include "../Filter/TimeFilter.mqh"
#include "reportfunction.mqh"
#include "stoplossprotectionfunction.mqh"

class TradeHelper {
    private:
        datetime lastsync;

    public:
        BaseSignal *signalist[];
        int totalsignal;
        int magicNumber;
        string symbol;
        int trademode;
        int period;
        int curzone;
        int currecover;
        datetime stopcreateOrderuntil;
        int presettrademode;
        
        int maxorderno;
        int fixedordertype;
        int buyorder;
        int sellorder;

    TradeHelper() {
        lastsync = TimeCurrent();
        symbol = "EURUSD";
        period = PERIOD_M15;
        magicNumber = default_magicNumber;
        stopcreateOrderuntil = TimeCurrent();
        curzone = 100;
        currecover = 450;
        maxorderno = 1;
        fixedordertype = 2;
    }

// self modify
    virtual void initHelper() {
        totalsignal = 0;
        if (usebasicentry == 1)
            totalsignal++;
        if (fixedordertype == 2) {
         buyorder = 1;
         sellorder = 1;
        }
        else if (fixedordertype == OP_BUY)
         buyorder = 1;
        else if (fixedordertype == OP_SELL)
         sellorder = 1;
        
        
        int currentsignali = 0;
        initSignal(currentsignali);
    }

// self modify
    virtual void initSignal(int currentsignali) {
        ArrayResize(signalist, totalsignal , 0);
        if (usebasicentry == 1)
        {
            signalist[currentsignali] = new BasicEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali].symbol = symbol;
        }

    }

    ~TradeHelper() {
        int signalcount = ArraySize(signalist);
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            delete(bsignal);
        }
    }

    void refreshRobot() {
        if (checkAllOrderHasStopLossProtection()) {
            if (timeToCreateNewOrder(0) &&
                tf_countRecoveryCurPair(symbol, magicNumber) < maxrecoverypair &&
                tf_countOpenedCurPair(symbol, magicNumber) < maxopenedpair) {
                createFirstOrder();
            }

        } 
        
        checkHasOrderNextAction();
        
        if (lastsync < TimeCurrent())
        {
            rpt_syncclosedtrade();
            lastsync = TimeCurrent() + 10 * 60;
        }

    }

   /* // not using anymore
    bool checkHasOrder() {
        if (tf_countAllOrders(symbol, magicNumber) > 0)
            return true;
        return false;
    }
    */
    
    bool checkAllOrderHasStopLossProtection()
    {
      int torder = stoplossprotection_checkNoProtectOrdersWithMagicNumberRange(magicNumber, maxorderno);
      if (torder > 0)
         return false;
      return true;
    }

    bool timeToCreateNewOrder(int type) {
        if (stopcreateOrderuntil > TimeCurrent())
            return false;
        return true;
    }

// Self include this and modify
    virtual void signalRefresh(BaseSignal *bsignal)
    {
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.Refresh();
        }
    }
    
    int fetchMagicNumberForThisTrade()
    {
      for (int i = magicNumber; i < magicNumber + maxorderno; i++)
      {
         int countno = tf_countAllOrders(symbol, i);
         if (countno == 0)
            return i;
      }
      return -1;
    }

    void createFirstOrder() {
        int thismagicnumber = fetchMagicNumberForThisTrade();
        if (thismagicnumber == -1)
            return;
               
        int signalcount = ArraySize(signalist);
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            signalRefresh(bsignal);
            
            if (fixedordertype == OP_BUY && bsignal.signal != OP_BUY)
               return;
            if (fixedordertype == OP_SELL && bsignal.signal != OP_SELL)
               return;
               
            
            
            if (bsignal.signal != -1 && createOrderFilter(bsignal.signal, initlots))
            {
                double curprice = MarketInfo(symbol, MODE_BID);
                Print("[" + thismagicnumber + "] Create order now " + bsignal.signal + "/" + curprice + "/" + bsignal.stoploss + "/" + bsignal.takeprofit + "/" + bsignal.signalname);
                tf_createorder(symbol, bsignal.signal, initlots, "1", "", bsignal.stoploss, bsignal.takeprofit, bsignal.signalname, thismagicnumber);
                trademode = presettrademode;
                of_calTakeProfitOnAllOrders(symbol, thismagicnumber);
                return;
            }
        }
    }

// Self include this and modify
    virtual bool createOrderFilter(int signal, double lotsize)
    {

        return true;
    }

    void checkHasOrderNextAction() {
         int torders = 0;
        for (int imagicnumber = magicNumber; imagicnumber < magicNumber + maxorderno; imagicnumber++)
        {
            if (buyorder == 1) {
               checkHasOrderNextActionForOrderTypeMagicNumber(imagicnumber, OP_BUY);
            }
            if (sellorder == 1) {
               checkHasOrderNextActionForOrderTypeMagicNumber(imagicnumber, OP_SELL);
            }
        }
        
    }
    
    void checkHasOrderNextActionForOrderTypeMagicNumber(int _magicnumber, int _ordertype)
    {
        int torders = tf_countAllOrdersWithOrderType(symbol, _magicnumber, _ordertype);
        if (torders == 1)
        {
            checkSignalCloseAction(_magicnumber, _ordertype);
            checkRecoverAction(_magicnumber, _ordertype);
        }
        else if (torders > 1)
        {
            checkRecoverAction(_magicnumber, _ordertype);
        }
    
    }

    virtual void closeSignalRefresh(BaseSignal *bsignal)
    {
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        
    }

    void checkSignalCloseAction(int _magicnumber, int _ordertype)
    {
        string orderparam[];
        //tf_findFirstOrder(symbol, magicNumber);
        //Print("Order comment: " + OrderComment());
        tf_commentdecode(OrderComment(), orderparam);
        
        int signalcount = ArraySize(signalist);
        int resultsignal = -1;
        int recovermethod = -1;
        for (int i = 0; i < signalcount; i++)
        {
            BaseSignal *bsignal = (BaseSignal *)signalist[i];
            if (orderparam[1] == bsignal.signalname)
            {
                closeSignalRefresh(bsignal);
                resultsignal = bsignal.closesignal;
                recovermethod = bsignal.recovermethod;
                break;
            }
        }
        if (resultsignal == 1)
        {
            tf_closeAllOrdersWithOrderType(symbol, _magicnumber, _ordertype);
        }
        if (resultsignal == 2)
        {
            if (recovermethod == martingale)
            {
                Martingale *martin = new Martingale();
                martin.period = period;
                martin.symbol = symbol;
                martin.ordertype = _ordertype;
                martin.magicNumber = _magicnumber;
                martin.curzone = curzone;
                martin.simplyDoRecovery();
                delete(martin);
            }
        }
    }

// Self include this and modify
    virtual void checkRecoverAction(int _magicnumber, int _ordertype)
    {
        if (trademode == martingale)
        {
            Martingale *martin = new Martingale();
            martin.period = period;
            martin.symbol = symbol;
            martin.ordertype = _ordertype;
            martin.magicNumber = _magicnumber;
            martin.curzone = curzone;
            martin.takeProfit();
            martin.doRecovery();
            
            delete(martin);
        } else if (trademode == zonecap)
        {
            Zonecap *zc = new Zonecap();
            zc.period = period;
            zc.symbol = symbol;
            zc.magicNumber = _magicnumber;
            zc.curzone = curzone;
            zc.takeProfit();
            zc.doRecovery();
            
            delete(zc);
        } else if (trademode == simplestoploss)
        {

        } else if (trademode == signalclosesignal) {

        }
        else if (trademode == selfsignal)
        {

        }
    }




};
