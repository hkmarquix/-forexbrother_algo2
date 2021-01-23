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
        signal = -1;
        period = PERIOD_M1;
        
        //if (TimeHour(TimeCurrent()) < 11)
        // return;
        //if (TimeHour(TimeCurrent()) > 11)
        // return;

        double sk0 = iStochastic(symbol, PERIOD_M1, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double sd0 = iStochastic(symbol, PERIOD_M1, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double sk1 = iStochastic(symbol, PERIOD_M1, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        double sd1 = iStochastic(symbol, PERIOD_M1, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);

        double maend = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
        double mastart = iMA(symbol, period, 5, 0, MODE_EMA, PRICE_CLOSE, 1);

        /*double sk0_15 = iStochastic(symbol, PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double sd0_15 = iStochastic(symbol, PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
        double sk1_15 = iStochastic(symbol, PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        double sd1_15 = iStochastic(symbol, PERIOD_M15, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);*/


         double m15_sk0 = iStochastic(symbol, longperiod, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double macdm = iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds = iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

        double macdm1 = iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds1= iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

         double macdm2 = iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 2);
        double macds2= iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 2);
        
        double macdm3 = iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 3);
        double macds3= iMACD(symbol, longperiod, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 3);
        
        double sk50 = iStochastic(symbol, PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
        double sk51 = iStochastic(symbol, PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
        double sk52 = iStochastic(symbol, PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 2);
        double sk53 = iStochastic(symbol, PERIOD_M5, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 3);
        
        double macdm_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macdm1_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macdm2_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 2);
        double macds_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
        double macds1_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        double macds2_15 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 2);
                
        double uval = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
         double mval = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
         double lval = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
               
         double uval1 = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
         double mval1 = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
         double lval1 = iBands(symbol, PERIOD_M15, 15, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);

         double macdm5 = iMACD(symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds5 = iMACD(symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
        
        double price = MarketInfo(symbol, MODE_BID);
        
        string trigger = "";
        
        if (sk0 > sk1 && sk0 < 40
            && (MarketInfo(symbol, MODE_ASK) < maend && (maend - mastart) > -1)
            
            )
        {
            trigger = "nb";
            signal = OP_BUY;
        }
        if (sk0 < sk1 && sk0 > 60
            && (MarketInfo(symbol, MODE_BID) > maend && (maend - mastart) > -1)
            )
        {
            trigger = "ns";
            signal = OP_SELL;
        }
        
        if (uval - 0.15 > uval1 && lval < lval1 - 0.15)
        {
            if (price < mval && price > lval
               && macdm < macdm1
               )
               {
                  trigger = "ss";
                  signal = OP_SELL;
               }
            else if (price < mval && signal == OP_BUY)
            {
               signal = -1;
            }
            else if (price > mval && signal == OP_SELL)
            {
               signal = -1;
            }
        }
        
        
        if (signal != -1)
        {
         writelog_writeline(StringFormat("%s, stoc: %f,%f macd: %f,%f macd1: %f,%f sk5: %f,%f,%f,%f, price: %f", 
                                          trigger, sk0, sk1, macdm, macds, macdm1, macds1, sk50, sk51, sk52, sk53, price));
         writelog_writeline(StringFormat("uval: %f,%f lval: %f,%f", 
                                          uval, uval1, lval, lval1));                                 
        }

    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
    }

};