----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Engineer: Roberto Spatafora, Cosimo Sguanci
-- 
-- Create Date: 20.02.2020 13:25:48
-- Design Name: RL Project - Working Zone
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: RL Project - Working Zone
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_start : in std_logic;
		i_rst : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_address : out std_logic_vector(15 downto 0);
		o_done : out std_logic;
		o_en : out std_logic;
		o_we : out std_logic;
		o_data : out std_logic_vector (7 downto 0)
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
	signal num_clk : std_logic_vector(3 downto 0) := (others => '0');
	signal target : std_logic_vector(7 downto 0) := (others => '0');
	signal current_address_read : std_logic_vector(3 downto 0) := (others => '0');
	signal found : std_logic := '0';
	signal target_group : std_logic_vector(2 downto 0) := (others => '0');
	signal group_data : std_logic_vector(7 downto 0) := (others => '0');
	signal one_hot_converter : std_logic_vector(3 downto 0) := (others => '0');
	signal done_flag : std_logic := '0';

begin
	process (i_clk, i_rst, i_start)
    
	begin
		if rising_edge(i_clk) then

			if (i_start = '1') then

				if (num_clk = 0) then

					o_address <= "0000000000001000";
					o_en <= '1';
					o_we <= '0';
					num_clk <= num_clk + 1;
					o_done <= '0';

				elsif (num_clk = 1) then

					num_clk <= num_clk + 1;
					o_done <= '0';

				elsif (num_clk = 2) then

					target <= i_data;
					o_en <= '1';
					o_we <= '0';
					num_clk <= num_clk + 1;
					o_address <= "000000000000" & current_address_read;
					current_address_read <= std_logic_vector(unsigned(current_address_read) + 1);
					o_done <= '0';

				elsif (num_clk = 3) then

					num_clk <= num_clk + 1;
					o_address <= "000000000000" & current_address_read;
					current_address_read <= std_logic_vector(unsigned(current_address_read) + 1);
					o_done <= '0';
					
				elsif (num_clk > 3 and found = '0' and num_clk < 12) then
					if ((unsigned(target) <= unsigned(i_data) + 3) and (unsigned(target) >= unsigned(i_data))) then
						found <= '1';
						target_group <= std_logic_vector((unsigned(current_address_read(2 downto 0))) - 2);
						group_data <= i_data;
					end if;

					current_address_read <= std_logic_vector(unsigned(current_address_read) + 1);
					o_address <= "000000000000" & current_address_read;
					o_en <= '1';
					o_we <= '0';
					num_clk <= num_clk + 1;
					o_done <= '0';

				elsif (found = '1') then

					o_address <= "0000000000001001";
					one_hot_converter(to_integer(unsigned(target)) - to_integer(unsigned(group_data))) <= '1';
					o_data <= '1' & target_group & one_hot_converter;
					o_en <= '1';
					o_we <= '1';

					if (done_flag = '1') then
						o_done <= '1';
					end if;

					done_flag <= '1';

				elsif (num_clk = 12 and found = '0') then

					o_address <= "0000000000001001";
					o_data <= target;
					o_en <= '1';
					o_we <= '1';
					o_done <= '1';
					done_flag <= '1';

				end if;

				if (done_flag = '1' or i_rst = '1') then

					num_clk <= "0000";
					target <= "00000000";
					current_address_read <= "0000";
					found <= '0';
					target_group <= "000";
					group_data <= "00000000";
					one_hot_converter <= "0000";
					done_flag <= '0';
					
				end if;

			else
				o_done <= '0';

			end if;

		end if;

	end process;
end Behavioral;