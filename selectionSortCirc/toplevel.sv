module ram (input wr, clk,
            input [2:0] addrW, addrR,
  			input [7:0] datain, 
			output logic [7:0] dataout);
  logic [7:0] mem [0:7];

  always_ff @(posedge clk) begin
    if (wr)  mem[addrW] <= datain; 
  end
  always_ff @(posedge clk) begin
    dataout <= mem[addrR];
  end
endmodule

module controlPath(input start, wr, iEQseven, cSTm, jEQseven, iEQjm, clk, nrst,
                   output logic rdy, w, stOuter, stInner, newMin, stepInner, stepOuter, // wydawanie poleceń
                   output zero, addrSel, i1, i0, j1, jm // te dane mówią jaki należy wybrać adres odczytu/zapisu
                   );
  const logic [3:0] 
  ready = 4'b0001,
  outer = 4'b0010,
  inner = 4'b0100,
  e     = 4'b1000,
  swp   = 4'b0000;
  logic [3:0] state;
  
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin
      state <= ready;
    end else unique casez(state)
      ready: begin if(start) state <= outer;
        		   else state <= ready;
      end
      outer: begin if(iEQseven) state <= ready;
                   else state <= inner;
      end
      inner: begin if(!cSTm & jEQseven) state <= e;
                   else state <= inner;
      end
      e:     begin if(iEQjm) state <= outer;
                   else state <= swp;
      end
      swp:   begin state <= outer;
      end
    endcase
  end
  assign rdy = state[0],
  w = (wr & state[0] & !start) | (state[3] & !iEQjm) | (state == swp), // b
  stOuter = start & state[0],
  stInner = !iEQseven & state[1],
  newMin = cSTm & state[2],
  stepInner = !cSTm & !jEQseven & state[2],
  stepOuter = iEQjm & state[3] | (state == 0),
  zero = state[0] & start, // odczyt
  addrSel = state[0] & !start, // zapis odczyt
  i1 = (state[1]) | (state[3] & iEQjm) | (state == 0), // odczyt
  i0 = (state[2] & !cSTm &  jEQseven) | (state == swp), // zapis
  j1 = (state[2] & !cSTm & !jEQseven), // odczyt
  jm = (state[3] & !iEQjm); // zapis
endmodule

module dataPath(input rdy, wr, stOuter, stInner, newMin, stepInner, stepOuter, clk, 
                input zero,  i1, j1, // adresy odczytu
                i0, jma, addrSel, // adresy zapisu
                input [2:0] addr,
                input  [7:0] datain,
                output [7:0] dataout,
                output ready, iEQseven, cSTm, jEQseven, iEQjm);
  
  logic [2:0] i,j,jm, adw, adr;
  logic [7:0] c,m, dt;
  assign ready = rdy;
  assign iEQseven = (i == 7);
  assign cSTm = c < m;
  assign jEQseven = (j == 7);
  assign iEQjm = (i == jm);
  ram data(wr, clk, adw, adr, dt, dataout);
  
  // wybór odpowiednich adresów
  always_comb begin
    if(i0) adw = i;
    else if (jma) adw = jm;
    else if (addrSel) adw = addr;
    else adw = 0;
  end
  
  always_comb begin
    if (zero) adr = 0;
    else if (i1) adr = i + 1;
    else if (j1) adr = j + 1;
    else if (jma) adr = jm;
    else if (addrSel) adr = addr;
    else adr = i;
  end
  
  // wybór odpwiednich danych wejściowych
  always_comb begin
    if(i0) dt = m;
    else if (jma) dt = c;
    else if (addrSel) dt = datain;
    else dt = dataout;
  end
 
  assign c = dataout;
  
  always_ff @(posedge clk) begin
    if (stOuter) begin
      i <= 3'd0;
    end else if(stInner) begin
      j <= i + 1;
      jm <= i;
      m <= c;
    end else if(newMin) begin
      m <= c;
      jm <= j;
    end else if(stepInner) begin
      j <= j + 1;
    end else if(stepOuter) begin
      i <= i + 1;
    end
  end
endmodule

module toplevel(input clk, nrst, start, wr,
                input [2:0] addr, 
                input [7:0] datain,
                output [7:0] dataout, 
                output ready);
  logic rdy, w, stOuter, stInner, newMin, stepInner, stepOuter,
               zero, i1, i0, j1, jm;
  logic addrSel;
  
  logic iEQseven, cSTm, jEQseven, iEQjm;
  
  dataPath data(rdy, w, stOuter, stInner, newMin, stepInner, stepOuter, clk,
              zero, i1 , j1, i0, jm, addrSel, addr, datain, dataout, ready, iEQseven, cSTm, jEQseven, iEQjm);
  
  controlPath ctrl(start, wr, iEQseven, cSTm, jEQseven, iEQjm, clk, nrst,
                  rdy, w, stOuter, stInner, newMin, stepInner, stepOuter,
                   zero, addrSel, i1, i0, j1, jm);
  
endmodule