module pmod_counter (
        input CLK,              // Main clock input
        output P1_1,            // Chip select - Active low signal to enable the external device
        output P1_2,            // Data - Serial data output to the external device
        output P1_4             // Clock - Serial clock for data synchronization
);

// Declare wires to connect to the lookup table - used to store data patterns
wire [3:0] lut_address;         // 4-bit address to select data from lookup table
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
reg [3:0] tempcounter = 4'b0000; // Counter to select which bit of data to send
reg [3:0] dataloader = 4'b0000; // Counter to select which pattern to load from LUT
localparam N = 8;              // Timing parameter for chip select frequency
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
