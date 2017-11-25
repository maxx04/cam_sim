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
-- Description: Ändert gelesene BMP datei und schreibt es in neues BMP.
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
use ieee.std_logic_arith.all;
--use IEEE.std_logic_unsigned.all;

use work.sim_bmppack.all;

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity bmp_wreiter is

	GENERIC(byte_per_pixel : natural := 3);
	Port(resetn            : in STD_LOGIC;
	     clk               : in STD_LOGIC;
	     start_frame       : in STD_LOGIC;
	     x, y              : in natural;
	     pixel_data        : in std_logic_vector(23 downto 0);
	     pixel_data_ready  : in STD_LOGIC;
	     sensor_data       : in sensor_vector;
	     sensor_data_ready : in STD_LOGIC);
end bmp_wreiter;

architecture Behavioral of bmp_wreiter is


	signal file_writed                    : std_logic                     := '0';
	signal ImageWidth, ImageHeight, x_old : natural                       := 0;
	signal px_data_tmp                    : std_logic_vector(23 downto 0) := (others => '0');

begin

	writer : process is

	variable tmp_sensor_vec : sensor_vector;
	variable  tmp_sensor                     : sensor;

	
	begin
		wait until rising_edge(clk);

		if resetn = '1' then

			if (x /= x_old) then
				x_old <= x;

				if (pixel_data_ready = '1') then -- selber bild abbilden
					SetPixel(x, y, pixel_data);
				end if;

				if (sensor_data_ready = '1' ) then -- sensor abbilden
					
					tmp_sensor := vector2sensor(sensor_data);
					
					px_data_tmp (7 downto 0) <= conv_std_logic_vector(tmp_sensor.color.r, 8);
					px_data_tmp (15 downto 8) <= conv_std_logic_vector(tmp_sensor.color.g, 8);
					px_data_tmp (23 downto 16) <= conv_std_logic_vector(tmp_sensor.color.b, 8);
					
				end if;

				if (y = 640) then       -- FIXME ende schreiben, dann 
					
					DrawCross(tmp_sensor.pos.x, tmp_sensor.pos.y, px_data_tmp);

					if file_writed = '0' then

						report "write File...";

						WriteFile(" ..\..\test_out.bmp");
						file_writed <= '1';

						report "File is written.";

					end if;

					wait;

				end if;
			end if;

		
		end if;

	end process writer;

end Behavioral;
