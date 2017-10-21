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

entity cam_move is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           hsync_in, vsync_in, href_in : in std_logic;
           cam_pxdata : in STD_LOGIC_VECTOR (7 downto 0);
           data_to_usb : out STD_LOGIC_VECTOR (7 downto 0)
           );
end cam_move;

architecture Behavioral of cam_move is
	
	
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

begin
	
		cam_to_pixel : get_mark_points
			port map(
			resetn         => resetn,
			clk            => clk,
			vsync          => vsync_in,
			href           => href_in,
			px_data        => cam_pxdata,
			px_count_out   => open,
			line_count_out => open,
			data_ready     => open,
			px_data_out    => open
		);


end Behavioral;
