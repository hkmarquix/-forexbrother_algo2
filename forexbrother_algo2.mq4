//+------------------------------------------------------------------+
//|                                               synceatoserver.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "config.mqh"
#include "TradeInclude\writelog.mqh"
#include "TradeInclude\tradefunction.mqh"
#include "TradeInclude\orderfunction.mqh"
#include "TradeInclude\macdcrossover.mqh"
#include "SelfAdd\MTradeHelper.mqh"

enum signalidlist {
    basicentryid=1012,
    mbasic = 4000,
    marquisbasicentry = 3001
};
enum trademodelist {
    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4,

    selfsignal = 99
};
enum filterlist {
  TIMEFILTER = 1,
  ADXFILTER = 2,
  CTIMEFILTER = 3
};

int default_magicNumber = 18292;
double closeprice = 0.0;
bool keepsilence = false;

int processOrders = 0;

MTradeHelper *tHelper;
MTradeHelper *curPairs[];

string curlist_arr[];
int curperiod_arr[];
int curzone_arr[];
int currecover_arr[];
int curtrademode_arr[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    initCurPair();

   if (IsTesting())
    keepsilence = true;
//---
   return(INIT_SUCCEEDED);
  }
  
  void initCurPair()
  {
      convertCurzone();
      convertCurrecover();
      convertCurtrademode();
      convertCurperiod();

      StringSplit(curlist, StringGetCharacter(",", 0), curlist_arr);
      ArrayResize(curPairs, ArraySize(curlist_arr), 0);
      if (IsTesting())
        ArrayResize(curPairs, 1, 0);
      for (int i = 0; i < ArraySize(curlist_arr); i++)
      {
         string cur = curlist_arr[i];
         tHelper = new MTradeHelper();
         tHelper.magicNumber = default_magicNumber;
         tHelper.symbol = cur;
         tHelper.period = curperiod_arr[i];
         tHelper.curzone = curzone_arr[i];
         tHelper.currecover = currecover_arr[i];
         tHelper.trademode = curtrademode_arr[i];
         tHelper.presettrademode = tHelper.trademode;
         tHelper.initHelper();
         curPairs[i] = tHelper;

         Print("TradeHelper init: " + cur + "/" + curperiod_arr[i]);

         if (IsTesting())
           break;
      }
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    for (int i = 0; i < ArraySize(curPairs); i++)
    {
      MTradeHelper *th = (MTradeHelper *)curPairs[i];
      delete(th);
    }
   ArrayFree(curPairs);
   ObjectsDeleteAll();
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    if (processOrders == 1)
      return;
    processOrders = 1;
    for (int i = 0; i < ArraySize(curPairs); i++)
      {
         MTradeHelper *tHelper = curPairs[i];
         tHelper.refreshRobot();
         
      }
    
    processOrders = 0;

  }

  void convertCurzone()
  {
    string t_arr[];
    StringSplit(curzone, StringGetCharacter(",", 0), t_arr);
    ArrayResize(curzone_arr, ArraySize(t_arr), 0);
    for (int i = 0; i < ArraySize(t_arr); i++)
    {
      curzone_arr[i] = StringToInteger(t_arr[i]);
    }
  }

  void convertCurrecover()
  {
    string t_arr[];
    StringSplit(curzonerecover, StringGetCharacter(",", 0), t_arr);
    ArrayResize(currecover_arr, ArraySize(t_arr), 0);
    for (int i = 0; i < ArraySize(t_arr); i++)
    {
      currecover_arr[i] = StringToInteger(t_arr[i]);
    }
  }

  void convertCurtrademode()
  {
    string t_arr[];
    StringSplit(curtrademode, StringGetCharacter(",", 0), t_arr);
    ArrayResize(curtrademode_arr, ArraySize(t_arr), 0);
    for (int i = 0; i < ArraySize(t_arr); i++)
    {
      curtrademode_arr[i] = StringToInteger(t_arr[i]);
    }
  }

  void convertCurperiod()
  {
    string t_arr[];
    StringSplit(curtrademode, StringGetCharacter(",", 0), t_arr);
    ArrayResize(curperiod_arr, ArraySize(t_arr), 0);
    for (int i = 0; i < ArraySize(t_arr); i++)
    {
      if (t_arr[i] == "M1")
        curperiod_arr[i] = PERIOD_M1;
      else if (t_arr[i] == "M5")
        curperiod_arr[i] = PERIOD_M5;
      else if (t_arr[i] == "M15")
        curperiod_arr[i] = PERIOD_M15;
      else if (t_arr[i] == "M30")
        curperiod_arr[i] = PERIOD_M30;
      else if (t_arr[i] == "H1")
        curperiod_arr[i] = PERIOD_H1;
      else if (t_arr[i] == "H4")
        curperiod_arr[i] = PERIOD_M4;
      else if (t_arr[i] == "D1")
        curperiod_arr[i] = PERIOD_D1;
    }
  }