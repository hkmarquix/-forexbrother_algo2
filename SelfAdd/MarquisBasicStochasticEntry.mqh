#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisBasicStochasticEntry : public BaseSignal {
    private:
        int longperiod;
           
    public:
        int takeprofit_pips;

    MarquisBasicStochasticEntry() {
        takeprofit_pips = 80;

        initHelper();
    }

    void initHelper() {
        signalname = "MBSE";
        signalid = marquisbasicentry;
        longperiod = PERIOD_M15;
    }

    ~MarquisBasicStochasticEntry() {
        
    }

    void Refresh()
    {
        int sec = TimeSeconds(TimeCurrent());
        if (sec % 2 == 0)
            signal = OP_BUY;
        else
        {
            signal = OP_SELL;
        }
        

    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
    }

};