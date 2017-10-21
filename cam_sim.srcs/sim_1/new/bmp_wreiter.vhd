----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2017 20:50:53
-- Design Name: 
-- Module Name: bmp_wreiter - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

use work.sim_bmppack.all;

entity bmp_wreiter is

	GENERIC(byte_per_pixel : natural := 3);
	Port(resetn        : in STD_LOGIC;
	     px_clk        : in STD_LOGIC;
	     start_frame   : in STD_LOGIC;
	     x, y          : in natural;
	     px_data_ready : in STD_LOGIC;
	     px_data       : in STD_LOGIC_VECTOR(23 downto 0));
end bmp_wreiter;

architecture Behavioral of bmp_wreiter is

	signal px_data_tmp             : std_logic_vector(23 downto 0);
	signal file_writed             : std_logic := '0';
	signal ImageWidth, ImageHeight : natural   := 0;

begin

	writer : process  is
	begin
		
		GetWidth(ImageWidth);
		GetHeigth(ImageHeight);

		if resetn = '1' then

			wait until rising_edge(px_clk);

			SetPixel(x, y, px_data);
			
			if x = 0 then
				report "line - " & integer'image(y);
			end if;
			

			if (y = ImageHeight) then -- ende schreiben, dann

				if file_writed = '0' then

					report "write File...";
					
					WriteFile(" ..\..\test_out.bmp");
					file_writed <= '1';
					
					report "File is written.";


				end if;

					wait until false;

			end if;

		end if;

	end process writer;

end Behavioral;
