#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../RecoverAction/Martingale.mqh"
#import "CandleRecoverDecision.ex4"
int candleRecoverDecision(int actiontype, string symbol, int period);
#import

class MMartingale : public Martingale {
    private:
      bool sellAfterBandClosed;
      bool buyAfterBandClosed;
       
      double cacheatr1000[];
      datetime bandOpenWaitUntil;
      datetime lastchecking;
      
      double lastbuystoploss;
      double lastsellstoploss;
      
      string tradelog;
      
      datetime lastcheck;
    public:
      int signal;
    
    MMartingale() {

        initHelper();
    }
    
    ~MMartingale() {
      //delete(cpattern);
    }

   void initHelper()
   {
      lastcheck = TimeCurrent();
      //cpattern = new CandlePattern(symbol, PERIOD_M5);
      bandOpenWaitUntil= TimeCurrent();
      ArrayResize(cacheatr1000, 100, 0);
      for (int i = 0; i < ArraySize(cacheatr1000); i++)
      {
         cacheatr1000[i] = 0;
      }
      
      lastbuystoploss= 0;
      lastsellstoploss = 0;
      lastchecking = TimeCurrent();
      ordertype = -1;
      
      recoveryname = "MMartin";
      recoveryid = martingale;
      sellAfterBandClosed = false;
      buyAfterBandClosed = false;
      strict_level = 1;
      
      Print(recoveryname);
   }

   
   bool checkCutCondition()
    {
      return false;
    }

    bool needRecoveryAction(double cprice)
    {
      //Print("ABC: " + recoveryname);
      refreshSignal(ordertype);
      if (signal <= -1)
         return false;
      return true;
         
        
    }
    
    void refreshSignal(int actiontype)
    {
      signal = candleRecoverDecision(actiontype, symbol, period);

    }
};