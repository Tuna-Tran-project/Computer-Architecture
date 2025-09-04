module Vending_FSM (
    input wire i_clk,
    input wire i_nickle,    // 5¢ coin
    input wire i_dime,      // 10¢ coin
    input wire i_quarter,   // 25¢ coin
    output reg o_soda,      // Dispense soda (pulse for one clock when dispensing)
    output reg [2:0] o_change // Change as 3-bit data (pulse for one clock when dispensing)
);

// State encoding: representing deposit value
localparam [2:0]
    S0 = 3'b000, // 0¢
    S1 = 3'b001, // 5¢
    S2 = 3'b010, // 10¢
    S3 = 3'b011, // 15¢
    S4 = 3'b100, // 20¢ (wait for more coin)
    S5 = 3'b101; //Dispense

reg [2:0] state, next_state;

// Combinational next state logic
always @(*) begin
    next_state = state;
    case (state)
        S0: begin
            if (i_nickle)      next_state = S1;
            else if (i_dime)   next_state = S2;
            else if (i_quarter)next_state = S3;
        end
        S1: begin
            if (i_nickle)      next_state = S2;
            else if (i_dime)   next_state = S3;
            else if (i_quarter)next_state = S4;
        end
        S2: begin
            if (i_nickle)      next_state = S3;
            else if (i_dime)   next_state = S4;
            else if (i_quarter)next_state = S4;
        end
        S3: begin
            if (i_nickle)      next_state = S4; // 15+5=20, go to S4 (wait for next coin)
            else if (i_dime || i_quarter) next_state = S0; // Dispense and reset
        end
        S4: begin
            if (i_nickle || i_dime || i_quarter)
                next_state = S5; // Dispense then reset
        end
        S5: begin
                next_state = S0; // Dispense then reset
        end        
        default: next_state = S0;
    endcase
end

// Output logic: pulse on dispense, calculate change
always @(*) begin
    // Default values
    o_soda = 1'b0;
    o_change = 3'b000;

    case (state)
        S0: if (i_quarter) begin // 25¢ inserted
                o_soda = 1'b1;
                o_change = 3'b001; // 25-20=5
            end
        S1: if (i_quarter) begin // 5¢ + 25¢ = 30¢
                o_soda = 1'b1;
                o_change = 3'b010; // 30-20=10
            end
        S2: begin
            if (i_quarter) begin // 10¢ + 25¢ = 35¢
                o_soda = 1'b1;
                o_change = 3'b011; // 35-20=15
            end
        end
        S3: begin
            if (i_dime) begin // 15¢ + 10¢ = 25¢
                o_soda = 1'b1;
                o_change = 3'b001; // 25-20=5
            end else if (i_quarter) begin // 15¢ + 25¢ = 40¢
                o_soda = 1'b1;
                o_change = 3'b100; // 40-20=20
            end
        end
        S5: begin
            if (i_nickle) begin
                o_soda = 1'b1;
                o_change = 3'b000; // 20¢ + 5¢ = 25¢, change=5
            end else if (i_dime) begin
                o_soda = 1'b1;
                o_change = 3'b010; // 20¢ + 10¢ = 30¢, change=10
            end else if (i_quarter) begin
                o_soda = 1'b1;
                o_change = 3'b010; // 20¢ + 25¢ = 45¢, change=25
            end
        end
        default: begin
            o_soda = 1'b0;
            o_change = 3'b000;
        end
    endcase
end

// State register
always @(posedge i_clk) begin
    state <= next_state;
end

endmodule