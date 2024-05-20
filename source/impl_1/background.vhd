library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity background is
generic
	(food_width : integer := 20; -- food size as 10 pixels
	 head_width : integer := 20; -- head size as 10 pixels
	 snake_begin_x : integer := 150; -- initial snake position of x
	 snake_begin_y : integer := 225; -- initial snake position of y
	 snake_length_begin : integer := 1; -- initial snake length of 1
	 snake_length_max : integer := 20; -- max snake size 10
	 food_begin_x : integer := 400; -- initial food position x
	 food_begin_y : integer := 250 -- initial food position y
	);
  port(
  		control : in unsigned(7 downto 0);
		clk : in std_logic;
		row, col : in std_logic_vector(15 downto 0);
		valid : in std_logic;
		rgbVal : in std_logic_vector(5 downto 0);
		RGB : out std_logic_vector(5 downto 0) 
  );
end background;

architecture synth of background is
--signal rgbVal : std_logic_vector(5 downto 0);
	-- xy position represented in 32 bits --------- 
	-----------------------------------------------
	-- 16 bit : x position | 16 bit : y position --
	-----------------------------------------------
	
	subtype xy is std_logic_vector(31 downto 0);
	type xys is array (integer range <>) of xy;
	signal random_xy : unsigned(31 downto 0); -- random food position that will be assigned later
	signal snake_length : integer range 0 to snake_length_max; -- setting the range of snake length
	signal snake_mesh_xy : xys(0 to snake_length_max - 1); -- snake body represented in the array of max size
	signal food_xy : xy; -- food position repsented in 32 bits
	
	signal start : std_logic := '0';
