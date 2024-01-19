module controlPath (input eq, bGTa, nrst, start, clk,
                    output logic load, swp, rdy);
  logic r;
  assign rdy  = r;
  assign swp  = (!r & bGTa) | eq;
  assign load = r & start;
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin
      r <= 1;
    end else if (r & start) begin
      r <= 0;
    end else if (!r & eq) begin
      r <= 1;
    end else begin
      r <= r;
    end
  end
endmodule

module dataPath(input swp, rdy, load, clk,
                input [7:0] ina, inb,
                output[7:0] out, 
                output eq, bGTa);
  logic [7:0] a;
  logic [7:0] b;
  assign out = a;
  assign eq = (a == b) | rdy;
  assign bGTa = (a < b) & !rdy;
  always_ff @(posedge clk) begin
    if(load & rdy) begin
      a <= ina;
      b <= inb;
    end else if (swp & !rdy) begin //
      a <= b;
      b <= a;
    end else if (!swp & !rdy) begin
      a <= a - b;
      b <= b;
    end else begin
      a <= a;
      b <= b;
    end
  end
endmodule

module toplevel(input clk, nrst, start,
                input [7:0] ina, inb,
                output ready,
                output [7:0] out);
  logic eq, bGTa, load, swp;
  dataPath dt(swp, ready, load, clk, ina, inb, out, eq, bGTa);
  controlPath ctrl(eq, bGTa, nrst, start, clk, load, swp, ready);
endmodule 