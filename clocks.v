module pmod_counter (
        input CLK,              // Main clock input
        output P1_1,            // Chip select - Active low signal to enable the external device
        output P1_2,            // Data - Serial data output to the external device
        output P1_4             // Clock - Serial clock for data synchronization
);

// Declare wires to connect to the lookup table - used to store data patterns
wire [5:0] lut_address;         // 5-bit address to select data from lookup table
wire [15:0] lut_data;           // 16-bit data output from the lookup table

reg [15:0] data = 16'b0000000000000000;  // Register to store current data pattern from LUT

// Instantiate the lookup table module
// The lookup table likely contains predefined 16-bit patterns indexed by address
lookup_table my_lut (
    .address(lut_address),      // Connect address input to our lut_address signal
    .data_out(lut_data)         // Connect data output to our lut_data signal
);

wire inverse;                   // Used to generate chip select signal (inverse of counter[N])
reg dataclock = 1'b0;           // Register for generating the serial clock signal
reg [24:0] counter = 0;         // Main counter for timing
reg [5:0] tempcounter = 5'b00000; // Counter to select which bit of data to send
reg [5:0] dataloader = 5'b00000; // Counter to select which pattern to load from LUT
localparam N = 10;              // Timing parameter for chip select frequency
localparam D = N-6;             // Timing parameter for serial clock frequency (4)

// Main counter - increments on every positive edge of the main clock
// This is the timing base for all operations
always @(posedge CLK) begin
        counter <= counter + 1;
end

// Generate the data clock (serial clock output)
// The clock frequency is determined by counter[D] and will toggle when counter[N] is high
// This creates 16 clock cycles per chip select cycle (2^(N-D) = 2^6 = 64 transitions = 32 clock cycles)
always @(posedge counter[D]) begin
        if (counter[N])
                dataclock <= ~dataclock;  // Toggle the clock when counter[N]=1
end

// Increment the bit selection counter on each positive edge of dataclock
// This selects which bit of the 16-bit data word to output
always @(posedge dataclock) begin
        tempcounter <= tempcounter + 1;  // Cycle through bits 0-15 of data word
end

// Load new data from the lookup table when chip select changes from active to inactive
// (on negative edge of inverse signal, which is the same as positive edge of counter[N])
always @(negedge inverse) begin
        dataloader <= dataloader + 1;    // Select next pattern from lookup table
        data <= lut_data;                // Load the new data pattern
end

assign lut_address = dataloader;         // Connect dataloader to lookup table address
assign inverse = ~counter[N];            // Generate inverse signal from counter[N] bit
assign P1_1 = inverse;                   // Connect chip select output (active low)
assign P1_2 = data[tempcounter];         // Connect data output (selected bit from data word)
assign P1_4 = dataclock;                 // Connect clock output
endmodule



module lookup_table (
    input wire [5:0] address,     // 4-bit address input (16 possible values)
    output reg [15:0] data_out     // 16-bit data output
);

    // Lookup table implementation using a case statement
    always @(*) begin
        case (address)
6'b000000: data_out = 16'b0000000000100000;
6'b000001: data_out = 16'b0100110000100000;
6'b000010: data_out = 16'b1010011000100000;
6'b000011: data_out = 16'b0110100100100000;
6'b000100: data_out = 16'b0110001100100000;
6'b000101: data_out = 16'b0010111100100000;
6'b000110: data_out = 16'b0000010010100000;
6'b000111: data_out = 16'b1001001010100000;
6'b001000: data_out = 16'b0111011010100000;
6'b001001: data_out = 16'b0000100110100000;
6'b001010: data_out = 16'b0111010110100000;
6'b001011: data_out = 16'b1110001110100000;
6'b001100: data_out = 16'b0011101110100000;
6'b001101: data_out = 16'b0011011110100000;
6'b001110: data_out = 16'b0001111110100000;
6'b001111: data_out = 16'b0111111110100000;
6'b010000: data_out = 16'b1111111110100000;
6'b010001: data_out = 16'b0011111110100000;
6'b010010: data_out = 16'b1100111110100000;
6'b010011: data_out = 16'b1010011110100000;
6'b010100: data_out = 16'b0100101110100000;
6'b010101: data_out = 16'b1101110110100000;
6'b010110: data_out = 16'b1111100110100000;
6'b010111: data_out = 16'b1111111010100000;
6'b011000: data_out = 16'b0011101010100000;
6'b011001: data_out = 16'b1010110010100000;
6'b011010: data_out = 16'b0101000010100000;
6'b011011: data_out = 16'b0111101100100000;
6'b011100: data_out = 16'b1111010100100000;
6'b011101: data_out = 16'b0111111000100000;
6'b011110: data_out = 16'b0011001000100000;
6'b011111: data_out = 16'b1001100000100000;
6'b100000: data_out = 16'b0110011111000000;
6'b100001: data_out = 16'b1100110111000000;
6'b100010: data_out = 16'b1000000111000000;
6'b100011: data_out = 16'b0000101011000000;
6'b100100: data_out = 16'b1000010011000000;
6'b100101: data_out = 16'b1010111101000000;
6'b100110: data_out = 16'b0101001101000000;
6'b100111: data_out = 16'b1100010101000000;
6'b101000: data_out = 16'b0000000101000000;
6'b101001: data_out = 16'b0000011001000000;
6'b101010: data_out = 16'b0010001001000000;
6'b101011: data_out = 16'b1011010001000000;
6'b101100: data_out = 16'b0101100001000000;
6'b101101: data_out = 16'b0011000001000000;
6'b101110: data_out = 16'b1100000001000000;
6'b101111: data_out = 16'b0000000001000000;
6'b110000: data_out = 16'b1000000001000000;
6'b110001: data_out = 16'b1110000001000000;
6'b110010: data_out = 16'b1100100001000000;
6'b110011: data_out = 16'b1100010001000000;
6'b110100: data_out = 16'b0001110001000000;
6'b110101: data_out = 16'b1000101001000000;
6'b110110: data_out = 16'b1111011001000000;
6'b110111: data_out = 16'b1000100101000000;
6'b111000: data_out = 16'b0110110101000000;
6'b111001: data_out = 16'b1111101101000000;
6'b111010: data_out = 16'b1101000011000000;
6'b111011: data_out = 16'b1001110011000000;
6'b111100: data_out = 16'b1001011011000000;
6'b111101: data_out = 16'b0101100111000000;
6'b111110: data_out = 16'b1011001111000000;
6'b111111: data_out = 16'b1111111111000000;

default: data_out = 16'b0000000000000000;  // Address 0 maps to 0x00
       endcase
    end

endmodule
