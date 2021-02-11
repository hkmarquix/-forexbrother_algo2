#property copyright "Copyright 2020, Marquis Chan"
#property link      "https://www.traland.com"
#property strict


void writelog_writeline(string msg)
{
   string InpFileName = "trade.txt";
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   string filename=terminal_data_path+"\\MQL4\\Files\\"+InpFileName;
   
    int file_handle=FileOpen(InpFileName,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI, ' ', CP_ACP);
    if(file_handle!=INVALID_HANDLE)
    {
         FileSeek(file_handle, 0, SEEK_END);
        FileWrite(file_handle,TimeCurrent() + " " + msg);
        FileClose(file_handle);
    }
    else
        PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
}