module counter (
    input  logic clk,
    input  logic reset,
    output logic [3:0] count
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1;
    end

    assert property (@(posedge clk) disable iff (reset)
                     count == $past(count) + 1)
        else $fatal("Counter did not increment by 1 at time %0t.", $time);

    assert property (@(posedge clk) disable iff (reset)
                     count < 16)
        else $fatal("Counter overflow detected at time %0t.", $time);

endmodule


module tb_counter;

    logic clk;
    logic reset;
    logic [3:0] count;

    counter uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 0;

        reset = 1;
        #10 reset = 0;

        #100;

        $stop;
    end

    initial begin
        $monitor("Time = %0t, clk = %b, reset = %b, count = %d",
                  $time, clk, reset, count);
    end

endmodule