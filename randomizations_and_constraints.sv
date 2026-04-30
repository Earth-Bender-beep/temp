
// ==========================
// INLINE CONSTRAINT EXAMPLE
// ==========================
class Item;

    rand bit [7:0] id;

    constraint c_id { id < 25; }

endclass


module tb_inline;

    initial begin
        Item itm = new();

        itm.randomize() with { id == 10; };

        $display("Item Id = %0d", itm.id);
    end

endmodule



// ==========================
// RANDOM DISTRIBUTION EXAMPLE
// ==========================
class ABC_basic;

    rand bit [2:0] b;

endclass


module tb_basic;

    initial begin
        ABC_basic abc = new();

        for (int i = 0; i < 10; i++) begin
            abc.randomize();
            $display("b = %0d", abc.b);
        end
    end

endmodule



// ==========================
// SOLVE BEFORE EXAMPLE
// ==========================
class ABC_solve;

    rand bit a;
    rand bit [1:0] b;

    constraint c_ab {
        a -> b == 3'h3;
        solve a before b;
    }

endclass


module tb_solve;

    initial begin
        ABC_solve abc = new();

        for (int i = 0; i < 8; i++) begin
            abc.randomize();
            $display("a = %0d b = %0d", abc.a, abc.b);
        end
    end

endmodule