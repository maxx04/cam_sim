----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2012 05:36:01
-- Design Name: 
-- Module Name: cam_pkg - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.std_logic_arith.all;

package CAM_PKG is

	constant Image_Width  : positive := 480;
	constant Image_Hight  : positive := 640;
	constant bytes_per_px : positive := 3;

	subtype int8u is integer range 0 to 255;

	type RGB_COLOR is record
		r : integer range 0 TO 255;
		g : integer range 0 TO 255;
		b : integer range 0 TO 255;
	end record;

	type pixel_position is record
		x : integer range 1 TO Image_Width;
		y : integer range 1 TO Image_Hight;
	end record;

	type pixel is record
		pos   : pixel_position;
		color : RGB_COLOR;
	end record;

	type sensor is record
		pos     : pixel_position;
		color   : RGB_COLOR;
		max_pos : integer range 0 to 31;
		min_pos : integer range 0 to 31;
	end record;

	subtype sensor_vector is std_logic_vector(63 downto 0);

	type positions_array is array (31 downto 0) of pixel_position;
	type color_array is array (31 downto 0) of RGB_COLOR;
	type shift_position is array (16 downto 0) of integer range 0 to 8; --- FIXME größe 3 bit

	function log2(n : natural) return natural;
	function middle_value(v1 : in RGB_COLOR; v2 : in RGB_COLOR) return RGB_COLOR;
	function color_distance(Pixel0 : in RGB_COLOR; Pixel1 : in RGB_COLOR) return integer;
	function sensor2vector(sensor_t : sensor) return sensor_vector;
	function vector2sensor(slv : sensor_vector) return sensor;
	function or_reduct(slv : in std_logic_vector) return std_logic;

end package CAM_PKG;

package body CAM_PKG is

	-----------------------------------------------------------------------------
	function log2(n : natural) return natural is
	begin
		for i in 0 to 31 loop
			if (2 ** i) >= n then
				return i;
			end if;
		end loop;
		return 32;
	end log2;

	function middle_value(v1 : in RGB_COLOR; v2 : in RGB_COLOR) return RGB_COLOR is
		variable r : RGB_COLOR;
	begin
		r.r := (v1.r + v2.r)/2;
		r.g := (v1.g + v2.g)/2;
		r.b := (v1.b + v2.b)/2;
		return r;
	end function middle_value;

	function color_distance(Pixel0 : in RGB_COLOR; Pixel1 : in RGB_COLOR) return integer is
	begin
		return (((Pixel0.r + Pixel0.g + Pixel0.b) - (Pixel1.r + Pixel1.g + Pixel1.b)));
	end function color_distance;

	function sensor2vector(sensor_t : sensor) return sensor_vector is
		variable slv : sensor_vector;
	begin
		slv(63 downto 52) := std_logic_vector(to_unsigned(sensor_t.pos.x, 12));
		slv(51 downto 40) := std_logic_vector(to_unsigned(sensor_t.pos.y, 12));
		slv(39 downto 32) := std_logic_vector(to_unsigned(sensor_t.color.r, 8));
		slv(31 downto 24) := std_logic_vector(to_unsigned(sensor_t.color.g, 8));
		slv(23 downto 16) := std_logic_vector(to_unsigned(sensor_t.color.b, 8));
		slv(15 downto 8)  := std_logic_vector(to_signed(sensor_t.max_pos, 8));
		slv(7 downto 0)   := std_logic_vector(to_signed(sensor_t.min_pos, 8));
		return slv;
	end;

	function vector2sensor(slv : sensor_vector) return sensor is
		variable sensor_t : sensor;
	begin
		sensor_t.pos.x   := to_integer(unsigned(slv(63 downto 52))); -- FIXME prüfen ob richtig funktioniert
		sensor_t.pos.y   := to_integer(unsigned(slv(51 downto 40)));
		sensor_t.color.r := to_integer(unsigned(slv(39 downto 32)));
		sensor_t.color.r := to_integer(unsigned(slv(31 downto 24)));
		sensor_t.color.r := to_integer(unsigned(slv(23 downto 16)));
		sensor_t.max_pos := to_integer(signed(slv(15 downto 08)));
		sensor_t.min_pos := to_integer(signed(slv(07 downto 00)));
		return sensor_t;
	end;

 function or_reduct(slv : in std_logic_vector) return std_logic is
    variable res_v : std_logic;
  begin
    res_v := '0';
    for i in slv'range loop
      res_v := res_v or slv(i);
    end loop;
    return res_v;
  end function;
	
	
--ENTITY orn IS
--GENERIC (n : INTEGER := 4);
--PORT (x : IN STD_LOGIC_VECTOR(1 TO n);
--f : OUT STD_LOGIC);
--END orn;
--
--ARCHITECTURE dataflow OF orn IS
--SIGNAL tmp : STD_LOGIC_VECTOR(1 TO n);
--BEGIN
--tmp <= (OTHERS => '0');
--f <= '0' WHEN x = tmp ELSE '1';
--END dataflow;

end package body CAM_PKG;
