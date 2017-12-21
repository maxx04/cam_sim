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

library xil_defaultlib;
use xil_defaultlib.CAM_PKG.all;

entity s_top is
end s_top;


architecture Behavioral of s_top is

	signal reset                                : std_logic := '1';
	signal clk, clk_out                         : std_logic := '0';
	signal pclk, cam_hsync, cam_vsync, cam_href : std_logic := '0';
	signal px_data                              : std_logic_vector(7 downto 0);
	signal data_to_wreiter_ready                : std_logic := '0';
	signal data_to_wreiter                      : std_logic_vector(23 downto 0);
	signal x, y                                 : integer   := 0;
	signal tmp_sensor                           : sensor_vector;
	signal tmp_sensor_ready                     : std_logic := '0';

	component sim_tb_bmpread
		port(resetn                                           : in  std_logic;
		     pclk                                             : in  std_logic;
		     pixel_data                                       : out std_logic_vector(7 downto 0);
		     pixel_out_hsync, pixel_out_vsync, pixel_out_href : out std_logic);
	end component;

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

	end component;

	component bmp_wreiter is
		Port(resetn            : in STD_LOGIC;
		     clk               : in STD_LOGIC;
		     start_frame       : in STD_LOGIC;
		     x, y              : in positive;
		     pixel_data        : in std_logic_vector(23 downto 0);
		     pixel_data_ready  : in STD_LOGIC;
		     sensor_data       : in sensor_vector;
		     sensor_data_ready : in STD_LOGIC);
	end component;

begin

	input : sim_tb_bmpread
		port map(
			resetn          => reset,
			pclk            => pclk,
			pixel_data      => px_data,
			pixel_out_hsync => cam_hsync,
			pixel_out_vsync => cam_vsync,
			pixel_out_href  => cam_href
		);

	modul : cam_move
		port map(clk               => clk,
		         resetn            => reset,
		         hsync_in          => cam_hsync,
		         vsync_in          => cam_vsync,
		         href_in           => cam_href,
		         cam_pxdata        => px_data,
		         ---
		         cam_clk           => pclk,
		         px_number         => x,
		         line_number       => y,
		         pixel_data        => data_to_wreiter,
		         pixel_data_ready  => data_to_wreiter_ready,
		         sensor_data       => tmp_sensor,
		         sensor_data_ready => tmp_sensor_ready
		        );

	output : bmp_wreiter
		port map(
			resetn            => reset,
			clk               => clk,
			start_frame       => cam_vsync,
			x                 => x,
			y                 => y,
			pixel_data        => data_to_wreiter,
			pixel_data_ready  => data_to_wreiter_ready,
			sensor_data       => tmp_sensor,
			sensor_data_ready => tmp_sensor_ready
		);

	clk <= not clk after 10 ns;

	reset <= '0', '1' after 20 ns;

end Behavioral;
