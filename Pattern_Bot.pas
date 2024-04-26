input
  Pattern_1(true); // Entrada para ativar ou desativar Pattern_1
  Pattern_2(true); // Entrada para ativar ou desativar Pattern_2
  lote(1); // Tamanho do lote
  breakeven(150); // Distância para mover o stop loss para o ponto de equilíbrio

var 
  AJUSTE : FLOAT; // Variável para armazenar o ajuste
  sPavilVenda     : FLOAT;  // Variável para armazenar sPavilVenda
  sPavilCompra    : FLOAT;  // Variável para armazenar sPavilCompra
  sViolinadaVenda : FLOAT;  // Variável para armazenar sViolinadaVenda
  sViolinadaCompra : FLOAT; // Variável para armazenar sViolinadaCompra
  gain_compra, loss_compra : FLOAT; // Variáveis para ganho e perda em operações de compra
  gain_venda, loss_venda : FLOAT; // Variáveis para ganho e perda em operações de venda

begin
  AJUSTE  := DecisionPoints(0,4); // Calcula o ajuste
  Plot(AJUSTE); // Plota o ajuste no gráfico

  // Verifica se Pattern_1 está ativado
  if(Pattern_1 = true) then
  begin
    // Verifica se as condições para um padrão de venda foram atendidas
    if (High[0] > High[1]) and (High[1] > High[2]) and (Close[1] < High[2]) and (Close[0] < High[2]) then
    begin
      PaintBar(clBlue); // Pinta a barra de azul
      PlotText("W.V", clWhite); // Plota texto "W.V" em branco
      
      // Verifica se não há posição de compra ou venda aberta
      if (BuyPosition() = 0) and (SellPosition() = 0)  then
      begin      
        SellShortAtMarket(); // Abre uma posição de venda a descoberto
      end;               

      // Verifica se a posição de venda foi aberta
      if IsSold then
      begin
        gain_venda := low[2]; // Define o preço de ganho na venda
        loss_venda := high + 50; // Define o preço de perda na venda
        BuyToCoverLimit(gain_venda); // Define o limite de compra para o ganho
        BuyToCoverStop(loss_venda, loss_venda); // Define o stop loss na venda
      end;
    end;

    // Verifica se as condições para um padrão de compra foram atendidas
    if (Low[0] < Low[1]) and (Low[1] < Low[2]) and (Close[1] > Low[2]) and (Close[0] > Low[2]) then
    begin
      PaintBar(clWhite); // Pinta a barra de branco
      PlotText("W.C", clWhite); // Plota texto "W.C" em branco

      // Verifica se não há posição de compra ou venda aberta
      if (BuyPosition() = 0) and (SellPosition() = 0)  then
      begin      
        BuyAtMarket(); // Abre uma posição de compra
      end;               

      // Verifica se a posição de compra foi aberta
      if IsBought then
      begin
        gain_compra := high[2]; // Define o preço de ganho na compra
        loss_compra := low - 50; // Define o preço de perda na compra
        SellToCoverLimit(gain_compra); // Define o limite de venda para o ganho
        SellToCoverStop(loss_compra, loss_compra); // Define o stop loss na compra
      end;
    end;
  end;

  // Verifica se Pattern_2 está ativado
  if(Pattern_2 = true) then
  begin
    // Calcula sPavilVenda e sViolinadaVenda
    sPavilVenda := High[1] - Close[1];
    sViolinadaVenda := High[0] - High[1];

    // Verifica se as condições para um padrão de venda em Pattern_2 foram atendidas
    if(Close[1] > Open[1] ) and ( sPavilVenda <= 15 ) and ( sViolinadaVenda >= 30) and (Close[0] < Open[0]) then
    begin
      PaintBar(clBlue); // Pinta a barra de azul
      PlotText("P.V", clWhite); // Plota texto "P.V" em branco
      
      // Verifica se não há posição de compra ou venda aberta
      if (BuyPosition() = 0) and (SellPosition() = 0)  then
      begin      
        SellShortAtMarket(); // Abre uma posição de venda a descoberto
      end;               

      // Verifica se a posição de venda foi aberta
      if IsSold then
      begin
        gain_venda := low[1]; // Define o preço de ganho na venda
        loss_venda := high + 50; // Define o preço de perda na venda
        BuyToCoverLimit(gain_venda); // Define o limite de compra para o ganho
        BuyToCoverStop(loss_venda, loss_venda); // Define o stop loss na venda
      end;
    end;
  
    // Calcula sPavilCompra e sViolinadaCompra
    sPavilCompra := Close[1] - Low[1];
    sViolinadaCompra := Low[1] - Low[0];
    
    // Verifica se as condições para um padrão de compra em Pattern_2 foram atendidas
    if(Close[1] < Open[1] ) and ( sPavilCompra <= 15 ) and ( sViolinadaCompra >= 30) and (Close[0] > Open[0]) then
    begin
      PaintBar(clWhite); // Pinta a barra de branco
      PlotText("P.C", clWhite); // Plota texto "P.C" em branco

      // Verifica se não há posição de compra ou venda aberta
      if (BuyPosition() = 0) and (SellPosition() = 0)  then
      begin      
        BuyAtMarket(); // Abre uma posição de compra
      end;               

      // Verifica se a posição de compra foi aberta
      if IsBought then
      begin
        gain_compra := high[1]; // Define o preço de ganho na compra
        loss_compra := low - 50; // Define o preço de perda na compra
        SellToCoverLimit(gain_compra); // Define o limite de venda para o ganho
        SellToCoverStop(loss_compra, loss_compra); // Define o stop loss na compra
      end;
    end;
  end;
  
  // Verifica se uma posição de compra está aberta
  if IsBought then
  begin
    // Move o stop loss para o ponto de equilíbrio se o preço subir a partir do preço de compra
    if( Close >= BuyPrice + breakeven) then
    begin
      loss_compra := BuyPrice - 5; // Define o novo stop loss
      SellToCoverLimit(gain_compra); // Define o limite de venda para garantir o ganho
      SellToCoverStop(loss_compra, loss_compra); // Define o novo stop loss
    end;
  end;
   
  // Verifica se uma posição de venda está aberta
  if IsSold then
  begin
    // Move o stop loss para o ponto de equilíbrio se o preço cair a partir do preço de venda
    if( Close <= SellPrice - breakeven) then
    begin
      loss_venda := SellPrice + 5; // Define o novo stop loss
      BuyToCoverLimit(gain_venda); // Define o limite de compra para garantir o ganho
      BuyToCoverStop(loss_venda, loss_venda); // Define o novo stop loss
    end;
  end;      
end;
