module m41 (input a, b, c, d, s0, s1, output out); // mulitplexer 4:1
  assign out = s1 ? (s0 ? d : c) : (s0 ? b : a);
endmodule
module dff(output q, nq, input clk, d); // kod z wykładu
	logic r, s, nr, ns;
	nand gq(q, nr, nq), gnq(nq, ns, q),
	gr(nr, clk, r), gs(ns, nr, clk, s),
	gr1(r, nr, s), gs1(s, ns, d);
endmodule
// https://media.geeksforgeeks.org/wp-content/uploads/USR12.png 
//korzystałem z tego obrazka do implementacji
module shiftRegister(output [7:0]q, input[7:0]d, input i,c,l,r);
  logic [7:0] m;
  
  dff ff0(q[0], , c, m[0]);
  dff ff1(q[1], , c, m[1]);
  dff ff2(q[2], , c, m[2]);
  dff ff3(q[3], , c, m[3]);
  dff ff4(q[4], , c, m[4]);
  dff ff5(q[5], , c, m[5]);
  dff ff6(q[6], , c, m[6]);
  dff ff7(q[7], , c, m[7]);
  
  m41 mux0(q[0], q[1], i,    d[0], l, r, m[0]);
  m41 mux1(q[1], q[2], q[0], d[1], l, r, m[1]);
  m41 mux2(q[2], q[3], q[1], d[2], l, r, m[2]);
  m41 mux3(q[3], q[4], q[2], d[3], l, r, m[3]);
  m41 mux4(q[4], q[5], q[3], d[4], l, r, m[4]);
  m41 mux5(q[5], q[6], q[4], d[5], l, r, m[5]);
  m41 mux6(q[6], q[7], q[5], d[6], l, r, m[6]);
  m41 mux7(q[7], i,    q[6], d[7], l, r, m[7]);
endmodule