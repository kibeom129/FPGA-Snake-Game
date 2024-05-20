library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity vga is
  port(
		clk : in std_logic; -- taking in the outcore_o
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		valid : out std_logic;
		frameclk : out std_logic;
		row, col : out std_logic_vector(15 downto 0)
  );
end vga;

architecture synth of vga is


signal row_count : unsigned(15 downto 0) := 16d"0";
signal col_count : unsigned(15 downto 0) := 16d"0";
signal validH : std_logic;
signal validV : std_logic;
begin
	process(clk) begin
		if rising_edge(clk) then
			if col_count = 16d"799" then 
				col_count <= 16d"0";
				row_count <= row_count + '1';
			else
				col_count <= col_count + '1';
			end if;
			if row_count = 16d"524" then
				row_count <= 16d"0";
			end if;
			 if row_count = 16d"262" and col_count = 16d"650" then
				frameclk <= not frameclk;
			end if;
		end if;

	end process;
	HSYNC <= '0' when (col_count >= 16d"656" and col_count < 16d"752") else '1';
	VSYNC <= '0' when (row_count >= 16d"490" and row_count < 16d"493") else '1';
	row <= std_logic_vector(row_count);
	col <= std_logic_vector(col_count);
	validH <= '1' when (col_count >= 16d"0" and col_count < 16d"641") else '0';
	validV <= '1' when (row_count >= 16d"0" and row_count < 16d"481") else '0';
	valid <= validH and validV;
end;
