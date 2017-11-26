----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2017 10:40:50
-- Design Name: 
-- Module Name: top - Behavioral
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

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
	Port(clk               : in  STD_LOGIC;
	     resetn            : in  STD_LOGIC;
	     hsync_in          : in  std_logic;
	     vsync_in          : in  std_logic;
	     href_in           : in  std_logic;
	     cam_pxdata        : in  STD_LOGIC_VECTOR(7 downto 0);
	     cam_clk           : out STD_LOGIC;
	     sensor_data       : out sensor_vector;
	     sensor_data_ready : out STD_LOGIC
	    );
end top;

architecture Behavioral of top is

	component cam_move is
		Port(clk               : in  STD_LOGIC;
		     resetn            : in  STD_LOGIC;
		     hsync_in          : in  std_logic;
		     vsync_in          : in  std_logic;
		     href_in           : in  std_logic;
		     cam_pxdata        : in  STD_LOGIC_VECTOR(7 downto 0);
		     -----
		     cam_clk           : out STD_LOGIC;
		     px_number         : out natural range 0 to 1024 := 0;
		     line_number       : out natural range 0 to 1024 := 0;
		     pixel_data        : out std_logic_vector(23 downto 0);
		     pixel_data_ready  : out STD_LOGIC;
		     sensor_data       : out sensor_vector;
		     sensor_data_ready : out STD_LOGIC
		    );
	end component cam_move;

begin
	
	cm: component cam_move
		port map(
			clk               => clk,
			resetn            => resetn,
			hsync_in          => hsync_in,
			vsync_in          => vsync_in,
			href_in           => href_in,
			cam_pxdata        => cam_pxdata,
			cam_clk           => cam_clk,
			px_number         => open,
			line_number       => open,
			pixel_data        => open,
			pixel_data_ready  => open,
			sensor_data       => sensor_data,
			sensor_data_ready => sensor_data_ready
		);

end Behavioral;
