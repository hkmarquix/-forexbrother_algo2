
extern double lotincrease_step = 0.01;//0.01;

extern double initlots = 0.04;//0.04;
extern double initlotstep = 0.04;//0.04;
double recoverPips = 100; // default val
double zcrecoverPips = 450;  // default val


extern double martingaletype = 2; // 1 -> step method; 2 -> factor method
extern double martingalefactor = 2;
extern bool boundMartingaleLotsizenotsmallerthanLastOrder = true;

extern double martingale_targetProfitForEachOrder = 3; // 0 means disbale
extern double martingale_targetProfitForEachLot = 0.75; // 0 means disbale ::::: each 0.01 lot !!!!!!!!!!!!
extern double martingale_targetProfitTotalPips = 0; //  0 means disbale

extern double zonecap_targetProfitForEachOrder = 3;

extern int martingale_lastordermin = 20; // 20 means 20 minutes before the last recover order
extern int martingale_startrecover = 5; // 5 means start martingale logic after 5 minute

extern int maxrecoverypair = 5;
extern int maxopenedpair = 6;

string EA_NAME = "fba2";

extern int use_marquisbasicstochasticmethod = 1;
extern int usebasicentry = 0;

extern int defaulttrademode = 1;
int currenttrademode = 1;

/* 

    martingale = 1,
    zonecap = 2,
    simplestoploss = 3,
    signalclosesignal = 4

*/

int maxCommentLevel = 20;

extern string curlist = "XAUUSD"; // it can be :  XAUUSD,EURUSD,USDJPY
extern string curperiod = "M1"; // it can be : M1,M15,H1
extern string curtrademode = "1"; // it can be : 1,2,2
extern string curzonerecover = "120";
extern string curzone = "100";