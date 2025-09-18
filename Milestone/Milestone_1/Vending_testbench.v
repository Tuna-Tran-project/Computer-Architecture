`timescale 1ns/1ps

module Vending_testbench;
    reg i_clk;
    reg i_nickle, i_dime, i_quarter;
    wire o_soda;
    wire [2:0] o_change;

    // Instantiate the Device Under Test (DUT)
    Vending_Machine uut (
        .i_clk(i_clk),
        .i_nickle(i_nickle),
        .i_dime(i_dime),
        .i_quarter(i_quarter),
        .o_soda(o_soda),
        .o_change(o_change)
    );

    // Clock generation: 10ns period
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    // Coin insertion task
    task insert_coin;
        input [2:0] coin; // [nickle, dime, quarter]
        begin
            {i_nickle, i_dime, i_quarter} = coin;
            #10;
            {i_nickle, i_dime, i_quarter} = 3'b000;
            #10;
        end
    endtask

    // Monitor outputs on every clock edge
    always @(posedge i_clk) begin
        if (o_soda)
            $display("[DISPENSE] o_soda=%b, o_change=%b at time %t", o_soda, o_change, $time);
        else if (i_nickle || i_dime || i_quarter)
            $display("[COIN] nickel=%b dime=%b quarter=%b deposit event at time %t", i_nickle, i_dime, i_quarter, $time);
    end

    initial begin
        // Initialize
        i_nickle = 0; i_dime = 0; i_quarter = 0;
        #10;

        $display("Test 1: Insert 4 nickels, 1 dime (¢30)");
        repeat(4) insert_coin(3'b100);
        insert_coin(3'b010);

        $display("Test 2: Insert 3 dimes (¢20)");
        repeat(3) insert_coin(3'b010);

        $display("Test 3: Insert a quarter (¢25)");
        insert_coin(3'b001);

        $display("Test 4: Insert dime, nickel, dime (¢25)");
        insert_coin(3'b010);
        insert_coin(3'b100);
        insert_coin(3'b010);

        $display("Test 5: Insert nickel, quarter (¢30)");
        insert_coin(3'b100);
        insert_coin(3'b001);

        $display("Simulation finished at %t", $time);
        #20;
        $stop;
    end
endmodule
