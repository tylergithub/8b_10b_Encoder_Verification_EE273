/*
	Example of a single packet:
	Input:
	K.28.1 -> K.28.1 -> K.28.1 -> K.28.1 -> Data -> Data -> ... -> K28.5 

	Output:
	K.28.1 -> K.28.1 -> K.28.1 -> K.28.1 -> Data -> Data -> K.23.7 -> CRC0 -> CRC1 -> CRC2 -> CRC3 -> K.28.5
*/

module dut(
	input clk,						// Rising edge module clock
	input reset,					// Active high module reset
	input pushin,					// Signal indicating data is present for encoding
	input [8:0] datain,				// Input data (The high order bit indicates a control code)
	input startin,					// Indicates the start of a block for disparity generation
	output pushout,					// Output data is present from the module
	output [9:0] dataout,			// 8/10 encoded data for transmission
	output startout					// Indicates the start of a block for transmission
	);

// Internal variables:
enum reg [2:0] {
Reset,
First_four_k281,
Data,
End_k285
} cs,ns;