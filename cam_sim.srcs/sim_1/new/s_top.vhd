----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2017 19:03:41
-- Design Name: 
-- Module Name: s_top - Behavioral
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

entity s_top is
end s_top;

architecture Behavioral of s_top is

	signal reset                    : std_logic := '1';
	signal clk, clk_out             : std_logic := '0';
	signal pclk, hsync, vsync, href : std_logic := '0';
	signal px_data                  : std_logic_vector(7 downto 0);
	signal px_data_ready              : std_logic := '0';
	signal px_data_out              : std_logic_vector(23 downto 0);
	signal x,y : integer :=0 ;

	component sim_tb_bmpread
		port(resetn                                                          : in  std_logic;
		     pixel_data                                                      : out std_logic_vector(7 downto 0);
		     pixel_out_clk, pixel_out_hsync, pixel_out_vsync, pixel_out_href : out std_logic);
	end component;

	component get_mark_points
		Port(resetn                       : in  STD_LOGIC;
		     clk                          : in  STD_LOGIC;
		     vsync                        : in  STD_LOGIC;
		     href                         : in  STD_LOGIC;
		     px_data                      : in  STD_LOGIC_VECTOR(7 downto 0);
		     data_ready                   : out STD_LOGIC;
		     px_count_out, line_count_out : out positive;
		     px_data_out                  : out STD_LOGIC_VECTOR(23 downto 0));
	end component;
	
	component check_sensor is
    Port ( resetn : in STD_LOGIC;
           clk : in STD_LOGIC;
           pixel_cnt :  positive range 1 TO 1023;
           line_cnt :  positive range 1 TO 1023;
           pixel_data : in STD_LOGIC_VECTOR (23 downto 0);
           pixel_data_ready : in STD_LOGIC;
           sensor_data : out STD_LOGIC_VECTOR (23 downto 0);
           sensor_data_ready : out STD_LOGIC);
end component;

	component bmp_wreiter is
		Port(resetn      : in STD_LOGIC;
		     px_clk      : in STD_LOGIC;
		     start_frame : in STD_LOGIC;
		     x,y : in positive;
		     px_data_ready : in STD_LOGIC;
		     px_data     : in STD_LOGIC_VECTOR(23 downto 0));
	end component;

begin

	input : sim_tb_bmpread
		port map(
			resetn          => reset,
			pixel_data      => px_data,
			pixel_out_clk   => pclk,
			pixel_out_hsync => open,
			pixel_out_vsync => vsync,
			pixel_out_href  => href
		);

	bearbeitung : get_mark_points
			port map(
			resetn         => reset,
			clk            => pclk,
			vsync          => vsync,
			href           => href,
			px_data        => px_data,
			px_count_out   => x,
			line_count_out => y,
			data_ready     => px_data_ready,
			px_data_out    => px_data_out
		);
		
		sensor: check_sensor 
	    port map ( 
			resetn       => reset,
			clk            => pclk,
           pixel_cnt => x,
           line_cnt => y,
           pixel_data => px_data_out,
           pixel_data_ready => px_data_ready,
           sensor_data => open,
           sensor_data_ready => open);

	output : bmp_wreiter
			port map(
			resetn      => reset,
			px_clk      => pclk,
			start_frame => vsync,
			x => x , 
			y => y,
			px_data_ready => px_data_ready,
			px_data     => px_data_out
		);

	process(clk) is
	begin
		clk <= not clk after 2 ns;
	end process;

	reset <= '0', '1' after 20 ns;

end Behavioral;
