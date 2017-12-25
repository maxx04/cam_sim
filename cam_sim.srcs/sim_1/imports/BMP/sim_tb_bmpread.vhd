-------------------------------------------------------------------------------
-- Title      : Testbench BMP Read
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sim_tb_bmpread.vhd
-- Author     : Kest
-- Company    : 
-- Created    : 2006-12-05
-- Last update: 2007-12-26
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
use IEEE.NUMERIC_STD.ALL;

use work.sim_bmppack.all;

entity sim_tb_bmpread is

port(
        resetn : in std_logic;
        pclk : in std_logic;
        
 		pixel_data : out std_logic_vector(7 downto 0 ); 

 		 pixel_out_hsync, pixel_out_vsync, pixel_out_href : out std_logic );

end sim_tb_bmpread;

-------------------------------------------------------------------------------


architecture BMP_to_OV7670 of sim_tb_bmpread is
  
  
  signal clk : std_logic := '0'; 
  signal ImageWidth, ImageHeight : integer := 0;
  signal bit_number : integer := 0;
  
  signal temp_hsync, temp_vsync, temp_href, temp_pixel_clock : std_logic ;
  signal pixel_data_temp : std_logic_vector(23 downto 0);
  signal data: std_logic_vector(7 downto 0);
  
  signal npixel, nline : integer; 
  
  constant VSYNC_Width : integer := 3; --sehe Datenblatt OV 7670
  constant VSYNC_for : integer := 17;
  constant VSYNC_after : integer := 10;
  
  constant HSYNC_Width : integer := 80;
  constant HSYNC_for : integer := 45;
  constant HSYNC_after : integer := 19;
  
  constant byte_per_pixel : integer := 3;

  

  
begin

        assert byte_per_pixel < 4 
            report " byte_per_pixel to big "
            severity failure;



read_file:  process
		
		variable px_count, x_count, y_count, line_count, byte_count, bit_number : integer := 0 ;
    begin
    
    report "read File...";
    ReadFile("test.bmp");


    GetWidth(ImageWidth);
    GetHeigth(ImageHeight);
    
    if resetn = '1' then
    
      loop EXIT WHEN line_count = (ImageHeight + VSYNC_for + VSYNC_Width + VSYNC_after); 
  
			wait until pclk'event and clk = '0';		-- bei negative flanke			
			temp_pixel_clock <= '0';
				
		  -- HSYNC
              if (px_count >= 0 and px_count < HSYNC_Width - 1) then                                
                    temp_hsync <= '0';               
              else
                    temp_hsync <= '1' ;
              end if ;
				
		  -- HREF
                if (px_count >= (HSYNC_for + HSYNC_Width)
                  and px_count < (HSYNC_for + HSYNC_Width  + ImageWidth)
                  and line_count >= (VSYNC_for +  VSYNC_Width)
                  and line_count < (VSYNC_for + VSYNC_Width +  ImageHeight)) then   
                      if (bit_number = 0) then             
                          GetPixel( px_count - (HSYNC_for + HSYNC_Width), line_count - (VSYNC_for + VSYNC_Width), pixel_data_temp);
                          
                          npixel <= px_count - (HSYNC_for + HSYNC_Width); 
                          nline <= line_count - (VSYNC_for + VSYNC_Width);
                      end if;
                      temp_href <= '1';                     					
				else
					  pixel_data_temp <= (others => '0');
					  temp_href <= '0';

				end if ;
				
            -- vsync control
				if line_count < VSYNC_Width then -- nach 510 lines line_count soll auf 0
					temp_vsync <= '1' ;
				 else 
					temp_vsync <= '0' ;
				end if ;
			


			if (px_count = (HSYNC_for + HSYNC_Width + ImageWidth - 1 + HSYNC_after) ) then -- neue line
					px_count := 0 ; -- abnullen
					bit_number := 0;
				    if (line_count > ( VSYNC_for + VSYNC_Width + ImageHeight - 1 + VSYNC_after)) then -- neues Frame
						line_count := 0; -- abnullen
				    else
					   line_count := line_count + 1 ;
				    end if;
			end if ;
			
			if line_count >= (VSYNC_for + VSYNC_Width + ImageHeight - 1 + VSYNC_after) then -- volle frame 
                line_count := 0;
                px_count := 0;
                bit_number := 0;
            end if;

				
			wait until  pclk'event and pclk = '1'; -- bei positive flanke
			
			temp_pixel_clock <= '1';	
			
			case bit_number is
               when 0 =>
                  data <= pixel_data_temp(23 downto 16);
               when 1 =>
                  data <= pixel_data_temp(15 downto 8);
               when 2 =>
                  data <= pixel_data_temp(7 downto 0);
            end case;   
            
            if ( bit_number = byte_per_pixel - 1) then -- pixel ausgabe
                  px_count := px_count + 1;
                  bit_number := 0;
            else
                  bit_number := bit_number + 1;
             end if; 
						         			     
      end loop;
	
		
		
      wait; -- one shot at time zero,
      
      end if; -- reset
      
    end process read_file;
	 
	 
	 clk_domain_latch : process(pclk, resetn)
	 begin
	 
 
	 if resetn = '0' then
		pixel_out_hsync <= '0' ;
		pixel_out_vsync <= '1' ;
		pixel_out_href <= '0';		
		pixel_data <= (others => '0');
	 elsif falling_edge(pclk) then
--		pixel_out_clk <= temp_pixel_clock ;
	    pixel_out_href <= temp_href;
		pixel_out_hsync <= temp_hsync ;
		pixel_out_vsync <= temp_vsync ;
		pixel_data <= data ;
	 end if ;
	 end process ;
	 

end BMP_to_OV7670;
