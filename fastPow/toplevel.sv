
module circuit(input clk, nrst, start, 
               input [15:0] inx, input [7:0] inn,
               output logic ready, output [15:0] out);
  logic [7:0] n;
  logic [15:0] a;
  logic [15:0] x;
  assign out = a;
  
  logic [15:0] in;
  logic [15:0] o = x * in;
  
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin
      ready <= 1;
    end else if(start & ready) begin
      ready <= 0;
    end else if (n == 0) begin
      ready <= 1;
    end else begin
      ready <= ready;
    end
  end
  
  always_ff @(posedge clk) begin
    if(start & ready) begin
      a <= 16'd1;
    end else if(!ready & (n[0] & 1) & !(n == 0)) begin
      a <= o;
    end else begin
      a <= a;
    end
  end
  
  always_ff @(posedge clk) begin
    if(start & ready) begin
      x <= inx;
    end else if(!ready & !(n[0] & 1) & !(n == 0)) begin
      x <= o;
    end else begin
      x <= x;
    end
  end
  
  always_ff @(posedge clk) begin
    if(start & ready) begin
      n <= inn;
    end else if(!ready & (n[0] & 1) & !(n == 0)) begin
      n <= n - 1;
    end else begin
      n <= n >> 1; // bo 0 / 2 = 0
    end
  end
  
  always_comb begin
    if (!ready & (n[0] & 1) & !(n == 0)) begin 
      in = a;
    end else if (!ready & !(n[0] & 1) & !(n == 0)) begin
      in = x;
    end else
      in = 1;
  end
endmodule