begin
	--moving the snake --
	process(clk) 
		
		constant snake_speed : signed(15 downto 0) := to_signed(7, 16); --speed of the snake --
		variable snake_head_xy_future : xy := (others => '0'); --next position of snake head
		variable food_xy_future : xy := (others => '0'); -- next position of food
		variable snake_length_future : integer := 0; -- next length of snake body
		variable dx, dy : signed(15 downto 0) := (others => '0'); -- difference between food pos and snake head pos
		variable inited : std_logic := '0'; -- games starts when this is '1'
		variable up, down, rig, lef : std_logic := '0'; -- stores the direction

	begin
		food_xy <= food_xy_future; -- initial food position
		snake_length <= snake_length_future; -- initial snake length
		
		if (inited = '0') then
			--reset snake length -- 
			snake_length_future := snake_length_begin;
			--set food position --
			food_xy_future(31 downto 16) := std_logic_vector(to_signed(food_begin_x, 16));
			food_xy_future(15 downto 0) := std_logic_vector(to_signed(food_begin_y, 16));
			--set head position--
			snake_head_xy_future(31 downto 16) := std_logic_vector(to_signed(snake_begin_x, 16));
			snake_head_xy_future(15 downto 0) := std_logic_vector(to_signed(snake_begin_y, 16));
			--set snake position--
			for i in 0 to snake_length_max - 1 loop
				snake_mesh_xy(i) <= snake_head_xy_future;
			end loop;
			inited := '1';
			if snake_length = snake_length_max then
				start <= '0';
				inited := '0';
			end if;
		elsif rising_edge(clk) then
		--move accordingly to the controller --
		case control is
			--up--
			when("11110111") => 
				--subtract snake speed to y val of snake move up the head of snake
				snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) - snake_speed);
				up := '1';
				down := '0';
				rig := '0';
				lef := '0';
			--right--
			when("11111110") =>
				--add snake speed to x val of snake to move right
				snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) + snake_speed);
				up := '0';
				down := '0';
				rig := '1';
				lef := '0';
			--down
			when("11111011") =>
				--add snake speed to y val of snake move down the head of snake
				snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) + snake_speed);
				up := '0';
				down := '1';
				rig := '0';
				lef := '0';
			--left--
			when("11111101") =>
				--subtract snake speed to x val of snake to move right
				snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) - snake_speed);
				up := '0';
				down := '0';
				rig := '0';
				lef := '1';	
			when("11101111") => 
					start <= '1';
					if (up = '1') then 
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) - snake_speed);
				elsif (down = '1') then
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) + snake_speed);
				elsif (rig = '1') then
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) + snake_speed);
				elsif (lef = '1') then
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) - snake_speed);
				else	
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)));
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)));
				end if;
			when others =>
				if (up = '1') then 
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) - snake_speed);
				elsif (down = '1') then
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)) + snake_speed);
				elsif (rig = '1') then
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) + snake_speed);
				elsif (lef = '1') then
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)) - snake_speed);
				else	
					snake_head_xy_future(15 downto 0) := std_logic_vector(signed(snake_head_xy_future(15 downto 0)));
					snake_head_xy_future(31 downto 16) := std_logic_vector(signed(snake_head_xy_future(31 downto 16)));
				end if;
		end case;
			--updates the body of snake--
			for i in snake_length_max - 1 downto 1 loop
				snake_mesh_xy(i) <= snake_mesh_xy(i - 1);
			end loop;
			snake_mesh_xy(0) <= snake_head_xy_future; -- push new head to snake body queue
			
			--boundary check
			if (signed(snake_head_xy_future(31 downto 16)) < 0 or
				signed(snake_head_xy_future(31 downto 16)) >= 640 or
				signed(snake_head_xy_future(15 downto 0)) < 0 or
				signed(snake_head_xy_future(15 downto 0)) >= 480) then
				inited := '0';
				start <= '0';
				up := '0';
				down := '0';
				rig := '0';
				lef := '0';	
			end if;
			
			--food check
			dx := abs(signed(snake_head_xy_future(31 downto 16)) - signed(food_xy_future(31 downto 16)));
			dy := abs(signed(snake_head_xy_future(15 downto 0)) - signed(food_xy_future(15 downto 0)));
			if (dy < (food_width + head_width) / 2 and
				dx < (food_width + head_width) / 2) then
				--grow the snake as it ate
				snake_length_future := snake_length_future + 1;
				--change food position
				food_xy_future := std_logic_vector(random_xy);
			end if;
		end if;
			
    end process;
	process (clk)
		--variable random_xy : unsigned(31 downto 0); -- random food position that will be assigned later
		variable random_x : unsigned(15 downto 0) := (others => '0');
		variable random_y : unsigned(15 downto 0) := (others => '0');
		begin
			--generate random number
			if (random_x > to_unsigned(619, 16)) then
				random_x := to_unsigned(20, 16);
			elsif (random_x > to_unsigned(519, 16) or random_x < to_unsigned(119, 16)) then
				random_x := to_unsigned(200, 16);
			end if;
				random_x := random_x + 5;
			
			random_xy(31 downto 16) <= random_x;
			if (random_y > to_unsigned(459, 16)) then
				random_y := to_unsigned(20, 16);
			elsif (random_y > to_unsigned(409, 16) or random_y < to_unsigned(69, 16)) then
				random_y := to_unsigned(130, 16);
			end if;
				random_y := random_y + 5;
			
			random_xy(15 downto 0) <= random_y;
	end process;
			--start
	process(snake_length, snake_mesh_xy, food_xy, valid)
		-- x and y distance from body part or food
		variable dx, dy : signed(15 downto 0) := (others => '0');
		--if current pixel belongs to body or food
		variable is_body, is_food : std_logic := '0';
		variable rg : std_logic_vector(5 downto 0); 
		begin
			if (valid = '1') then
				-- draw body
				is_body := '0';
				for i in 0 to snake_length_max - 1 loop
					dx := abs(signed(col) - signed(snake_mesh_xy(i)(31 downto 16)));
					dy := abs(signed(row) - signed(snake_mesh_xy(i)(15 downto 0)));
					if(i < snake_length) then -- if is valid snake body
						if(dx < head_width / 2 and dy < head_width / 2) then
							is_body := '1';
						end if;
					end if;
				end loop;
				--color of body--
				--draw food
				dx := abs(signed(col) - signed(food_xy(31 downto 16)));
				dy := abs(signed(row) - signed(food_xy(15 downto 0)));
			if (dx < food_width / 2 and dy < food_width / 2 ) then
					is_food := '1';
				else 
					is_food := '0';
				end if;
			if (is_body = '1') then
					rg := "001100";
				--color of food--
				elsif (is_food = '1') then
					rg := "110000";
				else
					rg := "000000";
			end if; 
				--draw background--
		RGB <= rg when(start) else rgbVal; 
			else
				RGB <= "000000";
		end if;
	end process;
end;