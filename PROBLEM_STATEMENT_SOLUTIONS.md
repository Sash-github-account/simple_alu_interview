# Lightelligence RTL Design Interview Question

## Overview
In this problem, we are looking for you to design and implement an unsigned 8-bit integer ALU.
We've provided stubs for the functional blocks that comprise the ALU. Your task is to connect them with the appropriate muxing to create an ALU that handles the following unsigned 8-bit integer operations:

 - Add
 - Subtract
 - Multiply
 - Divide
 - Arithmetic Mean

alu.sv is provided with a basic interface but is otherwise left-blank for you to fill in.
Since only stubs are provide for the functional blocks, you are not expected to functionally verify your design with a testbench.
We are looking for a general sense of your skills in the following areas:

 - Digital design
 - Ability to transform requirements into a maintainable and performant solution
 - RTL code quality

Please write-down all assumptions and questions you have.

Solution:
          I have updated the alu.sv file with the solution and left comments about the assumptions thatI made and questions that I had. 
          Though it was not required, I have also simulated the design in eda-playground, using a UVM test-bench that I use for my own personal projects. I have include the results from the simulation: waveforms and log. I have included this test bench under the folder 'verif'


## Questions
In addition to writing RTL to implement the ALU, please write brief responses to each of the following questions:

 - What are your initial thoughts on power, timing, performance and area?
 
 	Timing: Since my design has multiple stages, meeting timing should be easy.
	
	Performance: Assuming a 1Ghz clock, this ALU can perform up to 100 million operations per second. Further improvement can be achieved by including input FIFOs to buffer both command and data, thus avoiding bubbles in execution.
	
	Area: Based on my assumption about how the inputs are driven, additional hardware(some muxes and ) was required to internally store the command and data, till the operation. The ALU was implemented assuming a more rigorous spec and area can be reduced by a change in specification.
	
	Power: Dynamic power consumption can reduced by appropriate encoding of the FSM states as either gray code or one-hot. This will reduce the number of bits transitions per change of state and hence reduction of dynamic power consumed.
	
 - How does your solution scale with the addition of new functional units or the modification of the underlying data type? How could you support multiple data types?
 
 	The execution FSM is designed to able to handle various scenarios, such as delay between command and data arrival, arithmetic mean computation with capability to wait of data to arrive. Additional functional blocks such as FIFO for command and data can be readily integrated if needed.
 	I have taken advantage of the structures provided in "alu_pkg.svh" throughout my design and any change in data width is automatically supported and needs to changed on in that file.
	
 - What would you suggest to a DV engineer verifying this block?
 
 I would expect the following test cases from the DV engineer:
	1. A constraint random test bench that is capable of generating random opcode and data.
	2. Burst mode ie., commands coming in succession as soon as the result is generated for previous command.
	3. low performance mode ie., there is some amount of delay between successive commands 
	4. delayed arrival of data for arithmetic mean command
	
 - Is your solution maintainable? How does your code read to someone who isn't familar with the design?
 	I have provided appropriate comments corresponding to each section and list out the assumptions made about the spec.
	
 - What tools and hooks would you need to debug this design in a post-silicon environment?
	The flops created post synthesis can be made scan-able along with appropriate stitching of scan chains during synthesis. An addition input interface (such as JTAG) will be required to pass test vectors into the design.
	
We like to read good code and insightful analysis, but we also don't expect candidates to spend more than two hours on this problem.
Our goal is to get a better idea of how you write code and how you think about the implications of your RTL.