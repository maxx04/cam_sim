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
	constant pck_data_length  : positive := 12;
	constant numb_sync_bytes  : positive := 5;
	constant numb_cntrl_bytes : positive := 1;
	constant numb_crc_bytes   : positive := 2;

	constant gl_packet_length : positive := numb_sync_bytes + numb_cntrl_bytes + pck_data_length + numb_crc_bytes;

	constant G_LINE_WIDTH  : integer := 48;
	constant G_PIXEL_BYTES : integer := 2;

	type RGB_COLOR is record
		r : positive range 1 TO 1023; --(7 downto 0);
		g : unsigned (7 downto 0);
		b : unsigned (7 downto 0);
	end record;

	type pixel is record
		x     : positive range 1 TO 1023;
		y     : positive range 1 TO 1023;
		color : RGB_COLOR;
	end record;

	function log2(n : natural) return natural;

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

	-----------------------------------------------------------------------------

end package body CAM_PKG;
