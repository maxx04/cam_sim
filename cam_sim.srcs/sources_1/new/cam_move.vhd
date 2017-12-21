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
	     cam_clk           : out STD_LOGIC;
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
	signal pclk                 : std_logic;

	signal ram_write_enable : std_logic_vector(0 downto 0);
	signal ram_data_in      : std_logic_vector(23 downto 0);
	signal ram_data_out     : std_logic_vector(23 downto 0);
	signal ram_addr         : std_logic_vector(11 downto 0);
	signal ram_addr_read    : std_logic_vector(11 downto 0);
	signal ram_addr_write   : std_logic_vector(11 downto 0);

	signal outbus_free           : std_logic;
	signal tmp_sensor_data_ready : STD_LOGIC_VECTOR(sensors_number - 1 downto 0);

	component get_pixel_data
		Port(resetn                       : in  std_logic;
		     clk                          : in  std_logic;
		     vsync                        : in  std_logic;
		     href                         : in  std_logic;
		     px_data                      : in  STD_LOGIC_VECTOR(7 downto 0);
		     px_count_out, line_count_out : out natural;
		     px_data_ready                : out std_logic;
		     px_data_out                  : out STD_LOGIC_VECTOR(23 downto 0));
	end component;

	component check_sensor is
		generic(sensor_number   : integer range 1 to 256    := 1;
		        sensor_position : pixel_position            := (130, 50);
		        sensor_radius   : integer range 16 downto 4 := 8);
		Port(resetn            : in  STD_LOGIC;
		     clk               : in  STD_LOGIC;
		     pixel_cnt         : in  positive range 1 TO 1023;
		     line_cnt          : in  positive range 1 TO 1023;
		     pixel_data        : in  STD_LOGIC_VECTOR(23 downto 0); -- farbe f�r pixel
		     pixel_data_ready  : in  STD_LOGIC; -- daten f�r farbe bereit
		     ram_ready         : in  std_logic;
		     ----
		     sensor_data       : out sensor;
		     sensor_data_ready : out STD_LOGIC;
		     ram_we            : out STD_LOGIC;
		     ram_adress        : out std_logic_vector(11 downto 0);
		     ram_data          : out std_logic_vector(23 downto 0)
		    );
	end component;

	component sensor_calc_move is

		Port(clk            : in  STD_LOGIC;
		     resetn         : in  STD_LOGIC;
		     sensors_filled : in  std_logic;
		     ram_we         : in  std_logic;
		     ram_en         : in  std_logic;
		     ram_data       : in  std_logic_vector(23 downto 0);
		     ram_addr       : out std_logic_vector(11 downto 0);
		     move_vector_x  : out integer range -255 to 255;
		     move_vector_y  : out integer range -255 to 255
		    );
	end component sensor_calc_move;

	component blk_mem_gen_0 is
		Port(
			clka  : in  STD_LOGIC;
			ena   : in  STD_LOGIC;
			wea   : in  STD_LOGIC_VECTOR(0 to 0);
			addra : in  STD_LOGIC_VECTOR(11 downto 0);
			dina  : in  STD_LOGIC_VECTOR(23 downto 0);
			douta : out STD_LOGIC_VECTOR(23 downto 0)
		);

	end component blk_mem_gen_0;

begin

	cam_clk <= pclk;

	---- Ausgabe f�r wreiter
	px_number        <= x;
	line_number      <= y;
	pixel_data       <= tmp_pixel_data;
	pixel_data_ready <= tmp_pixel_data_ready;

	cam_to_pixel : get_pixel_data
		port map(
			resetn         => resetn,
			clk            => pclk,
			vsync          => vsync_in,
			href           => href_in,
			px_data        => cam_pxdata,
			px_count_out   => x,
			line_count_out => y,
			px_data_ready  => tmp_pixel_data_ready,
			px_data_out    => tmp_pixel_data
		);

	generate_sensors : for i in 1 to sensors_number generate

		--		signal tmp_sensor : sensor;

	begin

		sensor_inst : component check_sensor
			generic map(
				sensor_number   => i,
				sensor_position => (i *20, 50)
			)
			port map(
				resetn            => resetn,
				clk               => clk,
				pixel_cnt         => x,
				line_cnt          => y,
				pixel_data        => tmp_pixel_data,
				pixel_data_ready  => tmp_pixel_data_ready,
				ram_ready         => '1',
				sensor_data       => open,
				sensor_data_ready => tmp_sensor_data_ready(i - 1),
				ram_we            => ram_write_enable(0),
				ram_adress        => ram_addr_write,
				ram_data          => ram_data_in
			);

	end generate generate_sensors;

	-- FIXME einen signal erstellen zur adresssteuerung
	addr_switch : ram_addr <= ram_addr_write when tmp_sensor_data_ready(sensors_number - 1) = '1' else ram_addr_read;

	ram_inst : blk_mem_gen_0
		port map(
			clka  => clk,
			ena   => '1',
			wea   => ram_write_enable,
			addra => ram_addr,
			dina  => ram_data_in,
			douta => ram_data_out
		);

	calc_move_inst : sensor_calc_move
		port map(
			clk            => clk,
			resetn         => resetn,
			sensors_filled => tmp_sensor_data_ready(sensors_number - 1), -- letzte sensor gefuellt
			ram_we         => ram_write_enable(0),
			-- sensor nr zum berechnen
			-- 
			ram_en         => '1',
			ram_data       => ram_data_out,
			ram_addr       => ram_addr_read,
			move_vector_x  => open,
			move_vector_y  => open
		);

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

	check_bus : process(clk) is         -- ist notwendig f�r clock Verschiebung
	begin
		if rising_edge(clk) then
			if resetn = '0' then
				outbus_free <= '0';
			else
				outbus_free <= not or_reduct(tmp_sensor_data_ready);
			end if;
		end if;
	end process check_bus;

end Behavioral;
