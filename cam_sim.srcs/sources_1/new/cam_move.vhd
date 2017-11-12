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
	Port(clk               : in  STD_LOGIC;
	     resetn            : in  STD_LOGIC;
	     hsync_in          : in  std_logic;
	     vsync_in          : in  std_logic;
	     href_in           : in  std_logic;
	     cam_pxdata        : in  STD_LOGIC_VECTOR(7 downto 0);
	     -----
	     cam_clk              : out STD_LOGIC;
	     px_number         : out natural range 0 to 1024 := 0;
	     line_number       : out natural range 0 to 1024 := 0;
	     pixel_data        : out std_logic_vector(23 downto 0);
	     pixel_data_ready  : out STD_LOGIC;
	     sensor_data       : out sensor_vector;
	     sensor_data_ready : out STD_LOGIC
	    );
end cam_move;

architecture Behavioral of cam_move is

	signal tmp_pixel_data_ready : std_logic               := '0';
	signal tmp_pixel_data       : std_logic_vector(23 downto 0);
	signal x, y                 : integer range 0 to 1024 := 0;
	signal pclk              : STD_LOGIC;
	constant pclk_to_clk_rate   : integer                 := 5;
	
	signal outbus_free : STD_LOGIC;
	signal tmp_sensor_data_ready : STD_LOGIC_VECTOR(4 downto 0);

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
		generic(sensor_position : pixel_position            := (130, 50);
		        sensor_radius   : integer range 16 downto 4 := 8);
		Port(resetn            : in  STD_LOGIC;
		     clk               : in  STD_LOGIC;
		     pixel_cnt         :     positive range 1 TO 1023;
		     line_cnt          :     positive range 1 TO 1023;
		     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0);
		     pixel_data_ready  : in  STD_LOGIC;
		     sensor_data       : out sensor;
		     sensor_data_ready : out STD_LOGIC);
	end component;

	component sensor_gate is
		Port(clk               : in  STD_LOGIC;
		     resetn            : in  STD_LOGIC;
		     sensor_ready      : in  STD_LOGIC;
		     sensor_in         : in  sensor;
		     outbus_free       : in  STD_LOGIC;
		     sensor_out        : out sensor_vector;
		     sensor_data_ready : out std_logic
		    );
	end component;

begin

	cam_clk <= pclk;

	---- Ausgabe für wreiter
	px_number        <= x;
	line_number      <= y;
	pixel_data       <= tmp_pixel_data;
	pixel_data_ready <= tmp_pixel_data_ready;

	cam_to_pixel : get_mark_points
		port map(
			resetn         => resetn,
			clk            => pclk,
			vsync          => vsync_in,
			href           => href_in,
			px_data        => cam_pxdata,
			px_count_out   => x,
			line_count_out => y,
			data_ready     => tmp_pixel_data_ready,
			px_data_out    => tmp_pixel_data
		);

		outbus_free <= or_reduct( tmp_sensor_data_ready); -- FIXME ein Takt dazu wird gebraucht


	generate_sensors : for i in 1 to 5 generate

		signal tmp_sensor            : sensor;

		

	begin
		

		
		sensor_inst : component check_sensor
			generic map(sensor_position => (i*20, 50))
			port map(
				resetn            => resetn,
				clk               => clk,
				pixel_cnt         => x,
				line_cnt          => y,
				pixel_data        => tmp_pixel_data,
				pixel_data_ready  => tmp_pixel_data_ready,
				sensor_data       => tmp_sensor,
				sensor_data_ready => tmp_sensor_data_ready(i-1)
			);

		sensor_gate_inst : component sensor_gate
			port map(
				clk               => clk,
				resetn            => resetn,
				sensor_ready      => tmp_sensor_data_ready(i-1),
				sensor_in         => tmp_sensor,
				outbus_free       => outbus_free,
				sensor_out        => sensor_data,
				sensor_data_ready => sensor_data_ready
			);

	end generate generate_sensors;

	pclk_pr : process(clk) is

		variable n : integer := 0;

	begin
		if rising_edge(clk) then
			if resetn = '0' then
				n    := 0;
				pclk <= '0';
			else
				n := n + 1;

				if n > pclk_to_clk_rate then
					pclk <= '1';
				else
					pclk <= '0';
				end if;

				if n = 2*pclk_to_clk_rate then
					n := 0;
				end if;

			end if;
		end if;
	end process pclk_pr;
	
--check_bus : process (clk) is
--begin
--	if rising_edge(clk) then
--		if resetn = '0' then
--			outbus_free <= '0';
--		else
--			if tmp_sensor_data_ready = '1' then
--				outbus_free <= '0';
--			else
--				outbus_free <= '1';
--			end if;
--			
--		end if;
--	end if;
--end process check_bus;


end Behavioral;
