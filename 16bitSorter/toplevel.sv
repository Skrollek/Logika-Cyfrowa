module sortingNetwork(input [15:0]i, output [15:0]o);
  logic [15:0]p1,p2;
  always_comb begin
    
    case(i[15:12] < i[7:4])
      1'b1: { p1[7:4], p1[15:12] } = { i[15:12], i[7:4]};
      default: { p1[7:4], p1[15:12] } = { i[7:4], i[15:12]};
    endcase
    
    case(i[11:8] < i[3:0])
      1'b1: { p1[3:0], p1[11:8] } = { i[11:8], i[3:0]};
      default: { p1[3:0], p1[11:8] } = { i[3:0], i[11:8]};
    endcase
    
    case(p1[15:12] < p1[11:8])
      1'b1: { p2[11:8], p2[15:12] } = { p1[15:12], p1[11:8]};
      default: { p2[11:8], p2[15:12] } = { p1[11:8], p1[15:12]};
    endcase
    
    case(p1[7:4] < p1[3:0])
      1'b1: { p2[3:0], p2[7:4] } = { p1[7:4], p1[3:0]};
      default: { p2[3:0], p2[7:4] } = { p1[3:0], p1[7:4]};
    endcase
    
    o[15:12] = p2[15:12];
    case(p2[11:8] < p2[7:4])
      1'b1: { o[7:4], o[11:8] } = { p2[11:8], p2[7:4]};
      default: { o[7:4], o[11:8] } = { p2[7:4], p2[11:8]};
    endcase
    o[3:0] = p2[3:0];
      
  end
endmodule