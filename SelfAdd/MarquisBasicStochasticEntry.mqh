#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"

class MarquisBasicStochasticEntry : public BaseSignal {
    private:
        int longperiod;
        string tradeparam;
        bool buyAfterBandClosed;
        bool sellAfterBandClosed;
           
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
        
        buyAfterBandClosed = false;
        sellAfterBandClosed = false;
    }

    ~MarquisBasicStochasticEntry() {
        
    }
    
    bool macdslopepass(int _actiontype, int _period)
    {
      double macdm1 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
      double macdm2 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 3);
      double macds1 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
      double macds2 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 3);
      double slope = (macds1 - macds2) / 4;
      double slopem = (macdm1 - macdm2) / 4;
      tradeparam += _period + " slope: " + slope + "," + slopem + "; ";
      if ((slopem > 0.14/* || slope > 0.08*/) && _actiontype == OP_SELL)
         return false;
      if ((slopem < -0.14/* || slope < -0.08*/) && _actiontype == OP_BUY)
         return false;   
      if (MathAbs(macdm1) < 0.008 && MathAbs(macdm2) < 0.008 && slopem < 0.004)
         return false;
      if (slopem < 0.0015)
         return false;
      return true;
    }
    
    bool macdlowslope(int _actiontype, int _period)
    {
      double macdm1 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
      double macdm2 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 3);
      double macds1 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
      double macds2 = iMACD(symbol, _period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 3);
      double slope = (macds1 - macds2) / 4;
      double slopem = (macdm1 - macdm2) / 4;
      
      if (MathAbs(macdm1) < 0.008 && MathAbs(macdm2) < 0.008 && slopem < 0.004)
         return false;
      if (slopem < 0.0015)
         return false;
      return true;
    }

    void Refresh()
    {
       tradeparam= "";
       signal = -1;

       if (DayOfWeek() == 5 && TimeHour(TimeCurrent()) >= 21)
       {
           return;
       }
       if (TimeHour(TimeCurrent()) >= 22)
       {
         return;
       }
       if (TimeHour(TimeCurrent()) <= 9)
       {
         return;
       }
       
       //needRecoveryAction(0);
       int sec = TimeSeconds(TimeCurrent());
       if (sec % 2 == 0)
         signal = OP_BUY;
       else
         signal = OP_SELL;
         atrFilter();
       m15MacdFilter();
       emaFilter(period);
       emaFilter(PERIOD_M15);
       //emaFilter1();
        
       if (signal != -1)
       {
         resetOldParam();
           logtrade(tradeparam);
       }
       
       

        
    }
    
    void atrFilter()
    {
      double iatr = iATR(symbol, PERIOD_M5, 14, 0);
      if (iatr < 2)
         signal = -1;
    }

    void RefreshCloseSignal(int actiontype, double entryprice)
    {
        closesignal = -1;
    }
    
    
    void m15MacdFilter()
    {
      if (signal == -1)
         return;
         double macdm_0 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
        double macds_0 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
        double macdm_1 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double macds_1 = iMACD(symbol, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1); 
         if (macdm_0 > 0 && signal == OP_SELL)
            signal = -1;
         else if (macdm_0 <  0 && signal == OP_BUY)
            signal = -1;
        if ( signal == OP_BUY && macdm_0 > 0 && MathAbs(macdm_0 - macds_0) < MathAbs(macdm_1 - macds_1))
         signal = -1;
        if ( signal == OP_SELL && macdm_0 < 0 && MathAbs(macdm_0 - macds_0) < MathAbs(macdm_1 - macds_1))
         signal = -1;
    }
    
    void emaFilter(int _period)
    {
    if (signal == -1)
         return;
      double ema80_5 = iMA(symbol, _period, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
      double ema80_5_1 = iMA(symbol, _period, 80, 0, MODE_EMA, PRICE_CLOSE, 1);
      double ema80_5_2 = iMA(symbol, _period, 80, 0, MODE_EMA, PRICE_CLOSE, 2);
      double close0_5 = iClose(symbol, _period, 0);
      double close1_5 = iClose(symbol, _period, 1);
      double close2_5 = iClose(symbol, _period, 2);
      
      tradeparam += StringFormat("period: %d, ema80 %.5f,%.5f|%.5f,%.5f|%.5f,%.5f", _period, close0_5, ema80_5, close1_5, ema80_5_1, close2_5, ema80_5_2);
      if (signal == OP_SELL)
      {
         
         if (close0_5 > ema80_5 || close1_5 > ema80_5_1 || close2_5 > ema80_5_2)
         {
            signal = -1;
         }
      }
      if (signal == OP_BUY)
      {
         if (close0_5 < ema80_5 || close1_5 < ema80_5_1 || close2_5 < ema80_5_2)
         {
            signal = -1;
         }
      }
      
      
    }
    
    void emaFilter1()
    {
    if (signal == -1)
         return;
      double ema80_5 = iMA(symbol, period, 80, 0, MODE_EMA, PRICE_CLOSE, 0);
      if (signal == OP_SELL && MarketInfo(symbol, MODE_BID) < ema80_5 + 1 * 0.18)
      {
        // time to sell (martingale)
        signal = -1;
      }
      //else if (cprice < maend - iatr * 0.25 && (maend - mastart) > -1)
      else if (signal == OP_BUY && MarketInfo(symbol, MODE_ASK) > ema80_5 - 1 * 0.18)
      {
        // time to buy (martingale)
        signal = -1;
      }
    }
    
    
    bool macdvertex(int actiontype, double macdm_s0, double macds_s0, double macdm_s1, double macds_s1, double macdm_s2, double macds_s2, double factor, double factor2)
    {
      if (MathAbs(macdm_s0) < 0.5)
         return false;
    
      if (actiontype == OP_SELL && macdm_s0 > 0 && macdm_s1 > 0 && macdm_s2 > 0 &&
         macdm_s0 < macdm_s1 * factor && macdm_s1* factor2 > macdm_s2 && macdm_s0 > macds_s0 && macdm_s1 > macds_s1  && macdm_s2 > macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_SELL && macdm_s0 < 0 && macdm_s1 < 0 && macdm_s2 < 0 &&
         macdm_s0 * factor < macdm_s1 && macdm_s1 > macdm_s2 * factor2 && macdm_s0 > macds_s0 && macdm_s1 > macds_s1  && macdm_s2 > macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_BUY && macdm_s0 < 0 && macdm_s1 < 0 && macdm_s2 < 0 &&
         macdm_s0 > macdm_s1 * factor && macdm_s1 * factor2 < macdm_s2 && macdm_s0 < macds_s0 && macdm_s1 < macds_s1  && macdm_s2 < macds_s2)
         {
            return true;
         } 
      if (actiontype == OP_BUY && macdm_s0 > 0 && macdm_s1 > 0 && macdm_s2 > 0 &&
         macdm_s0 * factor > macdm_s1 && macdm_s1 < macdm_s2 * factor2 && macdm_s0 < macds_s0 && macdm_s1 < macds_s1  && macdm_s2 < macds_s2)
         {
            return true;
         } 
      return false;
    }
    
    void resetOldParam()
    {
      buyAfterBandClosed = false;
      sellAfterBandClosed = false;
    }
    
    bool needRecoveryAction(double cprice)
    {

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
        
         //logtrade(StringFormat("macd: %f,%f macd1: %f,%f macd2: %f,%f", 
         //                              macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s2, macds_s2));
         //logtrade(StringFormat("uval: %f,%f lval: %f,%f ", 
         //                              uval, uval1, lval, lval1));   
         
         if (!(uval > uval1 && lval < lval1))
        {
            if (buyAfterBandClosed){
               logtrade("ban closed, can buy now");
               buyAfterBandClosed = false;
               signal = OP_BUY;
               return true;
           }
           if (sellAfterBandClosed) {
               logtrade("ban closed, can sell now");
               sellAfterBandClosed = false;
               signal = OP_SELL;
               return true;
           }
        }
         /*
         if (macdvertex(OP_BUY, macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s2, macds_s2))
         {
            writelog_writeline("B vertex " + macdm_s0 + "," + macds_s0 + ":" + macdm_s1 + "," + macds_s1 + ":" + macdm_s2 + "," + macds_s2);
               signal = OP_BUY;
               return true;
         }
         
         if (macdvertex(OP_SELL, macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s2, macds_s2))
         {
            writelog_writeline("S vertex " + macdm_s0 + "," + macds_s0 + ":" + macdm_s1 + "," + macds_s1 + ":" + macdm_s2 + "," + macds_s2);
               signal = OP_SELL;
               return true;
         }
*/
         if (macdvertex(OP_BUY, macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s3, macds_s3, 0.85, 1) && macdm_s0 < 0)
         {
            logtrade(StringFormat("macd vertext, [BUY], %.5f,%.5f | %.5f,%.5f | %.5f,%.5f", macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s3, macds_s3));
            signal = OP_BUY;
            return true;
         }
         if (macdvertex(OP_SELL, macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s3, macds_s3, 0.85, 1) && macdm_s0 > 0)
         {
            logtrade(StringFormat("macd vertext, [SELL], %.5f,%.5f | %.5f,%.5f | %.5f,%.5f", macdm_s0, macds_s0, macdm_s1, macds_s1, macdm_s3, macds_s3));
            signal = OP_SELL;
            return true;
         }

         if (macdjustcross(OP_BUY, symbol, period, 2, 0, true, 0) == OP_BUY 
             && vol0 * 0.85 > vol1
             && MathAbs(macdm_s0 - macdm_s2) / 3 > 0.3) {
            logtrade("weak cross, buy now " + macdm_s0 + "," + macds_s0 + "   " + vol0 + "," + vol1);
            signal = OP_BUY;
            return true;
         }
         if (macdjustcross(OP_SELL, symbol, period, 2, 0, true, 0) == OP_SELL 
               && vol0 * 0.85 > vol1
               && MathAbs(macdm_s0 - macdm_s2) / 3 > 0.3) {
            logtrade("weak cross, sell now" + macdm_s0 + "," + macds_s0 + "   " + vol0 + "," + vol1);
            signal = OP_SELL;
            return true;
         }
     
     
        
         /*
         if (MathAbs(macdm_s0) > MathAbs(macdm_s1))
            return false;
         if (MathAbs(macdm_s0 - macds_s0) > MathAbs(macdm_s1 - macds_s1))
            return false;
        */
        /*if (MarketInfo(symbol, MODE_BID) < lval - iatr && macdm_s0 < 0)
        {
            
            if (uval > uval1 && lval < lval1 && buyAfterBandClosed == false)
              {
                  //buyAfterBandClosed = true;
                  //logtrade(StringFormat("uval: %f,%f lval: %f,%f ", 
                  //                           uval, uval1, lval, lval1));   
                  //logtrade("band opened... wait");
                  return false;
              }
              
            logtrade(StringFormat("BAND BUY macd: %f,%f macd1: %f,%f macd2: %f,%f", 
                                       macdm_s1, macds_s1, macdm_s2, macds_s2, macdm_s3, macds_s3));
            logtrade(StringFormat("uval: %f,%f lval: %f,%f ", 
                                       uval, uval1, lval, lval1));                           
            
            signal = OP_BUY;
            return true;
        }
        
        if (MarketInfo(symbol, MODE_ASK) > uval + iatr && macdm_s0 > 0)
        {
                                    
            if (uval > uval1 && lval < lval1 && sellAfterBandClosed == false)
           {
               //sellAfterBandClosed = true;
               //logtrade(StringFormat("uval: %f,%f lval: %f,%f ", 
               //                           uval, uval1, lval, lval1));   
               //logtrade("band opened... wait");
               return false;
           }
           
           logtrade(StringFormat("BAND SELL macd: %f,%f macd1: %f,%f macd2: %f,%f", 
                                       macdm_s1, macds_s1, macdm_s2, macds_s2, macdm_s3, macds_s3));
            logtrade(StringFormat("uval: %f,%f lval: %f,%f ", 
            uval, uval1, lval, lval1));                           
               
           
           signal  = OP_SELL;
           return true;
        }*/

        
        return false;
         
        
    }
    
    void logtrade(string msg)
    {
      return;
      writelog_writeline(msg);
    }

};