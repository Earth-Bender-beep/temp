module async_fifo(
    input wclk, rclk, reset,
    input w_enable, r_enable,
    input [7:0] wdata,
    output reg [7:0] rdata,
    output full_flag, empty_flag
);

    parameter FIFO_DEPTH = 16, POINTER = 4;

    reg [7:0] fifo [0:FIFO_DEPTH-1];
    reg [POINTER:0] wpointer, rpointer, wpointer_sync, rpointer_sync, Qr, Qw;

    assign full_flag  = (({~wpointer[POINTER], wpointer[POINTER-1:0]} == rpointer_sync[POINTER:0])) ? 1 : 0;
    assign empty_flag = (wpointer_sync == rpointer) ? 1 : 0;

    always @(posedge wclk, posedge reset) begin
        if (reset == 1) begin
            wpointer <= 0;
        end
        else begin
            if (w_enable == 1 && full_flag != 1) begin
                fifo[wpointer[POINTER-1:0]] <= wdata;
                wpointer <= wpointer + 1;
            end
        end
    end

    always @(posedge rclk, posedge reset) begin
        if (reset == 1) begin
            rpointer <= 0;
        end
        else begin
            if (r_enable == 1 && empty_flag != 1) begin
                rdata <= fifo[rpointer[POINTER-1:0]];
                rpointer <= rpointer + 1;
            end
        end
    end

    always @(posedge rclk, posedge reset) begin
        if (reset == 1) begin
            Qw <= 0;
            wpointer_sync <= 0;
        end
        else begin
            Qw <= wpointer;
            wpointer_sync <= Qw;
        end
    end

    always @(posedge wclk, posedge reset) begin
        if (reset == 1) begin
            Qr <= 0;
            rpointer_sync <= 0;
        end
        else begin
            Qr <= rpointer;
            rpointer_sync <= Qr;
        end
    end

endmodule



module async_fifo_tb;

    parameter FIFO_DEPTH = 16, POINTER = 4;

    reg wclk_t, rclk_t, reset_t;
    reg wenable_t, renable_t;
    reg [7:0] wdata_t, data_in;
    wire [7:0] rdata_t;
    wire full_flag_t, empty_flag_t;

    integer count;

    async_fifo #(FIFO_DEPTH, POINTER) async_inst (
        wclk_t,
        rclk_t,
        reset_t,
        wenable_t,
        renable_t,
        wdata_t,
        rdata_t,
        full_flag_t,
        empty_flag_t
    );


    task write_task;
        input [7:0] data_in;
        begin
            @(posedge wclk_t);
            if (!full_flag_t) begin
                wenable_t = 1;
                wdata_t = data_in;
                @(posedge wclk_t);
                wenable_t = 0;
            end
        end
    endtask


    task read_task;
        begin
            @(posedge rclk_t);
            if (!empty_flag_t) begin
                renable_t = 1;
                @(posedge rclk_t);
                renable_t = 0;
            end
        end
    endtask


    task single_wr_rd_test();
        begin
            data_in = $random;
            write_task(data_in);
            read_task();
        end
    endtask


    task all_wr_rd_test();
        for (count = 0; count < FIFO_DEPTH; count = count + 1) begin
            data_in = $random;
            write_task(data_in);
            read_task();
        end
    endtask


    task fifo_full_empty_test();
        begin
            for (count = 0; count < FIFO_DEPTH + 1; count = count + 1) begin
                data_in = $random;
                write_task(data_in);
            end

            for (count = 0; count < FIFO_DEPTH + 1; count = count + 1) begin
                read_task();
            end
        end
    endtask


    always begin
        #5 wclk_t = ~wclk_t;
    end


    always begin
        #5 rclk_t = ~rclk_t;
    end


    initial begin
        wclk_t = 0;
        rclk_t = 0;
        reset_t = 1;

        #15 reset_t = 0;

        @(posedge wclk_t);

        single_wr_rd_test();
        all_wr_rd_test();
        fifo_full_empty_test();

        #100 $finish;
    end

endmodule