module tb;

    string fruits[$] = {"orange", "apple", "kiwi"};

    initial begin
        foreach (fruits[i]) begin
            $display("fruits[%0d] = %s", i, fruits[i]);
        end

        $display("fruits = %p", fruits);

        fruits = {};

        $display("After deletion, fruits = %p", fruits);
    end

endmodule