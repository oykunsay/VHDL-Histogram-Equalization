--binary dosyadan okuyup ram'e yazarýz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_file_reader is
    port(
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        address : in std_logic_vector(7 downto 0);
        read_enable : in std_logic;
        write_enable : in std_logic;
        done : out std_logic
    );
end input_file_reader;

architecture behavior of input_file_reader is
    type ram_type is array (0 to 256**2-1) of std_logic_vector(7 downto 0);
    signal ram : ram_type;
    signal address_reg : std_logic_vector(7 downto 0);
    signal data_reg : std_logic_vector(7 downto 0);
    signal read_reg : std_logic;
    signal write_reg : std_logic;
    signal done_reg : std_logic;
    signal file_done : std_logic;
    file input_file : "bit_dizisi.txt";
    variable line : line;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            address_reg <= (others => '0');
            data_reg <= (others => '0');
            read_reg <= '0';
            write_reg <= '0';
            done_reg <= '0';
        elsif rising_edge(clk) then
            address_reg <= address;
            data_reg <= data_in;
            read_reg <= read_enable;
            write_reg <= write_enable;
            done_reg <= file_done;
        end if;
    end process;

    process(reset, clk)
    is
        variable address_int : integer;
    begin
        if reset = '1' then
            file_done <= '0';
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if write_reg = '1' then
                ram(to_integer(unsigned(address_reg))) <= data_reg;
            elsif read_reg = '1' then
                data_out <= ram(to_integer(unsigned(address_reg)));
            end if;
            if done_reg = '0' and file_done = '0' then
                readline(input_file, line);
                if endfile(input_file) then
                    file_done <= '1';
                else
                    read(line, address_int);
                    address_reg <= std_logic_vector(to_unsigned(address_int, 8));
                    read(line, data_reg);
                end if;
            end if;
        end if;
    end process;

    done <= file_done;
end behavior;