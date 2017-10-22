----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2017 18:52:36
-- Design Name: 
-- Module Name: cam_move - Behavioral
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

entity cam_move is
	Port(clk                         : in  STD_LOGIC;
	     resetn                      : in  STD_LOGIC;
	     hsync_in, vsync_in, href_in : in  std_logic;
	     cam_pxdata                  : in  STD_LOGIC_VECTOR(7 downto 0);
	     data_to_usb                 : out STD_LOGIC_VECTOR(7 downto 0)
	    );
end cam_move;

architecture Behavioral of cam_move is

--	signal pclk, hsync, vsync, href : std_logic := '0';
--	signal px_data                  : std_logic_vector(7 downto 0);
	signal px_data_ready            : std_logic := '0';
	signal px_data_out              : std_logic_vector(23 downto 0);
	signal to_usb              : std_logic_vector (23 downto 0);
	signal x, y                     : integer  range 0 to 1024 := 0;

	component get_mark_points
		Port(resetn                       : in  STD_LOGIC;
		     clk                          : in  STD_LOGIC;
		     vsync                        : in  STD_LOGIC;
		     href                         : in  STD_LOGIC;
		     px_data                      : in  STD_LOGIC_VECTOR(7 downto 0);
		     data_ready                   : out STD_LOGIC;
		     px_count_out, line_count_out : out natural;
		     px_data_out                  : out STD_LOGIC_VECTOR(23 downto 0));
	end component;

	component check_sensor is
		Port(resetn            : in  STD_LOGIC;
		     clk               : in  STD_LOGIC;
		     pixel_cnt         :     positive range 1 TO 1023;
		     line_cnt          :     positive range 1 TO 1023;
		     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0);
		     pixel_data_ready  : in  STD_LOGIC;
		     sensor_data       : out STD_LOGIC_VECTOR(23 downto 0);
		     sensor_data_ready : out STD_LOGIC;
		     pixel_out         : out pixel);
	end component;

begin
	
	data_to_usb <= to_usb(7 downto 0);

	cam_to_pixel : get_mark_points
		port map(
			resetn         => resetn,
			clk            => clk,
			vsync          => vsync_in,
			href           => href_in,
			px_data        => cam_pxdata,
			px_count_out   => x,
			line_count_out => y,
			data_ready     => px_data_ready,
			px_data_out    => px_data_out
		);

	sensor : check_sensor
		port map(
			resetn            => resetn,
			clk               => clk,
			pixel_cnt         => x,
			line_cnt          => y,
			pixel_data        => px_data_out,
			pixel_data_ready  => px_data_ready, -- FIXME reihenfolge data dann ready
			sensor_data       => to_usb, -- FIXME 
			sensor_data_ready => open,
			pixel_out         => open);

end Behavioral;
