module ram(input write, clk,
           input [9:0] addr,
           input [15:0] d, 
           output logic [15:0] val);
  logic [15:0] m [0:1023];
  assign val = m[addr];
  always_ff @(posedge clk)
    if (write) m[addr] <= d;
endmodule


module calc(input nrst, clk, push, en,
            input [2:0] op, 
            input [15:0] d, 
            output logic [15:0] out);
  
  logic [9:0]  cnt, cnt1;
  logic [15:0] tmp;
  logic [9:0]  mAddr;
  logic write;
  
  ram dt(write, clk, mAddr, out, tmp);
  
  assign cnt1 = cnt - 1;
  
  always_comb begin
    if(push) begin mAddr = cnt;
    end else if(op == 5) mAddr = cnt1 - out;
    else mAddr = cnt1;
  end
  
  assign write = en & (push | (op == 4));
  
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin out <= 0;
    end else if (en) begin
      if(push) out <= d;
      else case (op)
        3'd0 : out <= ((out > 0) && (out[15] == 0)); // czemu po prostu out > 0 nie działa
        3'd1 : out <= -out;
        3'd2 : out <= out + tmp;
        3'd3 : out <= out * tmp;
        default: out <= tmp;
      endcase
    end
  end
  
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) cnt <= 0;
    else if(en) begin
      if(push) cnt <= cnt + 1;
      else if((cnt > 0) && (op == 2 | 
                            op == 3 | 
                            op == 6 |
                            op == 7) ) cnt <= cnt - 1; 
      // da się też ten warunek zapisać jako (op > 1 & op != 4 & op != 5 & cnt > 0) 
      // ale ta wersja wydaje mi się mniej czytelna
    end
  end
  
endmodule

module ctrl(input clk, nrst, wr, start,
            input [9:0] addr,
            input [15:0] datain,
            output ready,
            output [15:0] out);
  
  const logic [1:0]
  RDY = 2'b10,
  BSY = 2'b00;
  
  logic write, en, push, loadNumber, loadOpcode;
  logic [1:0] s;
  logic [2:0] op;
  logic [9:0] pc, mAddr;
  logic [15:0] mData, d;
  
  assign ready = s[1];
  
  ram p(write, clk, mAddr, datain, mData);
  
  always_ff @(posedge clk, negedge nrst)
    if(!nrst)
      s <= RDY;
    else unique casez(s)
      RDY : if(start) begin
        	s <= BSY;
        	pc <= 10'd0;
      		end
      BSY : if(loadNumber) pc <= pc + 1;
      		else if (loadOpcode) begin
        		if(jump) pc <= out;
        		else pc <= pc + 1;
      		end else s <= RDY;
    endcase
  
  assign write = (s == RDY) & (!start & wr);
  
  always_comb
    unique casez(s)
      RDY: mAddr = addr;
      BSY: mAddr = pc;
      default: mAddr = pc;
    endcase
  
  assign op = mData[2:0];
  assign d = {1'd0, mData[14:0]};
  assign loadNumber = !mData[15];
  assign loadOpcode = !mData[14];
  assign jump = (op == 7);
  
  assign en   = (s == BSY) & (loadNumber | loadOpcode);
  assign push = (s == BSY) &  loadNumber;
  
  calc c(nrst, clk, push, en, op, d, out);
  
endmodule