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
-- Dependencies: Voraussetzung dass die sensoren in ene linie nicht gleichzeitig bearbeitet werden! Heben keine gemeinsame punkte.
-- wenn notwendig soll zweite reihe draufgelegt werden. Kamerascan laeuft von unten nach oben, von links nach rechts.
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
	signal index            : integer range 0 to points_per_circle;

begin

	fill_points : process(clk) is
		variable i     : integer range 0 to 4*sensor_radius - 1 := 0;
		variable sighn : integer range -1 to 1                  := -1;

		variable old_pixel_cnt : positive range 1 TO 1024;
		--		variable p             : pixel;
		--		variable p_sum         : RGB_COLOR;

	begin
		if (clk'event and clk = '0') then

			if resetn = '0' then
				new_value         <= '0';
				i                 := 0;
				sighn             := 1;
				index             <= (points_per_circle / 2 - 1) + 3;
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

				if (all_points_ready = '1') then -- all points ist noch 1 nach dem index = points_per_circle / 2
					ram_we                 <= '1';
					ram_adress             <= get_ram_addr_color(sensor_number, (points_per_circle - 1) + 1);
					ram_data(23 downto 12) <= std_logic_vector(to_unsigned(sensor_position.x, 12));
					ram_data(11 downto 0)  <= std_logic_vector(to_unsigned(sensor_position.y, 12));

					index             <= (points_per_circle / 2 - 1) + 3; -- fuer naechste runde;
					sensor_data_ready <= '1';

				end if;

				if (pixel_data_ready = '1' and pixel_cnt /= old_pixel_cnt) then -- FIXME schlechtes stil, ressource

					old_pixel_cnt := pixel_cnt; -- nur einen wert von pixel uebernehmen

					-- wenn innerhalb sensor
					if (line_cnt >= sensor_position.y - sensor_radius and line_cnt <= sensor_position.y + sensor_radius) then

						-- und pixelreihenfolge von links nach rechts !!!
						if (pixel_cnt = sensor_position.x + get_circle_shift_x(index)) then 
							-- index wird von oben nach unten berechnet

							new_value <= '1';

							if ram_ready = '1' then 
								ram_we     <= '1';
								ram_adress <= get_ram_addr_color(sensor_number, index);
								ram_data   <= pixel_data;
							else
								report "ram isnt ready" severity note;
							end if;

							--- Prozedur neues pixel Berechnung
							--	p_sum := middle_value(color_tmp, p_sum);
							--- End Prozedur	

							if sighn = 1 then
								index <= points_per_circle / 2 + i;

							else
								index <= points_per_circle / 2 - i;
								i     := i + 1; -- fuer naechste runde
							end if;

							sighn := -sighn; -- richtung wechsel

							-- wenn oberes punkt erreicht ist
							if (line_cnt = sensor_position.y + sensor_radius) then
								i := 0;
								case pixel_cnt is -- immer naechste vorgabe für index
									when sensor_position.x - 2 =>
										index <= points_per_circle - 1; 
									when sensor_position.x - 1 =>
										index <= 0;
									when sensor_position.x =>
										index <= 1;
									when sensor_position.x + 1 => -- letztes punkt
										index <= 2;
									when sensor_position.x + 2 =>    -- sensor gefuellt
										index <= points_per_circle - 2 - 1;
										all_points_ready <= '1';
										sighn := -1;
										i     := 0;
									when others => null;
								end case;

							end if;

							-- wenn unteres punkt erreicht ist
							if (line_cnt = sensor_position.y - sensor_radius) then
								i := 0;
								case pixel_cnt is -- immer naechste vorgabe für index -- FIXME reihenfolge anders von links nach rechts
									when sensor_position.x - 2 =>
										index <= points_per_circle / 2 - 1 + 2;
									when sensor_position.x - 1 =>
										index <= points_per_circle / 2 - 1 + 1;
									when sensor_position.x =>
										index <= points_per_circle / 2 - 1;
									when sensor_position.x + 1 =>
										index <= points_per_circle / 2 - 1 - 1;
									when sensor_position.x + 2 =>
										index <= points_per_circle / 2 - 1 + 4; -- naechstes punkt
										sighn := -1;
										i     := 3;
									when others => null;
								end case;

							end if;

						end if;

					end if;
				end if;

			end if;

		end if;

	end process fill_points;

end Behavioral;
