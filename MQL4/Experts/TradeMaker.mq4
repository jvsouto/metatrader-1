//+------------------------------------------------------------------+
//|                                                   TradeMaker.mq4 |
//|                                    Copyright © 2015, Mark Hewitt |
//|                                      http://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Mark Hewitt"
#property link      "http://www.markhewitt.co.za"

#include "../Include/detectXXX.mqh"
#include "../Include/TradeFunctions.mqh"
#include "../Include/stdlib.mqh"

int Losses = 2;
string TradeHeader = "TMAKER";

double Balances[4];
int activeOrders[4];

int accountType = 0;         // account index into Symbols/Balances to put current trade onto
int risks_used = 0;         // number of risks trade was taken on
double sl_used = 0;        // stop loss size in pips used

bool initVariables = true;
bool hasNewBar = false;
datetime previousBar ;
string buttonID = "button";
string buttonClr = "buttonclr";
string buttonBE = "buttonbe";
string buttonTrade = "buttontrade";
string buttonInfo = "btninfo";
string buttonBuy = "buttonbuy";
string buttonSell = "buttonsell";
string buttonSFP = "buttonsfp";
string buttonATR24 = "buttonatr24";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   int btnLeft = 5;
   int btnSpace = 55;
   int btnTradeSpace = 45;
   
