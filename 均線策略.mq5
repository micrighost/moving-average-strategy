//+------------------------------------------------------------------+
//|                                                     均線策略.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include  <classpack.mqh>
ClassPack CPack ;


//策略說明:
//假設均線可以反映出大部分籌碼的位置，透過均線來找到相對好的買點。
//前天的最低價如果低於均線，而昨天的最低價高於均線，代表價格bar上穿且完全站上均線，那今天就開多單，停損在當下均線，停利為價格再次觸碰到均線現價。
//前天的最高價如果高於均線，而昨天的最高價低於均線，代表價格bar下穿且完全跌破均線，那今天就開空單，停損在當下均線，停利為價格再次觸碰到均線現價。
//
//
//
//參數
//MA20 均線


 
 
double ma_values[];                               //裝iMA值的陣列
double ma_handle;                                 //iMA指標的句柄

double before_yesterday_ma_values[];              //裝iMA值的陣列
double before_yesterday_ma_handle;                //iMA指標的句柄

double before_yesterday_high_price_ma_values[];   //裝1日iMA值的陣列
double before_yesterday_high_price_ma_handle;     //1日iMA指標的句柄

double before_yesterday_low_price_ma_values[];    //裝1日iMA值的陣列
double before_yesterday_low_price_ma_handle;      //1日iMA指標的句柄

double yesterday_high_price_ma_values[];          //裝1日iMA值的陣列
double yesterday_high_price_ma_handle;            //1日iMA指標的句柄

double yesterday_low_price_ma_values[];           //裝1日iMA值的陣列
double yesterday_low_price_ma_handle;             //1日iMA指標的句柄

int buy_count = 0;                                //持有多單
int sell_count = 0;                               //持有空單

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   //--- 創建iMA指標，MA20均線
   ma_handle = iMA(NULL,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);                    //週期20，偏移0
   
   //--- 創建iMA指標，前天MA20均線
   before_yesterday_ma_handle = iMA(NULL,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);   //週期20，偏移0
   
   //--- 創建iMA指標，前天最高價
   before_yesterday_high_price_ma_handle = iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_HIGH);
   
   //--- 創建iMA指標，前天最低價
   before_yesterday_low_price_ma_handle = iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);
   
   //--- 創建iMA指標，昨天最高價
   yesterday_high_price_ma_handle = iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_HIGH);
   
   //--- 創建iMA指標，昨天最低價
   yesterday_low_price_ma_handle = iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);   

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，MA20均線
   CopyBuffer(ma_handle,0,0,1,ma_values);                                             //ma_values[0]為當前bar的MA值
   
   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，前天MA20均線
   CopyBuffer(before_yesterday_ma_handle,0,2,1,before_yesterday_ma_values);           //before_yesterday_ma_values[0]為前天bar的MA值   
   
   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，前天最高價
   CopyBuffer(before_yesterday_high_price_ma_handle,0,2,1,before_yesterday_high_price_ma_values); //before_yesterday_high_price_ma_values[0]為當前bar的前兩根的MA值

   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，前天最低價
   CopyBuffer(before_yesterday_low_price_ma_handle,0,2,1,before_yesterday_low_price_ma_values);   //before_yesterday_low_price_ma_values[0]為當前bar的前兩根的MA值
   
   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，昨天最高價
   CopyBuffer(yesterday_high_price_ma_handle,0,1,1,yesterday_high_price_ma_values);   //yesterday_high_price_ma_values[0]為昨天bar的MA值
   
   //--- 用當前iMA的值填充ma_values[]數組
   //--- 複製1个元素，昨天最低價
   CopyBuffer(yesterday_low_price_ma_handle,0,1,1,yesterday_low_price_ma_values);     //yesterday_low_price_ma_values[0]為昨天bar的MA值
   
   

   if(CPack.isnewbar()){
      if(before_yesterday_low_price_ma_values[0] < before_yesterday_ma_values[0]){    //前天的最低價如果低於前天均線
         if(yesterday_low_price_ma_values[0] > ma_values[0]){                         //且昨天的最低價高於均線
            if(PositionsTotal() == 0){                                                //如果沒有持倉
               trade.Buy(0.01,NULL,0,ma_values[0]);                                   //開多單，0.01手，當前貨幣兌，現價，停損在當下均線
               buy_count = 1;                                                         //設置多單計數
            }         
         }   
      }
      
      
      if(before_yesterday_high_price_ma_values[0] > before_yesterday_ma_values[0]){   //前天的最高價如果高於前天均線
         if(yesterday_high_price_ma_values[0] < ma_values[0]){                        //且昨天的最高價低於均線
            if(PositionsTotal() == 0){                                                //如果沒有持倉
               trade.Sell(0.01,NULL,0,ma_values[0]);                                  //開空單，0.01手，當前貨幣兌，現價，停損在當下均線
               sell_count = 1;                                                        //設置空單計數
            }         
         }   
      }
   }
   
   
   if(buy_count == 1){                                            //如果有多單
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID) < ma_values[0]){   //當現價小於當前MA
         trade.PositionClose(_Symbol);                            //關閉之前的倉位
         buy_count = 0;                                           //重製計數
      } 
   } 
   
   if(sell_count == 1){                                           //如果有空單
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID) > ma_values[0]){   //當現價大於當前MA
         trade.PositionClose(_Symbol);                            //關閉之前的倉位
         sell_count = 0;                                          //重製計數
      } 
   } 
   
   
   
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
