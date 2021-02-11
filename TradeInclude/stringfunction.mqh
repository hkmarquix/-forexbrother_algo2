#property copyright "Copyright 2020, Marquis Chan"
#property link      "https://www.traland.com"
#property strict


void stringfunc_string2intarr(string _str, int &res[])
{
   string _strarr[];
   StringSplit(_str, StringGetCharacter(",", 0), _strarr);
   ArrayResize(res, ArraySize(_strarr), 0);
   for (int i = 0; i < ArraySize(_strarr); i++)
   {
      res[i] = StrToInteger(_strarr[i]);
   }
}

void stringfunc_string2arr(string _str, string &res[])
{
   StringSplit(_str, StringGetCharacter(",", 0), res);
}