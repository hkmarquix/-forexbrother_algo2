#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisBasicStochasticEntry : public BaseSignal {
    private:
           
    public:
        int takeprofit_pips;

    MarquisBasicStochasticEntry() {
        takeprofit_pips = 80;

        initHelper();
    }

    void initHelper() {
        signalname = "MBSE";
        signalid = marquisbasicentry;
    }

    ~MarquisBasicStochasticEntry() {
        
    }

    void Refresh()
    {
        signal = -1;
        period = PERIOD_M1;
        
        double sk0_5 = iStochastic(symbol, PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);

        double sk0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double sd0 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double sk1 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        //double sd1 = iStochastic(symbol, period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        double macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        double macdm1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds1= iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

         
        double ima0 = iMA(symbol, PERIOD_M5, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ima1 = iMA(symbol, PERIOD_M5, 200, 0, MODE_SMA, PRICE_CLOSE, 1);

        if (sk0 > sk1 && macdm - 0.7 > macds && macdm > macdm1 && macdm < 10
            && ima0 > ima1
            )
        {
            signal = OP_BUY;
        }
        if (sk0 < sk1 && macdm < macds - 0.7 && macdm < macdm1 && macdm > -10
            && ima0 < ima1
            )
        {
            signal = OP_SELL;
        }

        signalvaliduntil = TimeCurrent() + 10 * 60;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
    }

};