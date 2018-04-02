--Testbench file for testing the components of EE 443 Lab 5.
--Comment out the component sections of the object to skip its testing.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all ;
--
library std;
use std.textio.all;

--********************************
--***  Enter user library here ***
--********************************
library work;
use work.LibraryCard.all;
----------------------------------

entity Lab5Testbench is 
	port(dummyVariable: in std_logic);
end Lab5Testbench;

architecture behavior of Lab5Testbench is

--********************************
--*** Enter user components here if a user library is not defined
--********************************

----------------------------------

	signal sim_clk: std_logic := '0';
	constant sim_clk_period : time := 5 ns;
	--termination signals
	signal failed : integer := 0;
	signal done : boolean := false;--, done_file_i, done_file_o : boolean := false;

--********************************
-- Enter the port signals that will conect to user components
--********************************
	--PINV4
	signal PINV4_in, PINV4_out: std_logic_vector(3 downto 0);
	signal PINV4_en: std_logic;
	signal PINV4_failed : integer := 0;
	signal PINV4_done, PINV4_done_file_i, PINV4_done_file_o, PINV4_written : boolean := false;
	
	--MUX4x4
	signal MUX4x4_A, MUX4x4_B, MUX4x4_C, MUX4x4_D, MUX4x4_F: std_logic_vector(3 downto 0);
	signal MUX4x4_sel: std_logic_vector(1 downto 0);
	signal MUX4x4_failed : integer := 0;
	signal MUX4x4_done, MUX4x4_done_file_i, MUX4x4_done_file_o, MUX4x4_written : boolean := false;
	
	--BWOR4
	signal BWOR4_A, BWOR4_B, BWOR4_F: std_logic_vector(3 downto 0);
	signal BWOR4_failed : integer := 0;
	signal BWOR4_done, BWOR4_done_file_i, BWOR4_done_file_o, BWOR4_written : boolean := false;
	
	--BWAND4
	signal BWAND4_A, BWAND4_B, BWAND4_F: std_logic_vector(3 downto 0);
	signal BWAND4_failed : integer := 0;
	signal BWAND4_done, BWAND4_done_file_i, BWAND4_done_file_o, BWAND4_written : boolean := false;
	
	--ADD4
	signal ADD4_A, ADD4_B, ADD4_F : std_logic_vector(3 downto 0);
	signal ADD4_Cin, ADD4_Cout: std_logic;
	signal ADD4_failed : integer := 0;
	signal ADD4_done, ADD4_done_file_i, ADD4_done_file_o, ADD4_written : boolean := false;

----------------------------------

begin
sim_clk <= not sim_clk after sim_clk_period when not done else '0';

--********************************
-- Port map user components
--********************************
	PINV4_dut:  PINV4    port map(PINV4_in(3 downto 0), PINV4_en, PINV4_out(3 downto 0));
	MUX4x4_dut: MUX4x4   port map(MUX4x4_A(3 downto 0), MUX4x4_B(3 downto 0), MUX4x4_C(3 downto 0), MUX4x4_D(3 downto 0), MUX4x4_sel(1 downto 0), MUX4x4_F(3 downto 0));
	BWOR4_dut:  BWOR4    port map(BWOR4_A(3 downto 0), BWOR4_B(3 downto 0), BWOR4_F(3 downto 0));
	BWAND4_dut: BWAND4   port map(BWAND4_A(3 downto 0), BWAND4_B(3 downto 0), BWAND4_F(3 downto 0));
	ADD4_dut:   ADD4     port map(ADD4_A(3 downto 0), ADD4_B(3 downto 0), ADD4_Cin, ADD4_F(3 downto 0), ADD4_Cout);
----------------------------------

--*** The rest of this is split into sections for testing one component at a time.
--*** Each section follows the same layout. TestingProcess, VerifyingProcess, ReportingProcess
--*** Signals are changed on rising edge of sim_clk, then the values are compared to the expected values on the falling edge of sim_clk
--*** TestingProcess: Read inputs from a .txt file and place the value on the input pins of the component
--*** VerifyingProcess: Reads the expected output from a .txt file and compares it with the output of the component. Monitors errors
--*** ReportingProcess: When the input or output .txt file ends, outputs a message saying the circuit passed or how many times it failed.

