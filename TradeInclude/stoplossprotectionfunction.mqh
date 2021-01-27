#property copyright "Copyright 2020, Marquis Chan"
#property link "https://www.traland.com"
#property strict

int stoplossprotection_checkNoProtectOrdersWithMagicNumberRange(int _magicnumber, int len)
{
   int torder = 0;
   bool foundmgno = false;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      for (int imm = _magicnumber; imm < _magicnumber + len; imm++)
      {
         if (OrderMagicNumber() == imm)
            foundmgno = true;
      }
      torder += stoplossprotection_checkOrderHasNoProtection("", OrderMagicNumber(), -1);
   }
   
   return torder;
}

int stoplossprotection_checkOrderHasNoProtection(string _symbol, int _magicnumber, int _ordertype)
{
   int torder = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (_symbol != "" && OrderSymbol() != _symbol)
         continue;
      if (_magicnumber > 0 && OrderMagicNumber() != _magicnumber)
         continue;
      if (_ordertype != -1 && OrderType() != _ordertype)
         continue;
      if (OrderStopLoss() == 0)
         torder++;
   }
   return torder;
}