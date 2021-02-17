
extern double lotincrease_step = 0.01;// no use 0.01;

extern double initlots = 0.04;// init lot size 0.04;
extern double initlotstep = 0.04;// no use 0.04;
double recoverPips = 100; // no use default val
double zcrecoverPips = 450;  // no use default val


extern double martingaletype = 2; // martin type 1 -> step method; 2 -> factor method
extern double martingalefactor = 1.5; // martin factor: Wilson say x1.3 for each new order
extern bool boundMartingaleLotsizenotsmallerthanLastOrder = true;

extern double martingale_targetProfitForEachOrder = 0; // targetProfitForEachOrder target profit/order 0 means disbale
extern double martingale_targetProfitForEachLot = 0; // targetProfitForEachLot target profit/lot 0 means disbale ::::: each 0.01 lot !!!!!!!!!!!!
extern double martingale_targetProfitTotalPips = 0; // targetProfitTotalPips target pips  0 means disbale ::: << this will set TP for each order
extern double martingale_targetProfitDropForEachOrder = 0; // no use 0 means disable : targetProfitDropForEachOrder

extern double martingale_profitprotectiontrigger = 8; // martin profitprotectiontrigger 
extern double martingale_profitprotectionaddon = 4; // martin profitprotectionaddon

extern double single_profitprotectiontrigger = 11; // normal profitprotectiontrigger 
extern double single_profitprotectionaddon = 8; // normal profitprotectionaddon

double zonecap_targetProfitForEachOrder = 3;

extern int martingale_lastordermin = 2; // lastordermin(mins) 20 means 20 minutes before the last recover order
extern int martingale_startrecover = 2; // startrecover(mins) 5 means start martingale logic after 5 minute

extern int maxrecoverypair = 99;
extern int maxopenedpair = 99;

string EA_NAME = "fba2";

extern int use_marquisbasicstochasticmethod = 1;
extern int usebasicentry = 0;

extern int defaulttrademode = 1; // no use

extern double adxfilter_value = 20; // no use


int currenttrademode = 1;

/* 

    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4

*/

int maxCommentLevel = 20;

extern string curlist = "XAUUSD"; // curlist ex:  XAUUSD,EURUSD,USDJPY
extern string curordertype = "2,2,2"; // ordertype: 0 -> Buy; 1 -> Sell; 2 -> Both
extern string curmagicnumber = "18000,19000,20000"; // magicnumber list
extern string curmaxorderno = "1,1,1"; // max no of order
extern string curperiod = "M15,M15,M15"; // period, ex: M1,M15,H1
extern string curtrademode = "1,1,1"; // trademode, 1 -> martin; 2-> zone cap
extern string curzonerecover = "450,450,450"; // zonecap range 
extern string curzone = "120,120,120"; // martin range