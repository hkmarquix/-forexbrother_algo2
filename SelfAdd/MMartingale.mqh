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
      
      datetime lastcheckCandlePattern;
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
      lastcheckCandlePattern = TimeCurrent();
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

    int determineTimeFrameToUseForRecovery(double cprice, int actiontype, int torder)
    {
        return PERIOD_M15;//5;
        of_selectfirstorder(symbol, magicNumber);
        double openprice = OrderOpenPrice();
        // M1 cross over , around $2 // distance $5
        // M5 cross over, around $6 // distance $10
        // M15 cross over, around $10 // distance $20
        double distance =  MathAbs(cprice - openprice) * tf_getCurrencryMultipier(symbol);
         price_distance = distance;
        if (distance < 250 && torder <= 2)
        {
            strict_level = 1;
            if (distance > 500)
               strict_level++;
            return PERIOD_M1;
        }
        if (distance < 8000 && torder <= 5) {
            strict_level = 1;
            if (distance > 1500)
               strict_level++;
            return PERIOD_M5;
        }
        return PERIOD_M5;
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
    
    bool macdBigRiseProtection(int actiontype, double macdm_s0, double macds_s0, double macdm_s1, double macds_s1)
    {
      if (actiontype == OP_SELL)
      {
         if ((macdm_s0 - macds_s0) > (macdm_s1 - macds_s1)
                || 
                macdm_s0 - 1.4 > macds_s0)
         {
            return true;
         }
      }
      if (actiontype == OP_BUY)
      {
         if ((macds_s0 - macds_s0) > (macds_s1 - macdm_s1)
         ||
               macdm_s0 + 1.4 < macds_s0)
         {
            return true;
         }
      }
      return false;
    }
    
    bool macdvertex(int actiontype, double macdm_s0, double macds_s0, double macdm_s1, double macds_s1, double macdm_s2, double macds_s2, double factor)
    {
      if (actiontype == OP_SELL && macdm_s0 > 0 && macdm_s1 > 0 && macdm_s2 > 0 &&
         macdm_s0 < macdm_s1 * factor && macdm_s1* factor > macdm_s2 && macdm_s0 > macds_s0 && macdm_s1 > macds_s1  && macdm_s2 > macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_SELL && macdm_s0 < 0 && macdm_s1 < 0 && macdm_s2 < 0 &&
         macdm_s0 * factor < macdm_s1 && macdm_s1 > macdm_s2 * factor && macdm_s0 > macds_s0 && macdm_s1 > macds_s1  && macdm_s2 > macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_BUY && macdm_s0 < 0 && macdm_s1 < 0 && macdm_s2 < 0 &&
         macdm_s0 > macdm_s1 * factor && macdm_s1 * factor < macdm_s2 && macdm_s0 < macds_s0 && macdm_s1 < macds_s1  && macdm_s2 < macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_BUY && macdm_s0 > 0 && macdm_s1 > 0 && macdm_s2 > 0 &&
         macdm_s0 * factor > macdm_s1 && macdm_s1 < macdm_s2 * factor && macdm_s0 < macds_s0 && macdm_s1 < macds_s1  && macdm_s2 < macds_s2)
         {
            return true;
         } 
      return false;
    }

   void refreshAtr10000(int _period)
   {
      //Print(_period + "   " + ArraySize(cacheatr1000));
      if (cacheatr1000[_period] == 0)
         cacheatr1000[_period] = iATR(symbol, _period, 1000, 0);
      else if (TimeMinute(TimeCurrent()) == 0 && TimeSeconds(TimeCurrent()) == 0)
      {
         cacheatr1000[_period] = iATR(symbol, _period, 1000, 0);
      }
   }
   
   bool atrProtection(int _period)
   {
   double iatr = iATR(symbol, period, 3, 0) / 2;
      if (_period == PERIOD_M5 && iatr < 2)
         return true;
      if (_period == PERIOD_M15 && iatr < 4)
         return true;
      return false;
   }
   
   bool macdnonstopInOneSideMorethanXWindowsAndIncreasing(int period, int window, int actiontype)
   {
      int side = -1;
      double startpos = -1;
      double endpos = -1;
      
      for (int i = window; i >= 0; i--)
      {
         double macdm = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i);
         if (startpos == -1 && macdm > 0) {
            side = OP_BUY; startpos = macdm; }
         if (startpos == -1 && macdm < 0) { 
            side = OP_SELL; startpos = macdm; }
         if  (macdm < 0 && side == OP_BUY)
            return false;
         if (macdm > 0 && side == OP_SELL)
            return false;
         endpos = macdm;
      }
      
      if (endpos > startpos && side == OP_BUY && actiontype == OP_SELL)
         return true;
   
      if (endpos > startpos && side == OP_SELL && actiontype == OP_BUY)
         return true;
         
      return false;
   }
   
   bool checkCutCondition()
    {
      of_selectlastorder(symbol, magicNumber);
        int actiontype = OrderType(); 
      if (macdnonstopInOneSideMorethanXWindowsAndIncreasing(PERIOD_M5, 24, actiontype)) {
         tf_closeAllOrders(symbol, magicNumber);
         return false;
      }
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