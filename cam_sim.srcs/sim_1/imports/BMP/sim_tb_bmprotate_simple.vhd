-------------------------------------------------------------------------------
-- Title      : Testbench BMP Rotate
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sim_tb_bmprotate.vhd
-- Author     : Kest
-- Company    : 
-- Created    : 2006-12-05
-- Last update: 2007-10-29
-- Platform   : ModelSIM
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2006-12-05  1.0      kest            Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;

use work.sim_bmppack.all;

-------------------------------------------------------------------------------

entity sim_tb_bmprotate_simple is
end sim_tb_bmprotate_simple;

-------------------------------------------------------------------------------
architecture testbench of sim_tb_bmprotate_simple is
  constant cMathOne : integer := 1024;

  signal clk  : std_logic                     := '0';
  signal data : std_logic_vector(23 downto 0) := x"ffffff";

  signal adr, ImageWidth, ImageHeight, centerX, centerY : integer := 0;
  signal x, y, x_mitte, y_mitte                         : integer;

  signal angle, zoom                : real := 0.0;
  signal co, si, rotX, rotY, xf, yf : real := 0.0;

  
begin

  process(clk) is
  begin
    clk <= not clk after 5 ns;
  end process;



  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

  process is

  begin

    
    ReadFile("lena.bmp");

    angle <= 45.0 * 3.14 / 180.0;
    zoom  <= 1.0;


    GetWidth(ImageWidth);
    GetHeigth(ImageHeight);

    wait until clk'event and clk = '1';

    co <= cos(angle);
    si <= sin(angle);

    wait until clk'event and clk = '1';



    ---------------------------------------------------------------------------
    -- innere Schleife
    ---------------------------------------------------------------------------

    centerX <= integer(ImageWidth/2);
    centerY <= integer(ImageHeight/2);
    

    for y1 in 0 to integer(real(ImageHeight)/zoom) loop

      wait until clk'event and clk = '1';


      for x1 in 0 to integer(real(ImageWidth)/zoom) loop


        rotX <= real(x1);
        rotY <= real(y1);

        xf <= rotX * co + rotY * si;
        yf <= rotY * co - rotX * si;

        wait until clk'event and clk = '1';

        x <= integer(xf);
        y <= integer(yf);

        wait until clk'event and clk = '1';


        if x >= 0 and x < ImageWidth and y >= 0 and y < ImageHeight then
          GetPixel(x, y, data);
          wait until clk'event and clk = '1';

          SetPixel(x1, y1, data);
          wait until clk'event and clk = '1';
          
        end if;

      end loop;
    end loop;

    wait until clk'event and clk = '1';

    report "Jetzt ist das Bild fertig...";

    WriteFile("lena_rotated.bmp");
    wait until clk'event and clk = '1';

    wait;
  end process;
  


  
end testbench;

