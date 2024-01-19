module ram(input [15:0] d, input [9:0] waddr, raddr, input write, step, 
           output logic [15:0] val);
  integer i;
  logic [15:0] m [0:1023];
  initial
    for(i = 0; i < 1024; i = i + 1)
      m[i] = 0;
  assign val = m[raddr];
  always_ff @(posedge step)
    if (write) m[waddr] <= d;
endmodule


module calc(input nrst, step, push, input [1:0] op, input [15:0] d, 
            output logic [15:0] out, output logic [9:0] cnt);
  logic [15:0] tmp;
  
  ram mem(out, cnt-1, cnt-2, push, step, tmp);
  
  always_ff @(posedge step, negedge nrst) begin
    if(!nrst) begin
      cnt <= 0;
      out <= 0;
    end else if(push) begin
      out <= d;
      cnt <= cnt + 1;
    end else case (op)
      2'd1 : begin out <= -out; end
      2'd2 : begin out <= out + tmp;
        		   if (cnt != 0) cnt <= cnt - 1; 
      		 end
      2'd3 : begin out <= out * tmp;
        		   if (cnt != 0) cnt <= cnt - 1; 
      		 end
      default : cnt <= cnt;
    endcase
  end
endmodule