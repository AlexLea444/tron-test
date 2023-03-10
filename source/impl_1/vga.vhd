library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
	port(
			clk : in std_logic;
			hsync : out std_logic;
			vsync : out std_logic;
			valid : out std_logic;
			game_clk : out std_logic;
			row : out unsigned(9 downto 0);
			col : out unsigned(9 downto 0)
			);
end;

architecture synth of vga is
-- Counters to cycle through rows and columns
signal hor_count : unsigned(9 downto 0);
signal ver_count : unsigned(9 downto 0);
-- Signals for game timing
signal gameBC : unsigned(2 downto 0);
signal frame_clk : std_logic;
begin
	process(clk) begin
		if rising_edge(clk) then
			if (hor_count = 10d"799") then
				if (ver_count = 10d"524") then
					ver_count <= "0000000000";
				else
					ver_count <= ver_count + '1';
				end if;
				hor_count <= "0000000000";
			else
				hor_count <= hor_count + '1';
			end if;
		end if;
	end process;
	hsync <= '0' when ((hor_count >= 10d"656") and (hor_count < 10d"752")) else '1';
	vsync <= '0' when ((ver_count >= 10d"490") and (ver_count < 10d"492")) else '1';
	valid <= '1' when ((hor_count < 10d"640") and (ver_count < 10d"480")) else '0';
	
	--creates 60Hz frame_clk, then slows this down via a 3-bit binary counter for game_clk
	frame_clk <= '1' when (ver_count > 10d"480") else '0';
	process(frame_clk) begin
		if rising_edge(frame_clk) then
			gameBC <= gameBC + 3d"1";
		end if;
	end process;
	game_clk <= gameBC(2);
	
	row <= ver_count;
	col <= hor_count;
	
end;
