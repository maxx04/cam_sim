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

	generic(sensor_number   : integer range 1 to 256    := 1; -- FIXME max anzahl anpassen
	        sensor_position : pixel_position            := (130, 50);
	        sensor_radius   : integer range 16 downto 4 := 8);

	Port(resetn            : in  STD_LOGIC;
	     clk               : in  STD_LOGIC;
	     pixel_cnt         : in  positive range 1 TO 1023;
	     line_cnt          : in  positive range 1 TO 1023;
	     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0); -- farbe für pixel
	     pixel_data_ready  : in  STD_LOGIC; -- daten für farbe bereit
	     ram_ready         : in  std_logic;
	     ----
	     sensor_data       : out sensor;
	     sensor_data_ready : out STD_LOGIC;
	     ram_we            : out std_logic;
	     ram_adress        : out std_logic_vector(11 downto 0);
	     ram_data          : out std_logic_vector(23 downto 0)
	    );
end check_sensor;

architecture Behavioral of check_sensor is

	signal all_points_ready : std_logic := '0';
	signal new_value        : std_logic := '0';

begin

	fill_points : process(clk) is
		variable i             : integer range 0 to 4*sensor_radius - 1 := 0;
		variable sighn         : integer range -1 to 1                  := -1;
		variable index         : integer range 32 downto 0              := 0; -- 32 = to 31 + 1 position FIXME 
		variable old_pixel_cnt : positive range 1 TO 1024;
		--		variable p             : pixel;
		--		variable p_sum         : RGB_COLOR;

	begin
		if (clk'event and clk = '0') then

			if resetn = '0' then
				new_value         <= '0';
				i                 := 0;
				sighn             := 1;
				index             := 0;
				ram_we            <= 'Z';
				ram_adress        <= (others => '0');
				ram_data          <= (others => '0');
				all_points_ready  <= '0';
				sensor_data_ready <= '0';
			else

				new_value        <= '0'; -- neuen wert nur ein mal bei clk kommt
				all_points_ready <= '0';
				ram_we           <= 'Z';
				ram_adress       <= (others => 'Z'); -- FIXME auf collision prüfen
				ram_data         <= (others => 'Z');
				
				
				if(all_points_ready = '1') then -- all points ist noch 1 nach dem index = 16
								ram_we     <= '1';
								ram_adress <= get_ram_addr_color(sensor_number, 32);
								ram_data (23 downto 12)   <= std_logic_vector(to_unsigned(sensor_position.x, 12));
								ram_data (11 downto 0)   <= std_logic_vector(to_unsigned(sensor_position.y, 12));
								
								index             := 0;
								sensor_data_ready <= '1';
				end if;

				if (pixel_data_ready = '1' and pixel_cnt /= old_pixel_cnt) then -- FIXME schlechtes stil, ressource

					old_pixel_cnt := pixel_cnt; -- nur einen wert von pixel uebernehmen

					-- wenn innerhalb sensor
					if (line_cnt >= sensor_position.y - sensor_radius and line_cnt <= sensor_position.y + sensor_radius) then

						-- wenn oberes punkt erreicht ist
						if (line_cnt = sensor_position.y - sensor_radius and pixel_cnt = sensor_position.x - 1) then
							sighn := 1;
							index := 0;
							i     := 0;
						end if;

						-- und pixelreihenfolge von links nach rechts
						if (pixel_cnt = sensor_position.x - 1 + sighn*get_circle_shift(i)) then --FIXME Vereinheitlichen Pixel faengt von 1 und nicht von 0
							-- index wird von oben nach unten berechnet

							new_value <= '1';

							if ram_ready = '1' then -- FIXME not activated
								ram_we     <= '1';
								ram_adress <= get_ram_addr_color(sensor_number, index);
								ram_data   <= pixel_data;
							else
								report "ram isnt ready" severity note;
							end if;

							--- Prozedur neues pixel Berechnung
							--	p_sum := middle_value(color_tmp, p_sum);
							--- End Prozedur	

							-- am Ende wenn alle Sensorpunkte durch sind	
							if index = 16 then
								i                := 0;
								index            := 32;
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

end Behavioral;
