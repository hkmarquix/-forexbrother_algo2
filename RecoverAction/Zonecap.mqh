#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

#include "BaseRecovery.mqh"

class Zonecap : public BaseRecovery {
    private:
           
    public:

    Zonecap() {

        initHelper();
    }

    void initHelper() {
        recoveryname = "Zonecap";
        recoveryid = zonecap;
    }

    ~Zonecap() {
        
    }

    int doRecovery() {
        if (!of_selectlastorder(symbol, magicNumber))
            return -1;

        if (OrderProfit() > 0)
            return -1;

        double lastprice = OrderOpenPrice();

        string param[];
        tf_commentdecode(OrderComment(), param);

        double cprice = 0;
        if (OrderType() == OP_BUY) {
            cprice = MarketInfo(symbol, MODE_ASK);
        }
        else
        {
            cprice = MarketInfo(symbol, MODE_BID);
        }

        double diff = MathAbs(cprice - lastprice) * of_getcurrencrymultipier(symbol);

        if (diff > currecover)
        {
            int newordertype = -1;
            if (OrderType() == OP_BUY)
                newordertype = OP_SELL;
            else if (OrderType() == OP_SELL)
                newordertype = OP_BUY;
                
            double tlotsoftype = tf_countAllLotsWithOrderType(symbol, magicNumber, OrderType());
            double tlotsofopptype = tf_countAllLotsWithOrderType(symbol, magicNumber, newordertype);
            int neworderi = StrToInteger(param[2]) + 1;
            double newlots = MathAbs(tlotsoftype - tlotsofopptype + OrderLots()) * 1.5;
            if (newlots > lotincrease_step * 10)
                newlots = MathAbs(tlotsoftype - tlotsofopptype + OrderLots()) * 1.1;
            tf_createorder(symbol, newordertype, newlots, IntegerToString(neworderi), "", 0, 0, recoveryname, magicNumber);
            setTakeProfitForZoneCapOrder(symbol, magicNumber, 0);
            return 1;
        }

        return -1;
    }

    int takeProfit()
    {
        double tprofit = tf_orderTotalProfit(symbol, magicNumber);
        int torder = tf_countAllOrders(symbol, magicNumber);
        if (tprofit > zonecap_targetProfitForEachOrder * torder) {
            tf_closeAllOrders(symbol, magicNumber);
            return 1;
        }

        return -1;
    }
    
    void setTakeProfitForZoneCapOrder(string _symbol, int _magicNumber, double _totalProfit)
    {
        double average_buyprice = tf_averageOpenPriceWithOrderType(symbol, magicNumber, OP_BUY);
        double average_sellprice = tf_averageOpenPriceWithOrderType(symbol, magicNumber, OP_SELL);
        
        of_selectlastorder(symbol, magicNumber);
        if (OrderType() == OP_SELL)
        {
            
        }
        else if (OrderType() == OP_BUY)
        {
        
        }
    }


};