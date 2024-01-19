module circuit(input clk, nrst, door, start, finish, output heat, light, bell);
  const logic [4:0] 
  CLOSED = 5'b00001, 
  COOK = 5'b00010, 
  PAUSE = 5'b00100, 
  BELL = 5'b01000, 
  OPEN = 5'b10000;
  logic [4:0] state;
  assign bell = state[3];
  assign heat = state[1];
  or (light, state[4], state[2], state[1]);
  always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) state <= CLOSED;
    else unique casez(state)
      /* z jakiegos powodu bardzo nie chce skorzystac z one hot jak jest tak napisne 
      CLOSED: state <= (door ? OPEN : (start ? COOK : CLOSED)); 
      COOK: state <= (door ? PAUSE : (finish ? BELL : COOK));
      PAUSE: state <= (!door ? COOK : PAUSE);
      BELL: state <= (door ? OPEN : BELL);
      OPEN: state <= (!door ? CLOSED : OPEN); */
      5'b????1: state <= (door ? OPEN : (start ? COOK : CLOSED)); 
      5'b???1?: state <= (door ? PAUSE : (finish ? BELL : COOK));
      5'b??1??: state <= (!door ? COOK : PAUSE);
      5'b?1???: state <= (door ? OPEN : BELL);
      5'b1????: state <= (!door ? CLOSED : OPEN);
      default : state <= state;
    endcase
  end
endmodule