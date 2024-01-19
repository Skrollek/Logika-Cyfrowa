module dff(output q, nq, input clk, d, rst); // dff z restem asynchronicznym
  logic r, s, nr, ns;
  nand gq(q, nr, nq), gnq(nq, ns, q), gr(nr, clk, r, rst),
  gs(ns, nr, clk, s), gr1(r, nr, s), gs1(s, ns, d, rst);
endmodule

module tlatch(output q, nq, input c, t, nrst); // przerzutnik typu t z restem ansynchronicznym
  dff latch(q, nq, c, (!t & q) | (t & nq), nrst);
endmodule

module fourBitCounter(input clk, nrst, step, down, output[3:0] out);
  logic [3:1] z;
  assign z[1] = (out[0] ^ down) | step;
  assign z[2] = (out[1] ^ down) & z[1];
  assign z[3] = (out[2] ^ down) & z[2];
  tlatch latch1(out[0], , clk, !step, nrst);
  tlatch latch2(out[1], , clk, z[1] , nrst);
  tlatch latch3(out[2], , clk, z[2] , nrst);
  tlatch latch4(out[3], , clk, z[3] , nrst);
endmodule