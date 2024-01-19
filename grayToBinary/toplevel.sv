// z zalet tego programu moge wymienic ze latwo go sparametryzowac
module g2b(input[31:0] i, output logic [31:0] o);
  integer k;
  logic [31:0] prev,curr;
  always_comb begin
    prev = i;
    for(k = 0; k <= 4; k = k + 1) begin
      curr = prev ^ (prev >> 2**k);
      prev = curr;
    end
    o = curr;
  end
endmodule