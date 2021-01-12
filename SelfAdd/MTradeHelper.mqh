#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "MarquisBasicStochasticEntry.mqh"

#include "../TradeInclude/TradeHelper.mqh"
#include "../TradeInclude/BasicEntry.mqh"
#include "../TradeInclude/BaseSignal.mqh"
#include "../TradeInclude/tradefunction.mqh"
#include "../RecoverAction/Martingale.mqh"
#include "../RecoverAction/ZoneCap.mqh"
#include "../Filter/TimeFilter.mqh"
#include "../Filter/ADXFilter.mqh"
#include "../Filter/CloseTimeFilter.mqh"

class MTradeHelper : public TradeHelper {
    private:
            
    public:
        
    MTradeHelper() {
        TradeHelper();
    }

// self modify
    void initHelper() {
        totalsignal = 0;
        if (usebasicentry == 1)
            totalsignal++;
        if (use_marquisbasicstochasticmethod == 1)
            totalsignal++;
        Print("Total signal size: " + totalsignal);
        ArrayResize(signalist, totalsignal , 0);

        initSignal(0);
        
    }


// self modify
    void initSignal(int currentsignali) {
        
        if (usebasicentry == 1)
        {
            signalist[currentsignali] = new BasicEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        if (use_marquisbasicstochasticmethod == 1)
        {
            signalist[currentsignali] = new MarquisBasicStochasticEntry();
            signalist[currentsignali].period = period;
            signalist[currentsignali++].symbol = symbol;
        }
        
        
    }

// Self include this and modify
    void signalRefresh(BaseSignal *bsignal)
    {
        //Print(bsignal.signalid);
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.Refresh();
        }
        if (bsignal.signalid == marquisbasicentry)
        {
            MarquisBasicStochasticEntry *mbe = (MarquisBasicStochasticEntry *)bsignal;
            mbe.Refresh();
        }
        
    }


// Self include this and modify
    bool createOrderFilter(int signal, double lotsize)
    {
        TimeFilter *tf = new TimeFilter();
        tf.symbol = symbol;
        tf.period = period;
        tf.actiontype = signal;
        tf.lotsize = lotsize;
        tf.magicNumber = magicNumber;
        tf.Refresh();
        int tsignal = tf.signal;
        delete(tf);
        if (tsignal != signal) {
            //Print("Order filtered by timefilter");
            return false;
        }

        ADXFilter *adxf = new ADXFilter();
        adxf.symbol = symbol;
        adxf.period = period;
        adxf.actiontype = signal;
        adxf.lotsize = lotsize;
        adxf.magicNumber = magicNumber;
        adxf.Refresh();
        tsignal = adxf.signal;
        delete(adxf);
        if (tsignal != signal) {
            //Print("Order filtered by adxfilter");
            return false;
        }

        CloseTimeFilter *ctf = new CloseTimeFilter();
        ctf.symbol = symbol;
        ctf.period = period;
        ctf.actiontype = signal;
        ctf.lotsize = lotsize;
        ctf.magicNumber = magicNumber;
        ctf.Refresh();
        tsignal = ctf.signal;
        delete(ctf);
        if (tsignal != signal) {
            //Print("Order filtered by closetimefilter");
            return false;
        }

        return true;
    }

    void closeSignalRefresh(BaseSignal *bsignal)
    {
        of_selectlastorder(symbol, magicNumber);
        if (bsignal.signalid == basicentryid)
        {
            BasicEntry *be = (BasicEntry *)bsignal;
            be.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        else if (bsignal.signalid == marquisbasicentry)
        {
            MarquisBasicStochasticEntry *mse = (MarquisBasicStochasticEntry *)bsignal;
            mse.RefreshCloseSignal(OrderType(), OrderOpenPrice());
        }
        
    }


// Self include this and modify
    void checkRecoverAction()
    {
        if (trademode == martingale)
        {
            Martingale *martin = new Martingale();
            martin.period = PERIOD_M1;
            martin.symbol = symbol;
            martin.magicNumber = magicNumber;
            martin.curzone = curzone;
            martin.currecover = currecover;
            martin.takeProfit();
            int res = martin.doRecovery();
            if (res == 2)
            {
               trademode = zonecap;
            }
            
            delete(martin);
        } else if (trademode == zonecap)
        {
            Zonecap *zc = new Zonecap();
            zc.period = period;
            zc.symbol = symbol;
            zc.magicNumber = magicNumber;
            zc.curzone = curzone;
            zc.currecover = currecover;
            zc.takeProfit();
            zc.doRecovery();
            
            delete(zc);
        } else if (trademode == simplestoploss)
        {

        } else if (trademode == signalclosesignal) {

        }
    }




};
