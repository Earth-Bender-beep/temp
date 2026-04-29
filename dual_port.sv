module dual_port_ram(clk, rst, wr_addr, rd_addr, we, re, din, dout);

    input clk, rst, we, re;
    input [3:0] wr_addr, rd_addr;
    input [7:0] din;
    output reg [7:0] dout;

    reg [7:0] mem [15:0];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            dout <= 0;
            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 0;
        end
        else begin
            if (we)
                mem[wr_addr] <= din;
            if (re)
                dout <= mem[rd_addr];
        end
    end

endmodule


module dual_port_ram_tb();

    reg clk, rst, we, re;
    reg [7:0] din;
    reg [3:0] wr_addr, rd_addr;
    wire [7:0] dout;
    integer i, j;

    dual_port_ram dut(clk, rst, wr_addr, rd_addr, we, re, din, dout);

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task initialize;
    begin
        din = 8'd0;
        {rd_addr, wr_addr} = 8'd0;
        {rst, we, re} = 3'b100;
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
        din = m;
        wr_addr = n;
        we = o;
    end
    endtask

    task read(input [3:0] p, input q);
    begin
        @(negedge clk)
        rd_addr = p;
        re = q;
    end
    endtask

    initial begin
        initialize;
        reset;
        #10;

        for (i = 0; i < 16; i = i + 1)
            write({$random}, i, 1'b1);

        #10;

        for (j = 0; j < 16; j = j + 1)
            read(j, 1'b1);

        #700 $finish;
    end

    initial
        $monitor("din=%b,dout=%b,we=%b,re=%b,wr_addr=%b,rd_addr=%b",
                  din, dout, we, re, wr_addr, rd_addr);

endmodule