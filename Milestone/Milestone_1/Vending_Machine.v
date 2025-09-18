module Vending_Machine (
    // Clock and reset
    input  wire       i_clk,
    
    // Coin inputs (active high for one clock cycle)
    input  wire       i_nickle,    // 5¢ coin input
    input  wire       i_dime,      // 10¢ coin input  
    input  wire       i_quarter,   // 25¢ coin input
    
    // Outputs (active high for one clock cycle when dispensing)
    output reg        o_soda,      // Soda dispense signal
    output reg  [2:0] o_change     // Change amount (in 5¢ units)
);

    // Coin values in cents
    localparam NICKLE_VALUE  = 5;
    localparam DIME_VALUE    = 10;
    localparam QUARTER_VALUE = 25;
    localparam SODA_COST     = 20;
    
    // State encoding (represents accumulated money in cents)
    localparam [2:0] 
        STATE_0_CENTS  = 3'b000,    // 0¢ deposited
        STATE_5_CENTS  = 3'b001,    // 5¢ deposited
        STATE_10_CENTS = 3'b010,    // 10¢ deposited
        STATE_15_CENTS = 3'b011,    // 15¢ deposited
        STATE_DISPENSE = 3'b100;    // Dispensing state

    reg [2:0] current_state, next_state;
    reg [4:0] stored_total;  // ADDED: Store total value when dispensing
    
    // Helper signals
    wire coin_inserted;
    wire [4:0] current_value;  // Current accumulated value
    wire [4:0] total_value;    // Current value + new coin
    
    // Detect any coin insertion
    assign coin_inserted = i_nickle | i_dime | i_quarter;
    
    // Assign current_value from state
    assign current_value = current_state * 5;
    
    // Calculate total_value combinationally
    assign total_value = current_value + 
                        (i_nickle  ? NICKLE_VALUE  : 0) +
                        (i_dime    ? DIME_VALUE    : 0) +
                        (i_quarter ? QUARTER_VALUE : 0);

    // FSM Next State Logic
    always @(*) begin
        next_state = current_state;  // Default: stay in current state
        
        case (current_state)
            STATE_0_CENTS, STATE_5_CENTS, STATE_10_CENTS, STATE_15_CENTS: begin
                if (coin_inserted) begin
                    if (total_value >= SODA_COST) begin
                        // Enough money: go to dispense state
                        next_state = STATE_DISPENSE;
                    end else begin
                        // Not enough money: advance to next accumulation state
                        case (total_value)
                            5:  next_state = STATE_5_CENTS;
                            10: next_state = STATE_10_CENTS;
                            15: next_state = STATE_15_CENTS;
                            default: next_state = STATE_0_CENTS;  // Safety
                        endcase
                    end
                end
            end
            
            STATE_DISPENSE: begin
                // After dispensing, return to 0 cents
                next_state = STATE_0_CENTS;
            end
            
            default: begin
                next_state = STATE_0_CENTS;  // Safety
            end
        endcase
    end

    // FIXED: Store total value when transitioning to dispense state
    always @(posedge i_clk) begin
        if (next_state == STATE_DISPENSE && current_state != STATE_DISPENSE) begin
            // Store the total value when we're about to dispense
            stored_total <= total_value;
        end
    end

    // Output Logic
    always @(posedge i_clk) begin
        // Generate outputs when in dispense state
        if (current_state == STATE_DISPENSE) begin
            o_soda   <= 1'b1;
            o_change <= (stored_total - SODA_COST) / 5; // Use stored value!
        end else begin
            // Default outputs
            o_soda   <= 1'b0;
            o_change <= 3'b000;
        end
    end

    // State Register
    always @(posedge i_clk) begin
        current_state <= next_state;
    end

endmodule