//----
//--- Create a button to send custom events
   button( buttonID, "Lines", btnLeft );   
   btnLeft += btnSpace;
   
   button( buttonClr, "Clear", btnLeft );   
   btnLeft += btnSpace;
   
 /*  button( buttonBuy, "Buy", btnLeft, 40 );
   btnLeft += btnTradeSpace;
   
   button( buttonSell, "Sell", btnLeft, 40 );
   btnLeft += btnTradeSpace;
   */
  // button( buttonInfo, "X", btnLeft, 12 );
  
   button( buttonSFP, "SFP", btnLeft, 40 );
   btnLeft += btnTradeSpace;
   
   button( buttonATR24, "@ATR", btnLeft, 40 );
   btnLeft += btnTradeSpace;
  
   ObjectCreate("atr20",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("atr20",OBJPROP_XDISTANCE,5);
   ObjectSet("atr20",OBJPROP_YDISTANCE,23);
   ObjectSetText("atr20","");
     
   ObjectCreate("atr24",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("atr24",OBJPROP_XDISTANCE,5+(2*btnSpace));
   ObjectSet("atr24",OBJPROP_YDISTANCE,23);
   ObjectSetText("atr24",""); 
      
   ObjectCreate("atr1",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("atr1",OBJPROP_XDISTANCE,5+(4*btnSpace));
   ObjectSet("atr1",OBJPROP_YDISTANCE,23);
   ObjectSetText("atr1","");
          
   ObjectCreate("symbol",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("symbol",OBJPROP_XDISTANCE,250);
   ObjectSet("symbol",OBJPROP_YDISTANCE,0);
   ObjectSetText("symbol","");
        
   ObjectCreate("tradesopen",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("tradesopen",OBJPROP_XDISTANCE,350);
   ObjectSet("tradesopen",OBJPROP_YDISTANCE,0);
   ObjectSetText("tradesopen","");
   
   ObjectCreate("tradesopen2",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("tradesopen2",OBJPROP_XDISTANCE,605);
   ObjectSet("tradesopen2",OBJPROP_YDISTANCE,0);
   ObjectSetText("tradesopen2",""); 
   /*
   ObjectCreate("trend_m15",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_m15",OBJPROP_XDISTANCE,860);
   ObjectSet("trend_m15",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_m15","M15");   
    
   ObjectCreate("trend_h1",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_h1",OBJPROP_XDISTANCE,885);
   ObjectSet("trend_h1",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_h1","H1"); 
      
   ObjectCreate("trend_h4",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_h4",OBJPROP_XDISTANCE,910);
   ObjectSet("trend_h4",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_h4","H4"); 
   
   ObjectCreate("trend_d1",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_d1",OBJPROP_XDISTANCE,930);
   ObjectSet("trend_d1",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_d1","D1");   
    
   ObjectCreate("trend_wk",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_wk",OBJPROP_XDISTANCE,950);
   ObjectSet("trend_wk",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_wk","WK");   
*/
//----
   return(0);
  }
  
void button(string name, string label, int left, int width = 50) {
   ObjectCreate(0,name,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGray);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,left);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,16);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
}
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   
//--- Check the event by pressing a mouse button
   if(id==CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject=sparam;
      
      if ( clickedChartObject == buttonInfo ) {
       //  printPairData();
         
        // 
       //  OrderClose(
         
         ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      //--- If you click on the object with the name buttonID
      if ( clickedChartObject == buttonID ) {
         if ( ObjectGetInteger(0,buttonID,OBJPROP_STATE) ) {
            showLines();
            ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
            ChartRedraw();
         }
      }
        
      if ( clickedChartObject == buttonClr ) {
         if ( ObjectGetInteger(0,buttonClr,OBJPROP_STATE) ) {
            cleanLines();
            showStats();
            ObjectSetString(0,buttonTrade,OBJPROP_TEXT,"Trade");
            ObjectSetInteger(0,buttonClr,OBJPROP_STATE,0);
            ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
            ObjectSetInteger(0,buttonTrade,OBJPROP_STATE,0);
            ChartRedraw();
         }
      }
      
      if ( clickedChartObject == buttonBE ) {
         goBreakEven(Symbol());
         ObjectSetInteger(0,buttonBE,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      if ( buttonSFP == clickedChartObject ) {
         
         ObjectSetInteger(0,buttonSFP,OBJPROP_STATE,0);
         ChartRedraw();
         
         if ( ObjectFind("sl") == 0 ) {
            loadStatBalances();
            bool result;

            // if SL is lower, we are going log, so set SL ATR(24) below the low of previous bar
            if ( ObjectGet("sl", OBJPROP_PRICE1) < Bid ) {
               ObjectSet("sl", OBJPROP_PRICE1, iLow(Symbol(),PERIOD_H1,1) - iATR(Symbol(),PERIOD_H1,24,1));
               ObjectSet("entry", OBJPROP_PRICE1, Bid);
               ObjectSet("tp", OBJPROP_PRICE1, Bid + iATR(Symbol(),PERIOD_H1,24,1));
            } else {
               ObjectSet("sl", OBJPROP_PRICE1, iHigh(Symbol(),PERIOD_H1,1) + iATR(Symbol(),PERIOD_H1,24,1));
               ObjectSet("entry", OBJPROP_PRICE1, Bid);
               ObjectSet("tp", OBJPROP_PRICE1, Bid - iATR(Symbol(),PERIOD_H1,24,1));
           }
         }
      }
      
      if ( buttonATR24 == clickedChartObject ) {
         ObjectSetInteger(0,buttonATR24,OBJPROP_STATE,0);
         ChartRedraw();
         ObjectDelete("sl");
         
         if ( ObjectFind("entry") == 0 ) {
            loadStatBalances();
            
            // if entry is lower, we are going long, so set SL ATR(24) below the entry price
            if ( ObjectGet("entry", OBJPROP_PRICE1) < Bid ) {
               addLine("sl", ObjectGet("entry", OBJPROP_PRICE1) - iATR(Symbol(),PERIOD_H1,24,1), clrCrimson );
            } else {
               addLine("sl", ObjectGet("entry", OBJPROP_PRICE1) + iATR(Symbol(),PERIOD_H1,24,1), clrCrimson );
           }
         }
      }
           
      if ( buttonTrade == clickedChartObject ) {
         if ( ObjectFind("buy") == 0 || ObjectFind("sell") == 0 ) {
            // change the trade line back to entry line if it exists
            // and put button back to a trade button
            ObjectSetString(ChartID(),"buy",OBJPROP_NAME,"entry");
            ObjectSetString(ChartID(),"sell",OBJPROP_NAME,"entry");
            ObjectSetString(0,buttonTrade,OBJPROP_TEXT,"Trade");
         } else {
            if ( ObjectFind("entry") == 0 ) {
               if ( ObjectGet("sl", OBJPROP_PRICE1) > ObjectGet("entry", OBJPROP_PRICE1) ) {
                  ObjectSetString(ChartID(),"entry",OBJPROP_NAME,"sell");
               } else {
                  ObjectSetString(ChartID(),"entry",OBJPROP_NAME,"buy");
               }
            } else {
               double sl = 0;
               double entry = 0;
               double tp = 0;
               double pip = symbolPoints(Symbol());
               string type = "";
               
               if ( isBearBar(Symbol(),Period(),1) ) {
                  sl = findRecentHigh()+pip;
                  entry = Low[1]-pip;
                  type = "sell";
               } else {
                  sl = findRecentLow()-pip;
                  entry = High[1]+pip;
                  type = "buy";
              }
   
               showLines(1,sl,entry);
               ObjectSetString(ChartID(),"entry",OBJPROP_NAME,type);
            }
            
            // toggle the button so that it now becomes a clear entry button
            ObjectSetString(0,buttonTrade,OBJPROP_TEXT,"Cancel");
         }   
            
         ObjectSetInteger(0,buttonTrade,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      return;
  }
  
   if ( id == CHARTEVENT_OBJECT_DRAG ) {
      showStats(true);
      saveTemplate();
   }
   /*
   if (id == CHARTEVENT_CLICK) {
       if ( ObjectGetInteger(0,buttonID,OBJPROP_STATE) && dparam > 20 ) {
         datetime t;
         double p;
         int s;
         ChartXYToTimePrice(0,lparam,dparam,s,t,p);
         
         int i = 0;
         while ( iTime(Symbol(),Period(),i) != t && i < 10000 ) {
            i++;
         }
         
         PrintFormat("Time=%s  O=%G Bar=%d " + sparam,TimeToString(t),iOpen(Symbol(),Period(),i),i);
   
         if ( i < 10000 ) {
            showLines(i);
         }
       }
   }*/
   
   if ( id == CHARTEVENT_CHART_CHANGE ) {
      showTrends();
   }
   
   if ( id == CHARTEVENT_OBJECT_CREATE ) {
      Print("Create Object: ",sparam);
      
      // if this is not a buy/sell line, then ensure the object is only visible
      // on this timeframe and those lower than it, and get the correct style for lines
      
      if ( sparam != "buy" && sparam != "sell" && sparam != "entry" && sparam != "pending" && sparam != "sl" && sparam != "tp" ) {
         ///ObjectSetInteger(ChartID(),sparam,OBJPROP_TIMEFRAMES,getObjTimeFrames());
         /*if ( ObjectType(sparam) == OBJ_HLINE || ObjectType(sparam) == OBJ_TREND ) {
            switch ( Period() ) {
               case PERIOD_MN1:
               case PERIOD_W1:
                  ObjectSetInteger(ChartID(),sparam,OBJPROP_WIDTH,3); 
                  break;
                 c
            }
         }*/
      }
      
      saveTemplate();
      
   }
}

void saveTemplate() {
   ChartSaveTemplate(0,Symbol());
}

int getObjTimeFrames() {
   int visibility = 0;
   
   // set visibility, we deliberatly let the settings cascase down though
   // the switch statement as that we show all lower timesframes as well as this one
   switch ( Period() ) {
      case PERIOD_MN1: return OBJ_ALL_PERIODS;
      case PERIOD_W1: visibility = OBJ_PERIOD_W1;
      case PERIOD_D1: visibility |= OBJ_PERIOD_D1;
      case PERIOD_H4: visibility |= OBJ_PERIOD_H4;
      case PERIOD_H1: visibility |= OBJ_PERIOD_H1;
      case PERIOD_M30: visibility |= OBJ_PERIOD_M30;
      case PERIOD_M15: visibility |= OBJ_PERIOD_M15;
      case PERIOD_M5: visibility |= OBJ_PERIOD_M5;
      case PERIOD_M1: visibility |= OBJ_PERIOD_M1;
   }
   
   return visibility;
}

void showLines(int shift=1, double sl = 0, double p = 0) {
   cleanLines();
   loadStatBalances();
   
   double minStop = minimumStop();
   double tp;
   if ( p == 0 ) {      // only set entry price if not given
      if ( shift == 0 ) {
         p = Bid;
      } else {
         p = iOpen(Symbol(),Period(),shift-1);
      }
   }
   
   if ( iOpen(Symbol(),Period(),shift) > iClose(Symbol(),Period(),shift) ) {
      // bear  bar - short trade
     if ( sl == 0 ) {      // only set SL if not given
       // short trade  -  default stop loss is ATR(24) below the low of the previous bar
       sl = iLow(Symbol(),Period(),shift) + symbolPoints(Symbol()) - iATR(Symbol(),PERIOD_H1,24,1);
     }
     tp = p - ( (sl-p) * 1.5 );
     // if the stoploss is less than the required minimum set it to be the minimum instead
     /*if ( sl - p < minStop ) {
       sl = p + minStop;
     }*/
    } else {
      // bull  bar - long trade
      if ( sl == 0 ) {      // only set SL if not given
         // long trade  -  default stop loss is ATR(24) above the high of the previous bar
         sl = iHigh(Symbol(),Period(),shift) - symbolPoints(Symbol()) - iATR(Symbol(),PERIOD_H1,24,1);
      }
     tp = p + ( (p-sl) * 1.5 );
     // if the stoploss is less than the required minimum set it to be the minimum instead
    /* if ( p - sl < minStop ) {
       sl = p - minStop;
     }*/
   }
      
   addLine("entry", p, clrSkyBlue );
   addLine("sl", sl, clrCrimson );
   addLine("tp", tp, clrLimeGreen );
   
   showStats(true);
   
  // ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
   ChartRedraw();// Forced redraw all chart objects
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      ObjectDelete("atr1");
      ObjectDelete("atr20");
      ObjectDelete("atr24");
      ObjectDelete("tradesopen");
      ObjectDelete("symbol");
      ObjectDelete("tradesopen2");
      ObjectDelete("trend_h1");
      ObjectDelete("trend_h4");
      ObjectDelete("trend_d1");
      ObjectDelete("trend_wk");
      ObjectDelete(buttonID);
      ObjectDelete(buttonClr);
      ObjectDelete(buttonTrade);
      ObjectDelete(buttonBE);
      ObjectDelete(buttonInfo);
      ObjectDelete(buttonBuy);
      ObjectDelete(buttonSell);

//----
   return(0);
  }
  
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 // averageOutSpread();
  
  if ( initVariables ) {
    initVariables = false;
    previousBar = iTime(Symbol(),Period(),0);
    loadStatBalances();
  }
  
  // on a regular basis reload the balances to ensure its synced, as well as saving the template
  // to try keep it as up to date as possible in case MT4 bombs
  if ( newBar(previousBar,Symbol(),Period()) ) {
     loadStatBalances();
     saveTemplate();
  } 
  
  showTrends();
  
   // if there are no open trades on this pair, check for a buy/sell line
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderSymbol() == Symbol() ) {
         // ensure chart color is highlighting that this market is in a active position
         ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'23,0,3');
         return(0); 
      }  
   }
   
   if ( ObjectFind("entry") == 0 || ObjectFind("buy") == 0 || ObjectFind("sell") == 0 ) {
   
      showStats();
   
      // if we have a pending order, we can trade if the price is between the SL and order price
     /* if ( ObjectFind("pending") == 0 ) {
         
         // ensure chart color is highlighting that this market has an enabled order
         ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'2,0,21'); 
      
         double sl = ObjectGet("sl", OBJPROP_PRICE1);
         double price = ObjectGet("pending", OBJPROP_PRICE1);
         if ( price > sl && sl < Bid && Bid <= price ) {
            ObjectDelete("pending");
            ObjectDelete("buy");       // cleanup in case ...
            ObjectCreate("buy", OBJ_HLINE, 0, TimeCurrent(), price);
         } else if ( price < sl && sl > Bid && Bid >= price ) {
            ObjectDelete("pending");
            ObjectDelete("sell");         // cleanup in case ...
            ObjectCreate("sell", OBJ_HLINE, 0, TimeCurrent(), price);
         } 
      }
   */
      // buy line, we always try to buy below market, so when price is at or below our line we go long
      if ( ObjectFind("buy") == 0 ) {
        // ensure chart color is highlighting that this market has an order able to trade
        ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'2,17,0'); 
        
        if ( Bid <= ObjectGet("buy", OBJPROP_PRICE1) ) {
            if ( tradeBalances(OP_BUY) ) {
               ObjectDelete("buy");
               ObjectDelete("sl");
               ObjectDelete("tp");
            }
         } else {
            ObjectSetText("buy", "Stop Size: " + DoubleToString((ObjectGet("sl", OBJPROP_PRICE1) - ObjectGet("buy", OBJPROP_PRICE1))/symbolPoints(Symbol()),1) );
         }
     }
   
      if ( ObjectFind("sell") == 0 ) {
         // ensure chart color is highlighting that this market has an order able to trade
        ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'2,17,0'); 
        
        if ( Bid >= ObjectGet("sell", OBJPROP_PRICE1) ) {
            if ( tradeBalances(OP_SELL) ) {
               ObjectDelete("sell");
               ObjectDelete("sl");
               ObjectDelete("tp");
            }
        } else {
            ObjectSetText("sell", "Stop Size: " + DoubleToString((ObjectGet("sl", OBJPROP_PRICE1) - ObjectGet("sell", OBJPROP_PRICE1))/symbolPoints(Symbol()),1) );
         }
      }
      
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void cleanLines() {
   ObjectDelete("pending");
   ObjectDelete("inactive buy");
   ObjectDelete("inactive sell");
   ObjectDelete("buy");
   ObjectDelete("sell");
   ObjectDelete("BREAKEVEN");
   ObjectDelete("sl");
   ObjectDelete("tp");
   ObjectDelete("entry");         
   ChartSetInteger(0,CHART_COLOR_BACKGROUND, clrBlack );
   
 /*  long id = ChartFirst();
   do {
      ObjectDelete(id,"sl");
      ObjectDelete(id,"tp");
      ObjectDelete(id,"entry");         
   } while ( (id = ChartNext(id)) >= 0 );
*/
}

void addLine( string name, double price, const color clr = clrWhiteSmoke, const ENUM_LINE_STYLE style=STYLE_DASHDOT ) {
   
   // now find all other windows, and add this line as a non-editabele object for visual ref
   long id = ChartFirst();
   // Print ("Chart ",id," ",ChartPeriod(id));
   do {
      
      if ( ChartSymbol(id) == Symbol() ) {
   
     //    Print ("Chart ",id," ",ChartPeriod(id));
         if ( ObjectFind(id,name) >= 0 ) {
          //  ObjectDelete(id,name);
         }
   
         ObjectCreate(id,name,OBJ_HLINE,0,0,price);
         ObjectSetInteger(id,name,OBJPROP_COLOR,clr);
         ObjectSetInteger(id,name,OBJPROP_STYLE,style);
         
         // if this is not the main window, make it non editable
         if ( id != ChartID() ) {
          //  ObjectSetInteger(id,name,OBJPROP_SELECTABLE,false);
         }
      }  
   } while ( (id = ChartNext(id)) >= 0 );
   
}

void atrLine(string name,double price,string label) {
   if ( ObjectFind(name) < 0 ) {
      ObjectCreate(name,OBJ_TREND,0,iTime(Symbol(),PERIOD_D1,0),Bid,TimeCurrent(),Bid);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrLemonChiffon);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   }
   
   ObjectSetString(0,name,OBJPROP_TOOLTIP,label + ": " + DoubleToString(price,Digits));
   ObjectMove(0,name,0,iTime(Symbol(),PERIOD_D1,0),price);
   ObjectMove(0,name,1,TimeCurrent(),price);
}

void showTrends() {  
   
   double todaysHigh = iHigh(Symbol(),PERIOD_D1,0);
   double todaysLow = iLow(Symbol(),PERIOD_D1,0);


   double m = 10000;
   if ( Digits == 3 || Digits == 2 ) {
      m = 100;
   } else if ( Digits != 5 ) {
      m = 1;
   }
   

   double atr20 = iATR(Symbol(),PERIOD_D1,20,1);
   ObjectSetText("atr20","ATR(20): " + DoubleToStr(atr20*m,0),NULL,"Arial",White); 
   ObjectSetText("atr24","ATR(24): " + DoubleToStr(iATR(Symbol(),PERIOD_H1,24,1)*m,0),NULL,"Arial",White); 
   ObjectSetText("atr1","ATR: " + DoubleToStr(MathAbs(todaysHigh-todaysLow)*m,0),NULL,"Arial",White);

//atrLine("datrh", todaysLow + atr20, "ATR High");
  // atrLine("datrl", todaysHigh - atr20, "ATR Low");
    
   return;

   updateTrend("trend_m15",PERIOD_M15);
   updateTrend("trend_h1",PERIOD_H1);
   updateTrend("trend_h4",PERIOD_H4);
   updateTrend("trend_d1",PERIOD_D1);
   updateTrend("trend_wk",PERIOD_W1);
}

void updateTrend(string label, int period) {
   int trend = detectTrend(Symbol(),period);
   if ( trend != TRADE_ARROW_NONE ) {
      drawTrendLabel(label,trend,true);
   } else {
      drawTrendLabel(label,detect50(Symbol(),period),false);
   }
   
   int width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   ObjectSet("trend_m15",OBJPROP_XDISTANCE,width-190); 
   ObjectSet("trend_h1",OBJPROP_XDISTANCE,width-158); 
   ObjectSet("trend_h4",OBJPROP_XDISTANCE,width-137); 
   ObjectSet("trend_d1",OBJPROP_XDISTANCE,width-115); 
   ObjectSet("trend_wk",OBJPROP_XDISTANCE,width-95); 
}

void drawTrendLabel(string label, int trend, bool supa) {
   if ( trend == TRADE_ARROW_BUY ) {
      ObjectSetInteger(0,label,OBJPROP_COLOR,clrLime);
   } else {
      ObjectSetInteger(0,label,OBJPROP_COLOR,clrCrimson);
   }
   if ( supa ) {
      ObjectSetString(0,label,OBJPROP_FONT,"Arial Black");
   } else {
      ObjectSetString(0,label,OBJPROP_FONT,"Arial");
   }
}

void showStats(bool updateSL = false) {
 
   double price = 0;
   double rate = Bid;
   double tp = 0;
   
   if ( ObjectFind("sl") != 0 ) {
      ObjectSetText("tradesopen","",NULL,"Arial",White); 
      ObjectSetText("tradesopen2","",NULL,"Arial",White); 
      return;
   }
   
   double sl = ObjectGet("sl", OBJPROP_PRICE1);
   if ( ObjectFind("pending") == 0 ) {
      double p = ObjectGet("pending", OBJPROP_PRICE1);
      if ( p > sl ) {
         // pending buy, so must buy from the ask line when cpmputing lots
         rate = p + (Ask-Bid);
      } else {
         rate = p;
      }
   }
   
   if ( ObjectFind("buy") == 0 ) {
       rate = ObjectGet("buy", OBJPROP_PRICE1);
        /*if ( p > Bid ) {
          rate = (Ask-Bid) + p;
        } else {
           rate = Ask;
        }*/
     
    }
    else  if ( ObjectFind("sell") == 0  ) {

         rate = ObjectGet("sell", OBJPROP_PRICE1);
       /*  if ( p < Bid ) {
          rate =  p;
        } else {
           rate = Bid;
        }*/

      
   } else if ( ObjectFind("entry") == 0 ) {
       double p = ObjectGet("entry", OBJPROP_PRICE1);
      if ( ObjectGet("tp", OBJPROP_PRICE1) > ObjectGet("sl", OBJPROP_PRICE1) ) {         
          rate = (Ask-Bid) + p;
     } else {
          rate = p;
     } 
   } 
    
    if ( ObjectFind("tp") == 0 ) {
      tp = ObjectGet("tp", OBJPROP_PRICE1);
    } else {
        if ( rate > sl ) {
           tp = rate + (MathAbs(rate - sl)*1.5);
        } else {
           tp = rate - (MathAbs(rate - sl)*1.5);
       }
    }
    
   // check to ensure the stoploss is greater than the minimum, if not
   // then we adjust the sl level until it meets this requirement
/*if ( updateSL ) {
      double minStop = minimumStop();
      if ( MathAbs(rate-sl) < minStop ) {
         if ( rate > sl ) {      // are we buying, i.e. sl is lower than rate?
            sl = rate - minStop;
         } else {
            sl = rate + minStop;
         }
         ObjectSet("sl", OBJPROP_PRICE1, sl);
      }
   }
*/   
   // update all companion charts to make sure trade levels are synced
   /*long cid = ChartFirst();
   do {
      if ( cid != ChartID() ) {
          ObjectSetDouble(cid,"sl", OBJPROP_PRICE1, sl);
          ObjectSetDouble(cid,"tp", OBJPROP_PRICE1, tp);
          ObjectSetDouble(cid,"entry", OBJPROP_PRICE1, rate);
      }
   } while ((cid=ChartNext(cid)) >= 0);
*/    
   // if no order or sell then we just assume the Bid rate 
   
   double points = symbolPoints(Symbol());
   double stoploss = MathAbs(rate - sl) / points;   
   double takeprofit = 0;
   double rr = 0;
   double lots = 0;
   double balance = 0;
   double loss = 0;
   double profit = 0;
   
   int account = accountForTrade(Symbol());
   if ( account != -1 ) {
      lots = GetLots(stoploss);
      balance = Balances[account];
      loss = getTradeValue(stoploss, lots);
      if ( tp > 0 ) {
         takeprofit = MathAbs(rate - tp) / points;
         profit = getTradeValue(takeprofit, lots);
         rr = takeprofit/stoploss;
      }
   }
  
   string s = "(" + DoubleToStr(symbolPoints(Symbol()),4) + " x $" + DoubleToStr(tickValue()/10,2) + ")";  // show tick value as 0.01 lots
   ObjectSetText("symbol",s,NULL,"Arial",White);
    
   string t = "$" + DoubleToStr(balance,2) + "; L: " + DoubleToStr(lots,2) + "; SL: " + DoubleToStr(stoploss,0) + "; Loss: $" + DoubleToStr(loss,2); 
   ObjectSetText("tradesopen",t,NULL,"Arial",White);
   if ( tp > 0 ) {
      t = " TP: " + DoubleToStr(takeprofit,2) + "; P: $" + DoubleToStr(profit,2) + "; R: " + DoubleToStr(rr,1) + ":1";
      ObjectSetText("tradesopen2",t,NULL,"Arial",White);
   } else {
       ObjectSetText("tradesopen2","",NULL,"Arial",White);
  }
}


bool goLong(double deduct_lots = 0)
{
   double points = symbolPoints(Symbol());
   
   double stopPrice = Bid - symbolPoints(Symbol()) - iATR(Symbol(),PERIOD_H1,24,1); 
   // if there is a set SL use it rather then the default ATR(24)
   if ( ObjectFind("sl") == 0 ) {
      stopPrice = ObjectGet("sl", OBJPROP_PRICE1);
   }
   double stoploss = MathAbs(Ask - stopPrice) / points;
   
   double takeProfit = Ask + (stoploss*1.5*points);
   double breakEven = Ask + (stoploss*1*points);

   // if there is a TP line then adjust the TP to be the set level rather than fixed amount
   if ( ObjectFind("tp") == 0 ) {
      takeProfit = ObjectGet("tp", OBJPROP_PRICE1);
   }
   
   
   RefreshRates();
   while(IsTradeContextBusy() ) Sleep(100);
   double lots = GetLots(stoploss) - deduct_lots;
   if ( lots > 0 ) {    
     // Print("Trading: ",stopPrice, " ; ", takeProfit);
      int result = OrderSend(Symbol(), OP_BUY, lots, Ask, 0, stopPrice, takeProfit, getComment(), accountType+1, 0, Green); 
      if ( result < 0 ) {
         int err = GetLastError();
         if ( err == ERR_REQUOTE ) {
            // on a requote let it try again on the next tick
            return false;
         } else {
            // some other error (which will appear in journal, permanent failure so return true
            // to ensure the trade lines are removed so we dont keep trying
            Print("Failed to go LONG on ", Symbol()," : ",ErrorDescription(err));
            return false;
         } 
      }
      GlobalVariableSet("gActiveOrder" + (accountType+1),result);
      Print(getComment());
      ObjectCreate("BREAKEVEN", OBJ_HLINE, 0, TimeCurrent(), breakEven);
   } else {
      Print( "Cannot go LONG, no valid accounts for ", Symbol());
   }
   
   // permanent failure or success, flag the trade lines must be removed
   return true;
}

bool goShort(double deduct_lots = 0)
{
   double points = symbolPoints(Symbol());
   
   double stopPrice = Bid - symbolPoints(Symbol()) - iATR(Symbol(),PERIOD_H1,24,1) + (Ask-Bid);
   // if there is a set SL use it rather then the default ATR(24)
   if ( ObjectFind("sl") == 0 ) {
      stopPrice = ObjectGet("sl", OBJPROP_PRICE1) + (Ask-Bid);
   }
   double stoploss = MathAbs(stopPrice - Bid) / points;
   
   double takeProfit = Bid - (stoploss*1.5*points);
   double breakEven = Bid - (stoploss*1*points);

   // if there is a TP line then adjust the TP to be the set level rather than fixed amount
   if ( ObjectFind("tp") == 0 ) {
      takeProfit = ObjectGet("tp", OBJPROP_PRICE1);
   }
   
   
   RefreshRates();
   while(IsTradeContextBusy() ) Sleep(100);
   double lots = GetLots(stoploss) - deduct_lots;
   if ( lots > 0 ) {
      int result = OrderSend(Symbol(), OP_SELL, lots, Bid, 0, stopPrice, takeProfit, getComment(), accountType+1, 0, Red); 
      if ( result < 0 ) {
         int err = GetLastError();
         if ( err == ERR_REQUOTE ) {
            // on a requote let it try again on the next tick
            return false;
         } else {
            // some other error (which will appear in journal, permanent failure so return true
            // to ensure the trade lines are removed so we dont keep trying
            Print("Failed to go LONG on ", Symbol());
            return false;
         } 
      }
      GlobalVariableSet("gActiveOrder" + (accountType+1),result);
      Print(getComment());
      ObjectCreate("BREAKEVEN", OBJ_HLINE, 0, TimeCurrent(), breakEven);
   } else {
      Print( "Cannot go SHORT, no valid accounts for ", Symbol() );
   }
   
   // permanent failure or success, flag the trade lines must be removed
   return true;
}

void loadStatBalances() {
  /* int handle;
   handle=FileOpen("balances.csv",FILE_CSV|FILE_READ,';');
   if(handle<1)
   {
      Print("Cannot load balances for Stats, the last error is ", GetLastError());
      return;
   }
   
   TradeHeader = FileReadString(handle);                   // trade account name
   Losses = StringToInteger( FileReadString(handle) );                        // risks to apply to this account
   Balances[0] = StrToDouble( FileReadString(handle) );    // 1
   Balances[1] = StrToDouble( FileReadString(handle) );    // 2
   Balances[2] = StrToDouble( FileReadString(handle) );    // 3
   Balances[3] = StrToDouble( FileReadString(handle) );    // 4
   FileClose(handle);
*/

   // before we fetch the baalance, check if there are active trades
   // if there are any active orders, and that order has gone from
   // open to closed, we adjust the global balance to reflect result 
   // and clear the active order code to prevent this happening multiple times
  /* for ( int i = 1; i <= 4; i++ ) {
      int order = GlobalVariableGet("gActiveOrder" + i); 

      if ( order > 0 && OrderSelect(order,SELECT_BY_TICKET) ) {
         // order was not longer in active trades so select it from the history so we can get the profit
         if ( OrderCloseTime() != 0 ) {
            GlobalVariableSet("gTradableBalance" + i, GlobalVariableGet("gTradableBalance" + i) + OrderProfit());
            GlobalVariableSet("gActiveOrder" + i, 0); 
         }
      }
   }

   TradeHeader = "MainAccount" ;//GlobalVariableGet("gTradeHeader");
   Losses = GlobalVariableGet("gLosses");
   Balances[0] = GlobalVariableGet("gTradableBalance1");    // 1
   Balances[1] = GlobalVariableGet("gTradableBalance2");    // 2
   Balances[2] = GlobalVariableGet("gTradableBalance3");    // 3
   Balances[3] = GlobalVariableGet("gTradableBalance4");    // 4
    */
   
   TradeHeader = "MainAccount" ;
   Losses = GlobalVariableGet("gLosses");  
   Balances[0] = AccountBalance() - GlobalVariableGet("gOpeningBalance");
   Balances[1] = 0;
   Balances[2] = 0; 
   Balances[3] = 0; 
 
}

bool tradeBalances(int trade) {

   // file reading has been cuasing 5004 errors causing trades to not be entered
   // so for now we use a single account, single balance trhough a global until
   // we have made some money and are at the point of wanting multiple accounts
   
   loadStatBalances();
   Print ("Account ",TradeHeader, "; Risk ", Losses, "; Balances: $", Balances[0]," , $",Balances[1]," , $",Balances[2]," , $",Balances[3]);
   
   if ( trade == OP_BUY ) {
      return goLong();
   } else {
      return goShort();
   }   
   
   
   //  the code below is skipped for now because of the returns above


   int handle;
   handle=FileOpen("balances.csv",FILE_CSV|FILE_READ,';');
   if(handle<1)
   {
      Print("Cannot load trade balances, the last error is ", GetLastError());
      return(false);
   }
   
   // we use this to flag if an attempt to trade failed so that we can try again next time
   // normally this is a reqoute so we want to EA to try on each tick until our order goes in
   bool tradeSuccessful = true;
   
   // this uses the "old" format still, one line per account, allowing us to trade
   // several accounts on one station (unline stats balances above which uses only the first account)
   // format is:
   // [accountname];[risks];[balance1];[balance2];[balance3];[balance4]
   // [accountname];[risks];[balance1];[balance2];[balance3];[balance4]
   // ....
   // END
   // 
   // Each account can have up to four "balances" sub-accounts that are used is there is a trade already
   // on this account, typically not used, its easier to manage multiple accounts (lines)
   //
      
   TradeHeader = FileReadString(handle);                   // trade account name
   while ( TradeHeader != "END" ) {
      Losses = StringToInteger(FileReadString(handle));                        // risks to apply to this account
      Balances[0] = StrToDouble( FileReadString(handle) );    // 1
      Balances[1] = StrToDouble( FileReadString(handle) );    // 2
      Balances[2] = StrToDouble( FileReadString(handle) );    // 3
      Balances[3] = StrToDouble( FileReadString(handle) );    // 4
      Print ("Account ",TradeHeader, "; Risk ", Losses, "; Balances: $", Balances[0]," , $",Balances[1]," , $",Balances[2]," , $",Balances[3]);
      
      if ( trade == OP_BUY ) {
         tradeSuccessful = goLong();
      } else {
         tradeSuccessful = goShort();
      }
      
      TradeHeader = FileReadString(handle);                   // trade account name
   }
   FileClose(handle);
   
   return (tradeSuccessful);
   
//   Print( "Balanced: M:", TradableBalance, "; U:",USD, "; E:",EUR, "; G:",GBP, "; J:",JPY, "; A:",AUD, "; F:",Futures, "; C:",Commodities );
}

string getComment() {
   return (TradeHeader + ";" + IntegerToString(accountType+1) + "; $" + DoubleToStr(Balances[accountType],2));
}

double GetLots( double stopLoss ) { 

   accountType = accountForTrade(Symbol());
   if ( accountType != -1 ) {
      sl_used = stopLoss;
      risks_used = Losses;
      return (getLotsForBalance(stopLoss,accountType,Losses));
   }
   
   return (0);
}

double getLotsForBalance( double stopLoss, int account, int risk ) {
   double lots;
   double balance = Balances[account];

   lots = (MathFloor( (balance/(risk*stopLoss*tickValue()))*10 ) / 10) / 10;
   if ( lots < 0.01 ) { return 0.01; }
  
   // determine if the size of our risk is greater than the last tradeif the last trade was a win
   // if so throttle the size so that we do not loose more than we just won to minimize thrashing
   // in a W/L/W/L sequence
   double orderSize = lots*stopLoss*tickValue()*10;
    for (int cc = OrdersHistoryTotal() - 1; cc >= 0; cc--)
    {
      if (!OrderSelect(cc, SELECT_BY_POS,MODE_HISTORY) || OrderSymbol() == "" || (OrderProfit() >= 0 && OrderProfit() <= 8) ) continue;
      if ( OrderProfit() > 0  ) {
         // last trade was a winner, so use it to cap the loss 
         if ( orderSize > OrderProfit() ) {
            // convert profit to whole multiples of 10c then chop off any cents left to get a whole number of $0.1 units for converting to lots
            lots = (MathFloor( (OrderProfit()/stopLoss) * 10 ) / 10) / 10;
            if ( lots < 0.01 ) { return 0.01; }
         }
      } 
   //   Print( orderSize , " ; ", OrderSymbol() , " ; ", OrderProfit(), " ; " , lots, " ; " , lots*stopLoss*tickValue() );
      break;
   } 
   
  //Print (tickValue(), " ; ", MathFloor( (balance/(risk*stopLoss*tickValue()))*10 ));
 //  Print( ": Lots ", lots, " with SL ", stopLoss , " and balance ", balance );
   return (lots);
}

int accountForTrade(string symbol) {

   // ugly code, filter out the accounts that are not available for trading
   // by simply setting their balance to 0, Balances is reloaded each time
   // so this does not future trades
   // we dont do this if risks > 8 as these are large accounts handling multiple simultaneous trades on one balance
   if ( Losses <= 8 ) {
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         if ( OrderComment() != "" ) {
            string c[];
            StringSplit(OrderComment(),';',c);
            if ( c[0] == TradeHeader ) {
              Balances[ StringToInteger(c[1]) - 1 ] = 0;     // accounts number 1,2.. in comment not zero-based
            }
            /*if ( OrderMagicNumber() > 0 ) {
               Balances[ OrderMagicNumber() - 1 ] = 0;     // accounts number 1,2.. in magic number not zero-based
            }*/
         }
      }
   }
   
   // now we trade on the account that has the highest balance
   // so loop through the list and pick the best one
   double max = 0;
   int account = -1;
   for ( int i = 0; i < ArraySize(Balances); i++ ) {
      if ( Balances[i] > max ) {
         max = Balances[i];
         account = i;
      }
   }

   return (account);      // cannot find a valid account
}



// This function return the value true if the current bar/candle was just formed
// Inspired by: simplefx2.mq4, http://www.GetForexSoftware.com
bool newBar(datetime& previousBar,string symbol,int timeframe)
{
   if ( previousBar < iTime(symbol,timeframe,0) )
   {
      previousBar = iTime(symbol,timeframe,0);
      return(true);
   }
   else
   {
      return(false);
   }
}
