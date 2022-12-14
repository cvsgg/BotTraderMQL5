//DESCRICAO: Robo de objeto de estudo, criado do zero, referencia de "Delta Trader" 
// com adaptações e comentarios proprios

// biblioteca
#include <Trade/Trade.mqh> // biblioteca-padrão CTrade
CTrade trade;

input int lote = 2;
input int periodo9 = 9;
input int periodo21 = 21;

//--- manipuladores
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;

//--- vetores para as medias moveis
double mCurta[];
double mLonga[];

int OnInit()
  {
   ArraySetAsSeries(mCurta,true); //indica a base de dados
   ArraySetAsSeries(mLonga,true);

//--- atribuir p/ os manupuladores de média móvel
   curtaHandle = iMA(_Symbol,_Period,periodo9,0,MODE_SMA,PRICE_CLOSE);
   longaHandle = iMA(_Symbol,_Period,periodo21,0,MODE_SMA,PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---
   
  }
  
void OnTick()
  {
   if(isNewBar()) //retorna ao iniciar novo candle
     {
//--- lógica operacional 

      int copied1 = CopyBuffer(curtaHandle,0,0,3,mCurta); //garante a leitura correta
      int copied2 = CopyBuffer(longaHandle,0,0,3,mLonga);
  
      bool sinalCompra = false; // variaveis dos sinais de entrada
      bool sinalVenda = false;

      if(copied1==3 && copied2==3)  //se "leu corretamente os sinais..."
        {
         //--- sinal de compra
         if( mCurta[1]>mLonga[1] && mCurta[2]<mLonga[2] ) // cruzamento da media menor para cima
           {
            sinalCompra = true;
           }
         //--- sinal de venda
         if( mCurta[1]<mLonga[1] && mCurta[2]>mLonga[2] ) // cruzamento da media menor para baixo
           {
            sinalVenda = true;
           }
        }   
        
      bool comprado = false;
      bool vendido = false;
      if(PositionSelect(_Symbol))
        {
         //--- avisar que a posição atual é de compra, caso seja
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY )
           {
            comprado = true;
           }
         //--- avisar que a posição atual é de venda, caso seja
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL )
           {
            vendido = true;
           }
        }     
//--- Roteamento
      //--- líquido
      if( !comprado && !vendido ) // avisar que não esta posicionado
        {
         //--- sinal de compra
         if( sinalCompra )      //se está liquido e houver sinal de compra entao compra a mercado
           {
            trade.Buy(lote,_Symbol,0,0,0,"Compra a mercado"); // função de compra a mercado
           }
         //--- sinal de venda
         if( sinalVenda )   //se está liquido e houver sinal de venda entao venda a mercado
           {
            trade.Sell(lote,_Symbol,0,0,0,"Venda a mercado"); //função de venda a mercado 
           }
        }
      else
        {
         //--- virada de mão de compra para venda
         if( comprado )
           {
            if( sinalVenda )
              {
               trade.Sell(lote*2,_Symbol,0,0,0,"Virada de mão");
              }
           }
         //--- virada de mão de venda para compra
         else if( vendido )
           {
            if( sinalCompra )
              {
               trade.Buy(lote*2,_Symbol,0,0,0,"Virada de mão");
              }
           }
        }
      
      
     }
  }
bool isNewBar()
  {
   static datetime last_time=0; // considera a ultima barra aberta
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;  //garante o tempo da barra sendo igual ao tempo corrente
      return(false);
     }
//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
   return(false);
  }