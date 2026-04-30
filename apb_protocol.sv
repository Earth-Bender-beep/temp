module apb_fsm_slave (
    input        PCLK,
    input        PRESETn,
    input        PSEL,
    input        PENABLE,
    input        PWRITE,
    input  [7:0] PADDR,
    input  [31:0] PWDATA,
    output reg [31:0] PRDATA,
    output reg        PREADY
);

    localparam IDLE   = 2'b00,
               SETUP  = 2'b01,
               ACCESS = 2'b10;

    reg [1:0] state, next_state;
    reg [31:0] mem [0:255];

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE:    next_state = PSEL ? SETUP : IDLE;
            SETUP:   next_state = PENABLE ? ACCESS : SETUP;
            ACCESS:  next_state = PSEL ? SETUP : IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 0;
            PREADY <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    PREADY <= 0;
                end

                SETUP: begin
                    PREADY <= 0;
                end

                ACCESS: begin
                    PREADY <= 1;

                    if (PWRITE) begin
                        mem[PADDR] <= PWDATA;
                    end
                    else begin
                        PRDATA <= mem[PADDR];
                    end
                end

                default: begin
                    PREADY <= 0;
                end
            endcase
        end
    end

endmodule



module apb_fsm_slave_tb;

    reg         PCLK;
    reg         PRESETn;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [7:0]  PADDR;
    reg  [31:0] PWDATA;

    wire [31:0] PRDATA;
    wire        PREADY;

    apb_fsm_slave dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    initial PCLK = 0;
    always #5 PCLK = ~PCLK;


    task apb_write(input [7:0] addr, input [31:0] data);
    begin
        @(posedge PCLK);
        PSEL    = 1;
        PENABLE = 0;
        PWRITE  = 1;
        PADDR   = addr;
        PWDATA  = data;

        @(posedge PCLK);
        PENABLE = 1;

        wait (PREADY);

        @(posedge PCLK);

        PSEL    = 0;
        PENABLE = 0;

        @(posedge PCLK);
    end
    endtask


    task apb_read(input [7:0] addr, output [31:0] data);
    begin
        @(posedge PCLK);
        PSEL    = 1;
        PENABLE = 0;
        PWRITE  = 0;
        PADDR   = addr;

        @(posedge PCLK);
        PENABLE = 1;

        wait (PREADY);

        @(posedge PCLK);
        data = PRDATA;

        PSEL    = 0;
        PENABLE = 0;
    end
    endtask


    reg [31:0] rdata;

    initial begin
        $dumpfile("apb_test.vcd");
        $dumpvars(0, apb_fsm_slave_tb);

        PRESETn = 0;
        #15;
        PRESETn = 1;

        apb_write(8'h10, 32'hA5A5A5A5);
        apb_read(8'h10, rdata);
        $display("Test 1 - Addr: 0x10, Expected: 0xA5A5A5A5, Got: 0x%h", rdata);

        apb_write(8'h20, 32'h12345678);
        apb_read(8'h20, rdata);
        $display("Test 2 - Addr: 0x20, Expected: 0x12345678, Got: 0x%h", rdata);

        apb_write(8'hFF, 32'hDEADBEEF);
        apb_read(8'hFF, rdata);
        $display("Test 3 - Addr: 0xFF, Expected: 0xDEADBEEF, Got: 0x%h", rdata);

        apb_write(8'h01, 32'h00000001);
        apb_read(8'h01, rdata);
        $display("Test 4 - Addr: 0x01, Expected: 0x00000001, Got: 0x%h", rdata);

        apb_write(8'h02, 32'h87654321);
        apb_read(8'h02, rdata);
        $display("Test 5 - Addr: 0x02, Expected: 0x87654321, Got: 0x%h", rdata);

        apb_write(8'h80, 32'hCAFEBABE);
        apb_read(8'h80, rdata);
        $display("Test 6 - Addr: 0x80, Expected: 0xCAFEBABE, Got: 0x%h", rdata);

        apb_write(8'h55, 32'hFACEB00C);
        apb_read(8'h55, rdata);
        $display("Test 7 - Addr: 0x55, Expected: 0xFACEB00C, Got: 0x%h", rdata);

        $finish;
    end

endmodule