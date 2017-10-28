----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2017 19:54:01
-- Design Name: 
-- Module Name: get_mark_points - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity get_mark_points is
	GENERIC(byte_per_pixel : natural := 3;
	        width          : natural := 480;
	        hight          : natural := 640);
	        
	PORT(resetn      : in  STD_LOGIC;
	     clk         : in  STD_LOGIC;
	     vsync       : in  STD_LOGIC;
	     href        : in  STD_LOGIC;
	     px_data     : in  STD_LOGIC_VECTOR(7 downto 0);
	     --- out
	     data_ready : out STD_LOGIC; -- auf steigende flanke clk, data abnehmen
	     px_count_out, line_count_out : out positive;
	     px_data_out : out STD_LOGIC_VECTOR(byte_per_pixel*8 - 1 downto 0)
	    );
end get_mark_points;

architecture Behavioral of get_mark_points is

	signal bit_number           : natural   := 0;

begin
	
	byte_counts : process(clk)

    variable px_count, line_count : natural   := 0;		
		
	begin
		if (clk'event and clk = '0') then

			if resetn = '0' then
				px_data_out <= (others => '0');
				data_ready  <= '0';
			else
				-- VSYNC
				if (vsync = '1') then
					px_count   := 0;
					line_count := 0;
				end if;

				data_ready <= '0';

				if (href = '1') then

					case bit_number is
						when 0 => px_data_out(23 downto 16) <= px_data;
						when 1 => px_data_out(15 downto 8) <= px_data;
						when 2 => px_data_out(7 downto 0) <= px_data;
						when others =>
					end case;

					if ( bit_number = byte_per_pixel - 1) then
						px_count   := px_count + 1;
						bit_number <= 0;
						data_ready <= '1';
					else
						bit_number <= bit_number + 1;
					end if;

				else

					px_count   := 0;
					bit_number <= 0;
					
				end if;
				
				if px_count = width then
					line_count := line_count + 1;
				end if;
				
				px_count_out <= px_count;
				line_count_out <= line_count;
				

			end if;
		end if;
	end process;

end Behavioral;
