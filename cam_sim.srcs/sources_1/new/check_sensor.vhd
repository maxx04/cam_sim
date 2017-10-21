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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity check_sensor is
--	 generic(
--	 	
--	 );
    Port ( resetn : in STD_LOGIC;
           clk : in STD_LOGIC;
           pixel_cnt : in positive range 1 TO 1023;
           line_cnt : in positive range 1 TO 1023;
           pixel_data : in STD_LOGIC_VECTOR (23 downto 0);
           pixel_data_ready : in STD_LOGIC;
           sensor_data : out STD_LOGIC_VECTOR (23 downto 0);
           sensor_data_ready : out STD_LOGIC);
end check_sensor;


architecture Behavioral of check_sensor is
	
signal p : pixel;


begin
	
	sensor_data_ready <= '0';
	
	
check_input : process (clk) is
begin
	if rising_edge(clk) then
		if resetn = '0' then
			
		else
			if line_cnt = 30 then
				p.x <= 30;
			end if;
			
			
		end if;
	end if;
end process check_input;



end Behavioral;
