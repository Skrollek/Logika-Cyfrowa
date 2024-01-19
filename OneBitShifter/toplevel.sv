// Write your modules here!
module onebitShifter(input l, r, input [3:0] i, output [3:0]o);
  assign o[0] = (~l & ~r & i[0]) | (r & i[1]);
  assign o[2:1] = (i[3:2] & {2{r}}) | (i[1:0] & {2{l}}) | (i[2:1] & {2{~(l^r)}});
  assign o[3] =  (~l & ~r & i[3]) | (l & i[2]);
endmodule