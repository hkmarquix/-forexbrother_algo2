
extern double lotincrease_step = 0.01;//0.01;

extern double initlots = 0.04;//0.04;
extern double initlotstep = 0.04;//0.04;
double recoverPips = 100; // default val
double zcrecoverPips = 450;  // default val


extern double martingaletype = 2; // 1 -> step method; 2 -> factor method
extern double martingalefactor = 1.5; // Wilson say x1.3 for each new order
extern bool boundMartingaleLotsizenotsmallerthanLastOrder = true;

extern double martingale_targetProfitForEachOrder = 0; // 0 means disbale
extern double martingale_targetProfitForEachLot = 0; // 0 means disbale ::::: each 0.01 lot !!!!!!!!!!!!
extern double martingale_targetProfitTotalPips = 0; //  0 means disbale ::: << this will set TP for each order
extern double martingale_targetProfitDropForEachOrder = 0; // 0 means disable : targetProfitDropForEachOrder

extern double martingale_profitprotectiontrigger = 11;
extern double martingale_profitprotectionaddon = 8;

double zonecap_targetProfitForEachOrder = 3;

extern int martingale_lastordermin = 2; // 20 means 20 minutes before the last recover order
extern int martingale_startrecover = 2; // 5 means start martingale logic after 5 minute

extern int maxrecoverypair = 5;
extern int maxopenedpair = 6;

string EA_NAME = "fba2";

extern int use_marquisbasicstochasticmethod = 1;
extern int usebasicentry = 0;

extern int defaulttrademode = 1;

extern double adxfilter_value = 22;


int currenttrademode = 1;

/* 

    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4

*/

int maxCommentLevel = 20;

extern string curlist = "XAUUSD,XAUUSD"; // curlist ex:  XAUUSD,EURUSD,USDJPY
extern string curordertype = "0,1"; // ordertype: 0 -> Buy; 1 -> Sell; 2 -> Both
extern string curmagicnumber = "18000,19000"; // magicnumber list
extern string curmaxorderno = "10,10"; // max no of order
extern string curperiod = "M1,M1"; // period, ex: M1,M15,H1
extern string curtrademode = "1"; // trademode, 1 -> martin; 2-> zone cap
extern string curzonerecover = "450,450"; // zonecap range 
extern string curzone = "100,100"; // martin range