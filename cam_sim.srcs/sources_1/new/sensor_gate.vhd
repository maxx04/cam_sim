----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2017 10:57:34
-- Design Name: 
-- Module Name: sensor_gate - Behavioral
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

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity sensor_gate is
	Port(clk               : in  STD_LOGIC;
	     resetn            : in  STD_LOGIC;
	     sensor_ready      : in  STD_LOGIC;
	     sensor_in         : in  sensor;
	     outbus_free       : in  STD_LOGIC;
	     sensor_out        : out sensor_vector;
	     sensor_data_ready : out std_logic
	    );
end sensor_gate;

architecture Behavioral of sensor_gate is

	signal sensor_tmp       : sensor_vector;
	signal sensor_converted : std_logic;

begin
	convert : process(clk) is
	begin
		if rising_edge(clk) then
			if resetn = '0' then
				sensor_tmp       <= (others => '0');
				sensor_converted <= '0';
			else
				if (sensor_ready = '1') then
					sensor_tmp       <= sensor2vector(sensor_in);
					sensor_converted <= '1';
				else
					sensor_converted <= '0';
				end if;
				
--				if outbus_free = '1' then
--					sensor_data_ready <= '0';
--				else
--					sensor_data_ready <= '1';
--				end if;
				
			end if;
		end if;
	end process convert;

	bus_high : sensor_out <= sensor_tmp when outbus_free = '1' and sensor_converted = '1' else (others => 'Z');
	ready_high : sensor_data_ready <= '1' when outbus_free = '1' and sensor_converted = '1' else  'Z';
	
	

end Behavioral;
