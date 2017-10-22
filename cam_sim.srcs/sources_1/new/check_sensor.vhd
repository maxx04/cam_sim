----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2017 23:26:55
-- Design Name: 
-- Module Name: check_sensor - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity check_sensor is

	generic(sensor_position : pixel_position            := (130, 200);
	        sensor_radius   : integer range 16 downto 4 := 8);

	Port(resetn            : in  STD_LOGIC;
	     clk               : in  STD_LOGIC;
	     pixel_cnt         : in  positive range 1 TO 1023;
	     line_cnt          : in  positive range 1 TO 1023;
	     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0);
	     pixel_data_ready  : in  STD_LOGIC;
	     sensor_data       : out STD_LOGIC_VECTOR(23 downto 0);
	     sensor_data_ready : out STD_LOGIC;
	     pixel_out         : out pixel);
end check_sensor;

architecture Behavioral of check_sensor is

	signal p, my_px  : pixel;
	--	signal form_delta : positions_array;
	signal px_colors : color_array;
	signal i_out     : integer range 0 to positions_array'length - 1;

begin

	check_input : process(clk) is
		variable i : integer range 0 to positions_array'length - 1;

	begin
		if rising_edge(clk) then        -- aktuell kommt 3 mal rein
			if resetn = '0' then
				sensor_data_ready <= '0';
			else

				if pixel_data_ready = '1' then

					if (line_cnt >= sensor_position.y - sensor_radius and line_cnt < sensor_position.y + sensor_radius ) then

						if (pixel_cnt = sensor_position.x - 1) then --FIXME Vereinheitlichen Pixel faengt von 1 und nicht von 0

							i := 2*sensor_radius - (sensor_position.y + sensor_radius - line_cnt);

							px_colors(i).r <= to_integer(unsigned(pixel_data(7 downto 0)));
							px_colors(i).g <= to_integer(unsigned(pixel_data(15 downto 8)));
							px_colors(i).b <= to_integer(unsigned(pixel_data(23 downto 16)));
							
							sensor_data( 7 downto 0) <= pixel_data(7 downto 0); -- FIXME

							i_out <= i; --TODO

						end if;

					end if;
				end if;

			end if;
		end if;
		
		
		
		
	end process check_input;

end Behavioral;
