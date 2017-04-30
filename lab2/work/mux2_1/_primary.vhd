library verilog;
use verilog.vl_types.all;
entity mux2_1 is
    port(
        \out\           : out    vl_logic_vector(6 downto 0);
        i0              : in     vl_logic_vector(6 downto 0);
        i1              : in     vl_logic_vector(6 downto 0);
        sel             : in     vl_logic_vector(6 downto 0)
    );
end mux2_1;
