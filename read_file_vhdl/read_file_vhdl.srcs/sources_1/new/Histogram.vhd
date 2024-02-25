library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
use ieee.numeric_std.all;

entity HistogramEqualization is
end HistogramEqualization;

architecture Behavioral of HistogramEqualization is
    file inputFile : text open read_mode is "C:\Users\lenovo\read_file_vhdl\read_file_vhdl.sim\lena_bit_dizisi.txt";
    file outputFile: text open write_mode is "C:\Users\lenovo\read_file_vhdl\read_file_vhdl.sim\histogram_sonucu.txt";
    
    type HistogramArray is array (natural range 0 to 255) of integer;
    signal histogram : HistogramArray := (others => 0);
    signal cdf : HistogramArray := (others => 0);
    signal index : integer := 0;
    signal done : boolean := false;
    constant MAX_PIXEL : integer := 255;
    
begin
    process
        variable inputLine : line;
        variable pixelValue : std_logic_vector(7 downto 0);
        variable totalPixels : integer := 0;
    begin
        while not done loop
            wait for 1ns;
            if not endfile(inputFile) then
                readline(inputFile, inputLine);
                read(inputLine, pixelValue);
                index <= to_integer(unsigned(pixelValue));
                histogram(index) <= histogram(index) + 1;
                totalPixels := totalPixels + 1;
            else
                done <= true;
            end if;
        end loop;
        cdf(0) <= histogram(0);
        for i in 1 to MAX_PIXEL loop
            cdf(i) <= cdf(i-1) + histogram(i);
        end loop;
  
        for i in 0 to MAX_PIXEL loop
            histogram(i) <= MAX_PIXEL * (cdf(i) / totalPixels);
        end loop;
        
        for i in 0 to MAX_PIXEL loop
            write(outputFile, "Pixel " & integer'image(i) & ": " & integer'image(histogram(i)) & LF);
        end loop;
        
        file_close(inputFile);
        file_close(outputFile);
        wait;
    end process;
end Behavioral;