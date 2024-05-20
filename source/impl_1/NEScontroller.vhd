library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity NEScontroller is
port(
datain : in std_logic;
NESclk : out std_logic;
latch : out std_logic;
output : out unsigned(7 downto 0)
);
end NEScontroller;

architecture synth of NEScontroller is

component HSOSC is generic (CLKHF_DIV : String := "0b00");
    port(
        CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
        CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
        CLKHF : out std_logic := 'X'); -- Clock output
end component;

signal counter : unsigned(20 downto 0) := (others => '0');
signal clk : std_logic;
signal NEScount : unsigned(3 downto 0) := (others => '0');
signal shiftRegister : unsigned(7 downto 0);

begin

osc : HSOSC generic map (CLKHF_DIV => "0b00") port map (CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);

process(clk, NESclk) begin
if rising_edge(clk) then
	counter <= counter + 1;
	latch <= '1' when NEScount = "1111" else '0';
end if;
NESclk <= counter(8); -- NESclk is the 8th bit
NEScount <= counter(12 downto 9);

if rising_edge(NESclk) and NEScount < 4d"8" then -- NESclk is 1, and after it's been less than 8 clock cycles --> do shift register
	shiftRegister <= shiftRegister(6 downto 0) & datain;
end if;

if rising_edge(latch) then
	output <= shiftRegister;
end if;


end process;


end;
