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
use ieee.numeric_std.all;

package CAM_PKG is

	-- packet data length (bytes)
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
		pos   : pixel_position;
		color : RGB_COLOR;
		max_pos : integer range 0 to 31;
		min_pos :  integer range 0 to 31;
	end record;
	

	type positions_array is array (31 downto 0) of pixel_position;
	type color_array is array (31 downto 0) of RGB_COLOR;
	
	type shift_position is array (16 downto 0) of integer range 0 to 8; --- FIXME gr��e 3 bit

	function log2(n : natural) return natural;
	function middle_value(v1 : in RGB_COLOR; v2 : in RGB_COLOR) return RGB_COLOR;
	function color_distance(Pixel0 : in RGB_COLOR; Pixel1 : in RGB_COLOR) return integer;

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
	-----------------------------------------------------------------------------

end package body CAM_PKG;
