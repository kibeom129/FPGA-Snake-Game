library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity top is
  port(
datain : in std_logic;
NESclk : out std_logic;
output : out unsigned(7 downto 0);
latch : out std_logic;
osc : in std_logic;
HSYNC_out : out std_logic;
VSYNC_out : out std_logic;
RGB : out std_logic_vector(5 downto 0);
osc_out : out std_logic
  );
end top;

architecture synth of top is

component HSOSC is generic (CLKHF_DIV : String := "0b00");
    port(
        CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
        CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
        CLKHF : out std_logic := 'X'); -- Clock output
end component;

component NEScontroller is
port(
datain : in std_logic;
NESclk : out std_logic;
latch : out std_logic;
output : out unsigned(7 downto 0)
);
end component;

component mypll is
    port(
        ref_clk_i: in std_logic;
        rst_n_i: in std_logic;
        outcore_o: out std_logic;
        outglobal_o: out std_logic
    );
end component;


component vga is
  port(
		clk : in std_logic; -- taking in the outcore_o
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		valid : out std_logic;
		frameclk : out std_logic;
		row, col : out std_logic_vector(15 downto 0)
  );
end component;

component background is
  port(
		control : in unsigned(7 downto 0);
		clk : in std_logic;
		row, col : in std_logic_vector(15 downto 0);
		valid : in std_logic;
		rgbVal : in std_logic_vector(5 downto 0);
		RGB : out std_logic_vector(5 downto 0) 
  );
end component;



component start_screen is
  port(
	  clk : in std_logic;
	  xadr: in unsigned(5 downto 0);
	  yadr : in unsigned(4 downto 0); -- 0-1023
	  rgb : out std_logic_vector(5 downto 0)
      );
end component;


signal pll_clk : std_logic;
signal row, col : std_logic_vector(15 downto 0);
signal valid : std_logic;
signal clk : std_logic;
signal clk_rom : std_logic;
signal frameclk : std_logic;
signal control : unsigned(7 downto 0);
signal rom_data : std_logic_vector(5 downto 0);  -- Data from ROM
signal segments : std_logic_vector(6 downto 0);		

begin

myOsc : HSOSC generic map (CLKHF_DIV => "0b00") port map (CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);
myNES : NEScontroller port map (datain => datain, NESclk => NESclk, latch => latch, output => output);
pat_gen : background port map(control => output,  clk => frameclk, row => row, col => col, valid => valid, rgbVal => rom_data, RGB => RGB);
vga_clk : vga port map(clk => pll_clk, HSYNC => HSYNC_out, VSYNC => VSYNC_out, row => row, col => col, valid => valid, frameclk => frameclk);
pll : mypll port map (ref_clk_i => osc, outglobal_o => pll_clk, outcore_o => osc_out, rst_n_i => '1');
rom_inst : start_screen port map (clk => pll_clk, xadr => unsigned(col(8 downto 3)), yadr => unsigned(row(10 downto 6)), rgb => rom_data);



end;