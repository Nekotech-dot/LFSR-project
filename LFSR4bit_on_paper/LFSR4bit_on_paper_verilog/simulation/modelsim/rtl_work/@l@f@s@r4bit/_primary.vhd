library verilog;
use verilog.vl_types.all;
entity LFSR4bit is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        lfsr            : out    vl_logic_vector(3 downto 0);
        random_num      : out    vl_logic_vector(3 downto 0);
        output_bit      : out    vl_logic
    );
end LFSR4bit;