--********************************
-- Component under test: PINV4
--********************************
	PINV4_TestingProcess: process(sim_clk)
		variable PINV4_l : line;
		file PINV4_input : text is "\InOutFiles\PINV4_input.txt";
		variable PINV4_in_i : std_logic_vector(3 downto 0);
		variable PINV4_en_i : std_logic;
	begin
		if sim_clk'event and sim_clk = '1' then
			if not endfile(PINV4_input) then
				readline(PINV4_input, PINV4_l);
				read(PINV4_l, PINV4_en_i);
				read(PINV4_l, PINV4_in_i(3 downto 0));
				PINV4_in(3 downto 0) <= PINV4_in_i(3 downto 0);
				PINV4_en <= PINV4_en_i;
			else
				PINV4_done_file_i <= true;
			end if;
		end if;
	end process;
	
	PINV4_VerifyingProcess: process(sim_clk)
		variable PINV4_l, PINV4_l_out : line;
		variable PINV4_out_o : std_logic_vector(3 downto 0);
		file PINV4_output : text is "\InOutFiles\PINV4_output.txt";
	begin
		if sim_clk'event and sim_clk = '0' then
			if not endfile(PINV4_output) then
				readline(PINV4_output, PINV4_l);
				read(PINV4_l, PINV4_out_o(3 downto 0));
				--comparing section
				if not(PINV4_out_o(3 downto 0) = PINV4_out(3 downto 0)) then
					PINV4_failed <= PINV4_failed + 1;
					write(PINV4_l_out, string'("Error # "));
					write(PINV4_l_out, PINV4_failed);
					write(PINV4_l_out, string'(": Error in PINV4 signals: "));
					write(PINV4_l_out, string'("For inputs in="));
					write(PINV4_l_out, PINV4_in(3 downto 0));
					write(PINV4_l_out, string'(", en="));
					write(PINV4_l_out, PINV4_en);
					write(PINV4_l_out, string'(", out should be "));
					write(PINV4_l_out, PINV4_out_o(3 downto 0));
					write(PINV4_l_out, string'(" not "));
					write(PINV4_l_out, PINV4_out(3 downto 0));
					writeline(output, PINV4_l_out);
				end if;
			else
				PINV4_done_file_o <= true;
			end if;
		end if;
	end process;
	
	PINV4_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (PINV4_done_file_i or PINV4_done_file_o) and not(PINV4_written) then
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				if PINV4_failed > 0 then
					write(lout, string'("*** PINV4 Circuit failed "));
					write(lout, PINV4_failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
					write(lout, string'("*** PINV4 circuit passed all tests ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				PINV4_done <= true;
				PINV4_written <= true;
			end if;
		end if;
	end process;
----------------------------------

--********************************
-- Component under test: MUX4x4
--********************************
	MUX4x4_TestingProcess: process(sim_clk)
		variable MUX4x4_l : line;
		file MUX4x4_input : text is "\InOutFiles\MUX4x4_input.txt";
		variable MUX4x4_A_i,MUX4x4_B_i,MUX4x4_C_i,MUX4x4_D_i : std_logic_vector(3 downto 0);
		variable MUX4x4_sel_i : std_logic_vector(1 downto 0);
	begin
		if sim_clk'event and sim_clk = '1' then
			if not endfile(MUX4x4_input) then
				readline(MUX4x4_input, MUX4x4_l);
				read(MUX4x4_l, MUX4x4_A_i(3 downto 0));
				read(MUX4x4_l, MUX4x4_B_i(3 downto 0));
				read(MUX4x4_l, MUX4x4_C_i(3 downto 0));
				read(MUX4x4_l, MUX4x4_D_i(3 downto 0));
				read(MUX4x4_l, MUX4x4_sel_i(1 downto 0));
				MUX4x4_A(3 downto 0) <= MUX4x4_A_i(3 downto 0);
				MUX4x4_B(3 downto 0) <= MUX4x4_B_i(3 downto 0);
				MUX4x4_C(3 downto 0) <= MUX4x4_C_i(3 downto 0);
				MUX4x4_D(3 downto 0) <= MUX4x4_D_i(3 downto 0);
				MUX4x4_sel(1 downto 0) <= MUX4x4_sel_i(1 downto 0);
			else
				MUX4x4_done_file_i <= true;
			end if;
		end if;
	end process;
	
	MUX4x4_VerifyingProcess: process(sim_clk)
		variable MUX4x4_l, MUX4x4_l_out : line;
		variable MUX4x4_F_o : std_logic_vector(3 downto 0);
		file MUX4x4_output : text is "\InOutFiles\MUX4x4_output.txt";
	begin
		if sim_clk'event and sim_clk = '0' then
			if not endfile(MUX4x4_output) then
				readline(MUX4x4_output, MUX4x4_l);
				read(MUX4x4_l, MUX4x4_F_o(3 downto 0));
				--comparing section
				if not(MUX4x4_F_o(3 downto 0) = MUX4x4_F(3 downto 0)) then
					MUX4x4_failed <= MUX4x4_failed + 1;
					write(MUX4x4_l_out, string'("Error # "));
					write(MUX4x4_l_out, MUX4x4_failed);
					write(MUX4x4_l_out, string'(": Error in MUX4x4 signals: "));
					write(MUX4x4_l_out, string'("For input sel="));
					write(MUX4x4_l_out, MUX4x4_sel(1 downto 0));
					write(MUX4x4_l_out, string'(", F should be "));
					write(MUX4x4_l_out, MUX4x4_F_o(3 downto 0));
					write(MUX4x4_l_out, string'(" not "));
					write(MUX4x4_l_out, MUX4x4_F(3 downto 0));
					writeline(output, MUX4x4_l_out);
				end if;
			else
				MUX4x4_done_file_o <= true;
			end if;
		end if;
	end process;
	
	MUX4x4_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (MUX4x4_done_file_i or MUX4x4_done_file_o) and not(MUX4x4_written) then
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				if MUX4x4_failed > 0 then
					write(lout, string'("*** MUX4x4 Circuit failed "));
					write(lout, MUX4x4_failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
					write(lout, string'("*** MUX4x4 circuit passed all tests ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				MUX4x4_done <= true;
				MUX4x4_written <= true;
			end if;
		end if;
	end process;
----------------------------------

--********************************
-- Component under test: BWOR4
--********************************
	BWOR4_TestingProcess: process(sim_clk)
		variable BWOR4_l : line;
		file BWOR4_input : text is "\InOutFiles\BWOR4_input.txt";
		variable BWOR4_A_i,BWOR4_B_i : std_logic_vector(3 downto 0);
	begin
		if sim_clk'event and sim_clk = '1' then
			if not endfile(BWOR4_input) then
				readline(BWOR4_input, BWOR4_l);
				read(BWOR4_l, BWOR4_A_i(3 downto 0));
				read(BWOR4_l, BWOR4_B_i(3 downto 0));
				BWOR4_A(3 downto 0) <= BWOR4_A_i(3 downto 0);
				BWOR4_B(3 downto 0) <= BWOR4_B_i(3 downto 0);
			else
				BWOR4_done_file_i <= true;
			end if;
		end if;
	end process;
	
	BWOR4_VerifyingProcess: process(sim_clk)
		variable BWOR4_l, BWOR4_l_out : line;
		variable BWOR4_F_o : std_logic_vector(3 downto 0);
		file BWOR4_output : text is "\InOutFiles\BWOR4_output.txt";
	begin
		if sim_clk'event and sim_clk = '0' then
			if not endfile(BWOR4_output) then
				readline(BWOR4_output, BWOR4_l);
				read(BWOR4_l, BWOR4_F_o(3 downto 0));
				--comparing section
				if not(BWOR4_F_o(3 downto 0) = BWOR4_F(3 downto 0)) then
					BWOR4_failed <= BWOR4_failed + 1;
					write(BWOR4_l_out, string'("Error # "));
					write(BWOR4_l_out, BWOR4_failed);
					write(BWOR4_l_out, string'(": Error in BWOR4 signals: "));
					write(BWOR4_l_out, string'("For input A="));
					write(BWOR4_l_out, BWOR4_A(3 downto 0));
					write(BWOR4_l_out, string'(" and input B="));
					write(BWOR4_l_out, BWOR4_B(3 downto 0));					
					write(BWOR4_l_out, string'(", F should be "));
					write(BWOR4_l_out, BWOR4_F_o(3 downto 0));
					write(BWOR4_l_out, string'(" not "));
					write(BWOR4_l_out, BWOR4_F(3 downto 0));
					writeline(output, BWOR4_l_out);
				end if;
			else
				BWOR4_done_file_o <= true;
			end if;
		end if;
	end process;
	
	BWOR4_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (BWOR4_done_file_i or BWOR4_done_file_o) and not(BWOR4_written) then
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				if BWOR4_failed > 0 then
					write(lout, string'("*** BWOR4 Circuit failed "));
					write(lout, BWOR4_failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
					write(lout, string'("*** BWOR4 circuit passed all tests ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				BWOR4_done <= true;
				BWOR4_written <= true;
			end if;
		end if;
	end process;
----------------------------------

--********************************
-- Component under test: BWAND4
--********************************
	BWAND4_TestingProcess: process(sim_clk)
		variable BWAND4_l : line;
		file BWAND4_input : text is "\InOutFiles\BWAND4_input.txt";
		variable BWAND4_A_i,BWAND4_B_i : std_logic_vector(3 downto 0);
	begin
		if sim_clk'event and sim_clk = '1' then
			if not endfile(BWAND4_input) then
				readline(BWAND4_input, BWAND4_l);
				read(BWAND4_l, BWAND4_A_i(3 downto 0));
				read(BWAND4_l, BWAND4_B_i(3 downto 0));
				BWAND4_A(3 downto 0) <= BWAND4_A_i(3 downto 0);
				BWAND4_B(3 downto 0) <= BWAND4_B_i(3 downto 0);
			else
				BWAND4_done_file_i <= true;
			end if;
		end if;
	end process;
	
	BWAND4_VerifyingProcess: process(sim_clk)
		variable BWAND4_l, BWAND4_l_out : line;
		variable BWAND4_F_o : std_logic_vector(3 downto 0);
		file BWAND4_output : text is "\InOutFiles\BWAND4_output.txt";
	begin
		if sim_clk'event and sim_clk = '0' then
			if not endfile(BWAND4_output) then
				readline(BWAND4_output, BWAND4_l);
				read(BWAND4_l, BWAND4_F_o(3 downto 0));
				--comparing section
				if not(BWAND4_F_o(3 downto 0) = BWAND4_F(3 downto 0)) then
					BWAND4_failed <= BWAND4_failed + 1;
					write(BWAND4_l_out, string'("Error # "));
					write(BWAND4_l_out, BWAND4_failed);
					write(BWAND4_l_out, string'(": Error in BWAND4 signals: "));
					write(BWAND4_l_out, string'("For input A="));
					write(BWAND4_l_out, BWAND4_A(3 downto 0));
					write(BWAND4_l_out, string'(" and input B="));
					write(BWAND4_l_out, BWAND4_B(3 downto 0));					
					write(BWAND4_l_out, string'(", F should be "));
					write(BWAND4_l_out, BWAND4_F_o(3 downto 0));
					write(BWAND4_l_out, string'(" not "));
					write(BWAND4_l_out, BWAND4_F(3 downto 0));
					writeline(output, BWAND4_l_out);
				end if;
			else
				BWAND4_done_file_o <= true;
			end if;
		end if;
	end process;
	
	BWAND4_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (BWAND4_done_file_i or BWAND4_done_file_o) and not(BWAND4_written) then
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				if BWAND4_failed > 0 then
					write(lout, string'("*** BWAND4 Circuit failed "));
					write(lout, BWAND4_failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
					write(lout, string'("*** BWAND4 circuit passed all tests ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				BWAND4_done <= true;
				BWAND4_written <= true;
			end if;
		end if;
	end process;
----------------------------------

--********************************
-- Component under test: ADD4
--********************************
	ADD4_TestingProcess: process(sim_clk)
		variable ADD4_l : line;
		file ADD4_input : text is "\InOutFiles\ADD4_input.txt";
		variable ADD4_A_i,ADD4_B_i : std_logic_vector(3 downto 0);
		variable ADD4_Cin_i : std_logic;
	begin
		if sim_clk'event and sim_clk = '1' then
			if not endfile(ADD4_input) then
				readline(ADD4_input, ADD4_l);
				read(ADD4_l, ADD4_A_i(3 downto 0));
				read(ADD4_l, ADD4_B_i(3 downto 0));
				read(ADD4_l, ADD4_Cin_i);
				ADD4_A(3 downto 0) <= ADD4_A_i(3 downto 0);
				ADD4_B(3 downto 0) <= ADD4_B_i(3 downto 0);
				ADD4_Cin <= ADD4_Cin_i;
			else
				ADD4_done_file_i <= true;
			end if;
		end if;
	end process;
	
	ADD4_VerifyingProcess: process(sim_clk)
		variable ADD4_l, ADD4_l_out : line;
		variable ADD4_F_o : std_logic_vector(3 downto 0);
		variable ADD4_Cout_o : std_logic;
		
		file ADD4_output : text is "\InOutFiles\ADD4_output.txt";
	begin
		if sim_clk'event and sim_clk = '0' then
			if not endfile(ADD4_output) then
				readline(ADD4_output, ADD4_l);
				read(ADD4_l, ADD4_Cout_o);
				read(ADD4_l, ADD4_F_o(3 downto 0));
				--comparing section
				if ((not(ADD4_F_o(3 downto 0) = ADD4_F(3 downto 0))) or (not(ADD4_Cout_o = ADD4_Cout))) then
					ADD4_failed <= ADD4_failed + 1;
					write(ADD4_l_out, string'("Error # "));
					write(ADD4_l_out, ADD4_failed);
					write(ADD4_l_out, string'(": Error in ADD4 signals: "));
					write(ADD4_l_out, string'("For input A="));
					write(ADD4_l_out, ADD4_A(3 downto 0));
					write(ADD4_l_out, string'(" and input B="));
					write(ADD4_l_out, ADD4_B(3 downto 0));
					write(ADD4_l_out, string'(" and input Cin="));
					write(ADD4_l_out, ADD4_Cin);					
					write(ADD4_l_out, string'(", F should be "));
					write(ADD4_l_out, ADD4_F_o(3 downto 0));	
					write(ADD4_l_out, string'(", and Cout should be "));
					write(ADD4_l_out, ADD4_Cout_o);						
					write(ADD4_l_out, string'(", not F = "));
					write(ADD4_l_out, ADD4_F(3 downto 0));						
					write(ADD4_l_out, string'(", and Cout = "));
					write(ADD4_l_out, ADD4_Cout);
					writeline(output, ADD4_l_out);
				end if;
			else
				ADD4_done_file_o <= true;
			end if;
		end if;
	end process;
	
	ADD4_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (ADD4_done_file_i or ADD4_done_file_o) and not(ADD4_written) then
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				if ADD4_failed > 0 then
					write(lout, string'("*** ADD4 Circuit failed "));
					write(lout, ADD4_failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
					write(lout, string'("*** ADD4 circuit passed all tests ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				ADD4_done <= true;
				ADD4_written <= true;
			end if;
		end if;
	end process;
----------------------------------

	Overview_ReportingProcess: process(sim_clk)
		variable lout: line;
	begin
		if sim_clk'event and sim_clk = '1' then
			if (PINV4_done and MUX4x4_done and BWOR4_done and BWAND4_done and ADD4_done) then
				write(lout, string'(" PINV4_failed = "));
				write(lout, PINV4_failed);
				write(lout, string'(" MUX4x4_failed = "));
				write(lout, MUX4x4_failed);
				write(lout, string'(" BWOR4_failed = "));
				write(lout, BWOR4_failed);
				write(lout, string'(" BWAND4_failed = "));
				write(lout, BWAND4_failed);
				write(lout, string'(" ADD4_failed = "));
				write(lout, ADD4_failed);			
				

				failed <= ADD4_failed;--failed + PINV4_failed + MUX4x4_failed + BWOR4_failed + BWAND4_failed + ADD4_failed;
				
				write(lout, string'(" failed = "));
				write(lout, failed);
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				
				if failed > 0 then
				
				
					write(lout, string'("*** Circuits failed "));
					write(lout, failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				else
				
					write(lout, string'("*** Circuits passed all tests ***"));
					writeline(output, lout);
					--
					write(lout, string'("*** Circuits failed "));
					write(lout, failed);
					write(lout, string'(" times, ***"));
					writeline(output, lout);
				end if;
				write(lout, string'("***--------------------------------***"));
				writeline(output, lout);
				done <= true;
			end if;
		end if;
	end process;
	
end behavior;



