class myPacket;

    bit [2:0] header;
    bit encode;
    bit [2:0] mode;
    bit [7:0] data;
    bit stop;

    function new (bit [2:0] header = 3'h1, bit [2:0] mode = 3'h5);
        this.header = header;
        this.encode = 0;
        this.mode   = mode;
        this.data   = 8'h00;
        this.stop   = 1;
    endfunction

    function void display();
        $display("Header = 0x%0h, Encode = %0b, Mode = 0x%0h, Data = 0x%0h, Stop = %0b",
                  this.header, this.encode, this.mode, this.data, this.stop);
    endfunction

endclass


module tb_top;

    myPacket pkt0, pkt1;

    initial begin
        $display("==== Packet 0 ====");
        pkt0 = new(3'h2, 3'h3);
        pkt0.display();

        $display("==== Packet 1 ====");
        pkt1 = new();
        pkt1.display();

        $finish;
    end

endmodule



class Packet;

    bit [31:0] addr;

    function new (bit [31:0] addr = 32'h0000_0000);
        this.addr = addr;
    endfunction

    function void display();
        $display("BaseClass: Address = 0x%0h", this.addr);
    endfunction

endclass


class ExtPacket extends Packet;

    bit [31:0] data;

    function new (bit [31:0] addr = 32'h0000_0000,
                  bit [31:0] data = 32'hDEAD_BEEF);
        super.new(addr);
        this.data = data;
    endfunction

    function void display();
        $display("SubClass: Address = 0x%0h, Data = 0x%0h",
                  this.addr, this.data);
    endfunction

endclass


module tb;

    Packet bc;
    ExtPacket sc;

    initial begin
        sc = new(32'hfeed_feed, 32'h1234_5678);

        bc = sc;

        bc.display();
        sc.display();
    end

endmodule