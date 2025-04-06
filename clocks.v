module pmod_counter (
	input CLK,
	output P1_1, // Chip select
	output P1_2, // Data
	output P1_4  // Clock
);

// Declare wires to connect to the lookup table
wire [3:0] lut_address;
wire [15:0] lut_data;

reg [15:0] data  = 16'b0000000000000000;

// Instantiate the lookup table
lookup_table my_lut (
    .address(lut_address),
    .data_out(lut_data)
);

wire inverse;
reg dataclock = 1'b0;
reg [24:0] counter = 0; 
//reg [4:0] timer = 0;
reg [3:0] tempcounter = 4'b0000;
reg [3:0] dataloader = 4'b0000;
localparam N = 10;
localparam D = N-6;


// This is my base counter
always @(posedge CLK) begin
	counter <= counter +1;
//	if (counter[N])
//		timer <= timer +1;
end


// This generates the data clock to be sent to the data clock
// This will always be 16 counts per select cycle becasue of the definition of D
always @(posedge counter[D]) begin
	if (counter[N])
		dataclock <= ~dataclock;
end

always @(posedge dataclock) begin
	tempcounter <=tempcounter +1;
end



// This section changes the address of the data loaded from the look up table.
always @(negedge inverse) begin
	dataloader <= dataloader +1;
	data <= lut_data;
end

assign lut_address = dataloader;
assign inverse = ~ counter[N];
assign P1_1 = inverse;
assign P1_2 = data[tempcounter];
assign P1_4 = dataclock;
endmodule





module lookup_table (
    input wire [3:0] address,     // 4-bit address input (16 possible values)
    output reg [15:0] data_out     // 16-bit data output
);

    // Lookup table implementation using a case statement
    always @(*) begin
        case (address)
            4'b0000: data_out = 16'b0000000000000000;  // Address 0 maps to 0x00
            4'b0001: data_out = 16'b1110000000000000;  // Address 0 maps to 0x00
            4'b0010: data_out = 16'b0011100000000000;  // Address 0 maps to 0x00
            4'b0011: data_out = 16'b0000111000000000;  // Address 0 maps to 0x00
            4'b0100: data_out = 16'b0000011100000000;  // Address 0 maps to 0x00
            4'b0101: data_out = 16'b0000000111000000;  // Address 0 maps to 0x00
            4'b0110: data_out = 16'b0000000001110000;  // Address 0 maps to 0x00
            4'b0111: data_out = 16'b1100110011000000;  // Address 0 maps to 0x00
            4'b1000: data_out = 16'b1110111011100000;  // Address 0 maps to 0x00
            4'b1001: data_out = 16'b1111100011110000;  // Address 0 maps to 0x00
            4'b1010: data_out = 16'b1111110111110000;  // Address 0 maps to 0x00
            4'b1011: data_out = 16'b0111111111110000;  // Address 0 maps to 0x00
            4'b1100: data_out = 16'b0011111111100000;  // Address 0 maps to 0x00
            4'b1101: data_out = 16'b0001111111000000;  // Address 0 maps to 0x00
            4'b1110: data_out = 16'b0001000100010000;  // Address 0 maps to 0x00
            4'b1111: data_out = 16'b0011101110010000;  // Address 0 maps to 0x00
            default: data_out = 16'b0000000000000000;  // Address 0 maps to 0x00
        endcase
    end

endmodule
