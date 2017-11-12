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

	generic(sensor_position : pixel_position            := (130, 50);
	        sensor_radius   : integer range 16 downto 4 := 8);

	Port(resetn            : in  STD_LOGIC;
	     clk               : in  STD_LOGIC;
	     pixel_cnt         : in  positive range 1 TO 1023;
	     line_cnt          : in  positive range 1 TO 1023;
	     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0);
	     pixel_data_ready  : in  STD_LOGIC;
	     ----
	     sensor_data       : out sensor;
	     sensor_data_ready : out STD_LOGIC);
end check_sensor;

architecture Behavioral of check_sensor is

	type diff_array is array (0 to 31) of int8u;

	signal px_colors        : color_array;
	signal all_points_ready : std_logic := '0';
	signal new_value        : std_logic := '0';

begin

	fill_points : process(clk) is
		variable i                : integer range 0 to 4*sensor_radius - 1 := 0;
		variable sighn            : integer range -1 to 1                  := -1;
		variable index            : integer range 31 downto 0              := 0;
		variable old_pixel_cnt    : positive range 1 TO 1024;
		variable p                : pixel;
		variable p_sum, color_tmp : RGB_COLOR;
		variable shifts           : shift_position                         := (0, 2, 4, 5, 6, 7, 8, 8, 8, 8, 8, 7, 6, 5, 4, 2, 0);

	begin
		if (clk'event and clk = '0') then

			if resetn = '0' then
				new_value        <= '0';
				i                := 0;
				sighn            := 1;
				index            := 0;
				all_points_ready <= '0';
			else

				new_value        <= '0'; -- neuen wert nur ein mal bei clk kommt
				all_points_ready <= '0';

				if (pixel_data_ready = '1' and pixel_cnt /= old_pixel_cnt) then

					old_pixel_cnt := pixel_cnt; -- nur einen wert von pixel uebernehmen

					-- wenn innerhalb sensor
					if (line_cnt >= sensor_position.y - sensor_radius and line_cnt <= sensor_position.y + sensor_radius ) then

						if (line_cnt = sensor_position.y - sensor_radius and pixel_cnt = sensor_position.x - 1) then
							sighn := 1;
							index := 0;
							i     := 0;
							p_sum := (0, 0, 0);
						end if;

						-- und pixelreihenfolge von links nach rechts
						if (pixel_cnt = sensor_position.x - 1 + sighn*shifts(i)) then --FIXME Vereinheitlichen Pixel faengt von 1 und nicht von 0
							-- index wird von oben nach unten berechnet

							color_tmp.r := to_integer(unsigned(pixel_data(7 downto 0)));
							color_tmp.g := to_integer(unsigned(pixel_data(15 downto 8)));
							color_tmp.b := to_integer(unsigned(pixel_data(23 downto 16)));

							px_colors(index) <= color_tmp;

							p.pos.x := pixel_cnt;
							p.pos.y := line_cnt;

							new_value <= '1';

							--- Prozedur neues pixel Berechnung
							p_sum := middle_value(color_tmp, p_sum);
							--- End Prozedur	

							-- am Ende wenn alle Sensorpunkte durch sind	
							if index = 16 then
								i                := 0;
								index            := 0;
								all_points_ready <= '1';
							end if;

							if sighn = 1 then -- erstes sighn = -1
								index := 31 - i;
								i     := i + 1; -- fuer naechste runde
							else
								index := i;
							end if;

							sighn := -sighn; -- richtung wechsel

						end if;

					end if;
				end if;

			end if;

		end if;

	end process fill_points;

	calc_sensor : process(clk) is
--		procedure calc_s(in_colors : in color_array; signal sensor_out : out sensor) is
--			variable values : diff_array;
--		begin
--
--			for i in 0 to 30 loop
--				values(i) := color_distance(in_colors(i), in_colors(i + 1));
--			end loop;
--			values(31) := color_distance(in_colors(31), in_colors(0));
--
--		end procedure calc_s;

		variable values_1         : diff_array;
		variable max_value        : integer range -255 to 255 := 0;
		variable min_value        : integer range -255 to 255 := 0; 
		variable max_pos : integer range 0 to 31     := 0;
		variable min_pos : integer range 0 to 31     := 0;

	begin
		if (clk'event and clk = '1') then
			if resetn = '0' then
--				sensor_data_ready <= '0'; -- TODO rest initialisieren
			else
				sensor_data_ready <= '0';
				--sensor_data <= (others => 'Z');
				if all_points_ready = '1' then
					--					calc_s(px_colors, sensor_data);		

					-- berechne diffs
					max_value    := color_distance(px_colors(31), px_colors(0));
					min_value    := max_value;
					values_1(31) := max_value;

					for i in 0 to 30 loop
						values_1(i) := color_distance(px_colors(i), px_colors(i + 1));
						if values_1(i) > max_value then
							max_value := values_1(i);
							max_pos   := i;
						end if;
						if values_1(i) < min_value then
							min_value := values_1(i);
							min_pos   := i;
						end if;

					end loop;
					
					-- finde points
					sensor_data.pos.x   <= sensor_position.x;
					sensor_data.pos.y   <= sensor_position.y;
					sensor_data.max_pos <= max_pos;
					sensor_data.min_pos <= min_pos;
					--				sensor_data.color <= p_sum;
					sensor_data_ready   <= '1';

				end if;

			end if;
		end if;
	end process calc_sensor;
	


end Behavioral;
