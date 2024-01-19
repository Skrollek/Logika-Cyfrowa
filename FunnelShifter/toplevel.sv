module conShifter(input[7:0]a, b, input[3:0]n, output[7:0]o);
  logic[15:0] p = ({a , b} >> n);
  assign o = p[7:0];
endmodule

module funnelShifter(input[7:0] i, input[3:0] n, input ar, lr, rot, output[7:0] o);
  logic[7:0]a,b;
  assign a = rot? (i) : (lr ? (i) : (ar ? ({8{i[7]}}) : ((8'd0))));
  assign b = rot? (i) : (lr ? (8'd0) : (i) );
  logic [3:0]npom = (lr ? (4'd8-n) : (n) );
  conShifter conShifter(a,b,npom,o);
endmodule