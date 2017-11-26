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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity sensor_calc_move is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           datata_in_ready : in STD_LOGIC;
           sensor_data : in sensor;
           
           move_vector_x : out integer  range -255 to 255;
           move_vector_y : out integer  range -255 to 255
           );
end sensor_calc_move;

architecture Behavioral of sensor_calc_move is

begin


end Behavioral;
