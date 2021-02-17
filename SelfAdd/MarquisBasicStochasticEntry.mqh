#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include <hash.mqh>
#include <json.mqh>

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"
#import "CandleRecoverDecision.ex4"
int candleEntryMethod(string symbol, int period);
#import

class MarquisBasicStochasticEntry : public BaseSignal {
    private:
        int longperiod;
        
        bool buyAfterBandClosed;
        bool sellAfterBandClosed;
        
        datetime lastcheck;
           
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
        tradeparam= "";
        lastcheck = TimeCurrent();
        buyAfterBandClosed = false;
        sellAfterBandClosed = false;
    }

    ~MarquisBasicStochasticEntry() {
        
    }
    
    void Refresh()
    {
      tradeparam= "";
      signal = -1;
      
      signal = candleEntryMethod(symbol, period);
    
    
    }
    


    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
    }
    
    
    void resetOldParam()
    {
      buyAfterBandClosed = false;
      sellAfterBandClosed = false;
    }
    
    bool needRecoveryAction(double cprice)
    {

        
        return false;
         
        
    }
    
    void logtrade(string msg)
    {
      return;
      writelog_writeline(msg);
    }

};