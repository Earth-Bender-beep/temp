module tb;

    bit [7:0] m_data;

    initial begin
        m_data = 8'hA2;

        for (int i = 0; i < $size(m_data); i++) begin
            $display("m_data[%0d] = %b", i, m_data[i]);
        end
    end

endmodule