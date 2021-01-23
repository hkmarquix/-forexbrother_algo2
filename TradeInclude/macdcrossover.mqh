
int macdjustcross(int actiontype, string symbol, int period, int windowtocheck, int wait1window, bool crossabovezero, double abovelevel)
{
    string tradeparam = "";
    bool crosshappen = false;
    int crossside = -1;
    int signalside = actiontype;
    for (int i = 0; i < windowtocheck; i++)
    {
        tradeparam += " i: " + i;
        double macdm5 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i);
        double macds5 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i);
        double macdm5_1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i + 1);
        double macds5_1 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i + 1);
        
        double macdm5_2 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i + 2);
        double macds5_2 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i + 2);
        double macdm5_3 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i + 3);
        double macds5_3 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i + 3);
        double macdm5_4 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i + 4);
        double macds5_4 = iMACD(symbol, period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i + 4);
        
        if (wait1window > i) {
            continue;
        }
        
        if (macdm5 > macds5 && macdm5_1 < macds5_1
        //&& macdm5_2 < macds5_2 
        //&& macdm5_3 < macds5_3 
        //&& macdm5_4 < macds5_4 
        )
        {
        if (macdm5 < -1 * abovelevel || !crossabovezero) {
            tradeparam += " cross at " + i;
            crosshappen = true;
            crossside = OP_BUY;
            }
        }
        else if (macdm5 < macds5 && macdm5_1 > macds5_1
        //&& macdm5_2 > macds5_2 
        //&& macdm5_3 > macds5_3 
        //&& macdm5_4 > macds5_4 
        )
        {
        if (macdm5 > abovelevel || !crossabovezero) {
            tradeparam += " cross at " + i;
            crosshappen = true;
            crossside = OP_SELL;
            }
        }
        //if (crosshappen)
        //   tradeparam += StringFormat("\nMS macd CH %d/%d: %f, %f  _1: %f, %f", i, windowtocheck, macdm5, macds5, macdm5_1, macds5_1);
        //else
        //   tradeparam += StringFormat("\nMS macd NC %d/%d: %f, %f  _1: %f, %f", i, windowtocheck, macdm5, macds5, macdm5_1, macds5_1);
        
        if (crosshappen) {
        //tradeparam += "[break]";
        break;
        }
        
    }
    
    tradeparam += "[end]";
    if (crosshappen && signalside == crossside)
        return signalside;
    return -1;
}
