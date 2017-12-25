----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2017 12:12:08
-- Design Name: 
-- Module Name: sensor_calc_move - Behavioral
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

entity sensor_calc_move is
	Port(clk               : in  std_logic;
	     resetn            : in  std_logic;
	     sensors_filled    : in  std_logic;
	     ram_we            : in  std_logic;
	     ram_en            : in  std_logic;
	     ram_data          : in  std_logic_vector(23 downto 0);
	     ram_addr          : out std_logic_vector(11 downto 0);
	     sensor_out        : out sensor;
	     sensor_data_ready : out std_logic
	    );
end sensor_calc_move;

architecture Behavioral of sensor_calc_move is

	signal sensor_calculated : std_logic;
	signal sensor_n          : integer range 1 to sensors_number;
	signal index             : integer range 0 to 32 := 0;

	signal move_vector_x : integer range -255 to 255;
	signal move_vector_y : integer range -255 to 255;

begin

	calc_sensor : process(clk) is
		variable values_1                                   : integer range -255 to 255 := 0;
		variable max_value                                  : integer range -255 to 255 := 0;
		variable min_value                                  : integer range -255 to 255 := 0;
		variable max_pos                                    : integer range 0 to 31     := 0;
		variable min_pos                                    : integer range 0 to 31     := 0;
		variable px_colors, px_colors_last, px_colors_first : RGB_COLOR;

	begin
		if (clk'event and clk = '0') then
			if resetn = '0' then
				sensor_data_ready <= '0'; -- TODO rest initialisieren
				sensor_n          <= 1;
				sensor_calculated <= '0';
				ram_addr          <= (others => '0');
			else
				sensor_data_ready <= '0';
				ram_addr          <= (others => '0');

				if (sensors_filled = '1' or index /= 0) and sensor_n < 6 then -- FIXME ressourcen sparen			

					--FIXME optimierung moeglich
					case index is
						when 0 =>
							ram_addr <= get_ram_addr_color(sensor_n, index); -- stelle adress
							-- auch enable 

							index <= index + 1;
						-- für berechnungen immer index-1 benutzen !!!!!!!!!!!!!!!!!!!!!!!!!!!
						when 1 =>       -- erst jetzt data vom index = 0 angekommen also bearbeitung für index 0
						-- lese daten aus RAM -- FIXME als funktion
							px_colors_last := vector2rgb(ram_data);

							px_colors_first := px_colors_last;

							ram_addr  <= get_ram_addr_color(sensor_n, index); -- stelle naechstes adress
							min_value := 0;
							max_value := 0;
							index     <= index + 1;

						when 32 =>
							-- lese daten aus RAM
							px_colors := vector2rgb(ram_data);

							values_1 := color_distance(px_colors, px_colors_first);

							if values_1 > max_value then
								max_value := values_1;
								max_pos   := index - 1;
							end if;

							if values_1 < min_value then
								min_value := values_1;
								min_pos   := index - 1;
							end if;

							move_vector_x      <= max_value; -- TODO ausgabe realisieren
							move_vector_y      <= min_value;
							sensor_data_ready  <= '1';
							sensor_out.pos.x   <= 20 * sensor_n; -- FIXME koordinaten speichern
							sensor_out.pos.y   <= 50;
							sensor_out.min_pos <= min_pos;
							sensor_out.max_pos <= max_pos;
							sensor_calculated  <= '1';
							index              <= 0;
							sensor_n           <= sensor_n + 1; -- FIXME wenn mehr als 5 stop

						when others =>
							-- lese daten aus RAM
							px_colors := vector2rgb(ram_data);

							--	calc_s(px_colors, sensor_data);	-- TODO als entity oder Procedur erstellen	

							values_1 := color_distance(px_colors, px_colors_last);

							if values_1 > max_value then
								max_value := values_1;
								max_pos   := index - 1; -- !! RAM verzoegerung
							end if;

							if values_1 < min_value then
								min_value := values_1;
								min_pos   := index - 1; -- !! RAM verzoegerung
							end if;

							ram_addr       <= get_ram_addr_color(sensor_n, index); -- stelle naechstes adress
							px_colors_last := px_colors;

							index <= index + 1;

					end case;

				end if;

			end if;
		end if;
	end process calc_sensor;

end Behavioral;
