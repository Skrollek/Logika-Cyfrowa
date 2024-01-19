module circuit(input clk, input[15:0] d, input [1:0] sel, output logic [15:0] cnt, cmp, top, output logic out);
  logic [15:0] counter, comp, up;
  assign cnt = counter;
  assign cmp = comp;
  assign up  = top;
  assign out = !(counter >= comp);
  always_ff @(posedge clk) begin
    if(sel[0] & !sel[1])
      comp <= d;
    if(!sel[0] & sel[1])
      top <= d;
    if(sel[0] & sel[1])
      counter <= d;
    else if (counter >= up)
      counter <= 0;
    else
      counter <= counter + 1;
  end
endmodule