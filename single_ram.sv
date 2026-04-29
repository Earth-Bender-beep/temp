module single_port_ram (
    input clk,
    input rst,
    input en,
    input [3:0] addr,
    input [7:0] data_in,
    output reg [7:0] data_out
);

    reg [7:0] mem [15:0];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            data_out <= 8'd0;
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= 8'd0;
            end
        end
        else begin
            if (en) begin
                mem[addr] <= data_in;
            end
            else begin
                data_out <= mem[addr];
            end
        end
    end

endmodule


module single_port_ram_tb();

    reg clk, rst, en;
    reg [7:0] data_in;
    reg [3:0] addr;
    wire [7:0] data_out;

    integer i, j;

    single_port_ram dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task initialize;
    begin
        data_in = 8'd0;
        addr    = 4'd0;
        {rst, en} = 2'b10;
    end
    endtask

    task reset;
    begin
        @(negedge clk)
        rst = 1'b1;

        @(negedge clk)
        rst = 1'b0;
    end
    endtask

    task write(input [7:0] m, input [3:0] n, input o);
    begin
        @(negedge clk)
        data_in = m;
        addr    = n;
        en      = o;
    end
    endtask

    initial begin
        initialize;
        reset;

        #10;

        for (i = 0; i < 16; i = i + 1) begin
            write($random, i, 1'b1);
        end

        for (j = 0; j < 16; j = j + 1) begin
            write(8'd0, j, 1'b0);
        end

        $monitor("rst=%b addr=%d en=%b data_in=%d data_out=%d",
                  rst, addr, en, data_in, data_out);

        #50 $finish;
    end

endmodule