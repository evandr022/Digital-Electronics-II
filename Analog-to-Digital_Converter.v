//conversor Analogico para digital em verilog usando ADS1115 e FPGA

/*Interface I2C usa dois fios: 1- Dados e 2- Relogio*/

/* O pino ADDR da interface I2C é usado para configurar o endereço
GND - 1001000
VDD - 1001001
SDA - 1001010
SCL - 1001011
*/

/* ADC tem 4 registradores internos principais
1. Conversion Register
2. Config Register
3. Low Threshold Register
4. High Threshold Register
*/

/* // Task 0 Setup Conversion
 - 0 start_i2c()
 - 1 send_byte({address, w})
 - 2 send_byte(select_config_register)
 - 3 send_byte(config_with_channel_upper)
 - 4 send_byte(config_with_channel_lower)
 - 5 stop_i2c()

// Task 1 Check if Ready
 - 0 wait x amount of time
 - 1 start_i2c()
 - 2 send_byte({address, r})
 - 3 read_byte() // reading config upper byte
 - 4 store 1st byte + read_byte() // reading config lower byte
 - 5 stop_i2c()

// Task 2 Switch Back to Conversion Register
 - 0 delay some time
 - 1 start_i2c()
 - 2 write_byte({address, w})
 - 3 write_byte(select_conversion_register)
 - 4 stop_i2c()

// #3 Read Value
 - 0 start_i2c()
 - 1 write_byte({address, r})
 - 2 read_byte() // reading conversion register upper
 - 3 store 1st byte + read_byte() // reading conversion register lower
 - 4 store 2nd read byte
 - 5 stop_i2c()
*/

// Task 2 Switch Back to Conversion Register

module adc #(
    parameter address = 7'd0
) (
    input clk,
    input [1:0] channel,
    output reg [15:0] outputData = 0,
    output reg dataReady = 1,
    input enable,
    output reg [1:0] instructionI2C = 0,
    output reg enableI2C = 0,
    output reg [7:0] byteToSendI2C = 0,
    input [7:0] byteReceivedI2C,
    input completeI2C
);

// setup config
reg [15:0] setupRegister = {
    1'b1, // Start Conversion
    3'b100, // Channel 0 Single ended
    3'b001, // FSR +- 4.096v
    1'b1, // Single shot mode
    3'b100, // 128 SPS
    1'b0, // Traditional Comparator
    1'b0, // Active low alert
    1'b0, // Non latching
    2'b11 // Disable comparator
};

localparam CONFIG_REGISTER = 8'b00000001;
localparam CONVERSION_REGISTER = 8'b00000000;

localparam TASK_SETUP = 0;
localparam TASK_CHECK_DONE = 1;
localparam TASK_CHANGE_REG = 2;
localparam TASK_READ_VALUE = 3;

localparam INST_START_TX = 0;
localparam INST_STOP_TX = 1;
localparam INST_READ_BYTE = 2;
localparam INST_WRITE_BYTE = 3;

localparam STATE_IDLE = 0;
localparam STATE_RUN_TASK = 1;
localparam STATE_WAIT_FOR_I2C = 2;
localparam STATE_INC_SUB_TASK = 3;
localparam STATE_DONE = 4;
localparam STATE_DELAY = 5;

reg [1:0] taskIndex = 0;
reg [2:0] subTaskIndex = 0;
reg [4:0] state = STATE_IDLE;
reg [7:0] counter = 0;
reg processStarted = 0;

always @(posedge clk) begin
    case (state)
        STATE_IDLE: begin
            if (enable) begin
                state <= STATE_RUN_TASK;
                taskIndex <= 0;
                subTaskIndex <= 0;
                dataReady <= 0;
                counter <= 0;
            end
        end
        STATE_RUN_TASK: begin
            case ({taskIndex,subTaskIndex})
                {TASK_SETUP,3'd0},
                {TASK_CHECK_DONE,3'd1},
                {TASK_CHANGE_REG,3'd1},
                {TASK_READ_VALUE,3'd0}: begin
                    instructionI2C <= INST_START_TX;
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_SETUP,3'd1},
                {TASK_CHANGE_REG,3'd2},
                {TASK_CHECK_DONE,3'd2},
                {TASK_READ_VALUE,3'd1}: begin
                    instructionI2C <= INST_WRITE_BYTE;
                    byteToSendI2C <= {address, (taskIndex == TASK_CHECK_DONE || taskIndex == TASK_READ_VALUE) ? 1'b1 : 1'b0};
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_SETUP,3'd5},
                {TASK_CHECK_DONE,3'd5},
                {TASK_CHANGE_REG,3'd4},
                {TASK_READ_VALUE,3'd5}: begin
                    instructionI2C <= INST_STOP_TX;
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_SETUP,3'd2},
                {TASK_CHANGE_REG,3'd3}: begin
                    instructionI2C <= INST_WRITE_BYTE;
                    byteToSendI2C <= taskIndex == TASK_SETUP ? CONFIG_REGISTER : CONVERSION_REGISTER;
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_SETUP,3'd3}: begin
                    instructionI2C <= INST_WRITE_BYTE;
                    byteToSendI2C <= {
                        setupRegister[15] ? 1'b1 : 1'b0,
                        1'b1, channel,
                        setupRegister[11:8]
                    };
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_SETUP,3'd4}: begin
                    instructionI2C <= INST_WRITE_BYTE;
                    byteToSendI2C <= setupRegister[7:0];
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_CHECK_DONE,3'd0}: begin
                    state <= STATE_DELAY;
                end
                {TASK_CHECK_DONE,3'd3}, 
                {TASK_READ_VALUE,3'd2}: begin
                    instructionI2C <= INST_READ_BYTE;
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_CHECK_DONE,3'd4},
                {TASK_READ_VALUE,3'd3}: begin
                    instructionI2C <= INST_READ_BYTE;
                    outputData[15:8] <= byteReceivedI2C;
                    enableI2C <= 1;
                    state <= STATE_WAIT_FOR_I2C;
                end
                {TASK_CHANGE_REG,3'd0}: begin
                    if (outputData[15])
                        state <= STATE_INC_SUB_TASK;
                    else begin
                        subTaskIndex <= 0;
                        taskIndex <= TASK_CHECK_DONE;
                    end
                end
                {TASK_READ_VALUE,3'd4}: begin
                    state <= STATE_INC_SUB_TASK;
                    outputData[7:0] <= byteReceivedI2C;
                end
                default:
                    state <= STATE_INC_SUB_TASK;
            endcase
        end
        STATE_WAIT_FOR_I2C: begin
            if (~processStarted && ~completeI2C)
                processStarted <= 1;
            else if (completeI2C && processStarted) begin
                state <= STATE_INC_SUB_TASK;
                processStarted <= 0;
                enableI2C <= 0;
            end
        end
        STATE_INC_SUB_TASK: begin
            state <= STATE_RUN_TASK;
            if (subTaskIndex == 3'd5) begin
                subTaskIndex <= 0;
                if (taskIndex == TASK_READ_VALUE) begin
                    state <= STATE_DONE;
                end
                else
                    taskIndex <= taskIndex + 1;
            end
            else
                subTaskIndex <= subTaskIndex + 1;
        end
        STATE_DELAY: begin
            counter <= counter + 1;
            if (counter == 8'b11111111) begin
                state <= STATE_INC_SUB_TASK;
            end
        end
        STATE_DONE: begin
            dataReady <= 1;
            if (~enable)
                state <= STATE_IDLE;
        end
    endcase
end

endmodule



module i2c (
    input clk,
    input sdaIn,
    output reg sdaOutReg = 1,
    output reg isSending = 0,
    output reg scl = 1,
    input [1:0] instruction,
    input enable,
    input [7:0] byteToSend,
    output reg [7:0] byteReceived = 0,
    output reg complete
);
    localparam INST_START_TX = 0;
    localparam INST_STOP_TX = 1;
    localparam INST_READ_BYTE = 2;
    localparam INST_WRITE_BYTE = 3;
    localparam STATE_IDLE = 4;
    localparam STATE_DONE = 5;
    localparam STATE_SEND_ACK = 6;
    localparam STATE_RCV_ACK = 7;

    reg [6:0] clockDivider = 0;

    reg [2:0] state = STATE_IDLE;
    reg [2:0] bitToSend = 0;

    always @(posedge clk) begin
        case (state)
            STATE_IDLE: begin
                if (enable) begin
                    complete <= 0;
                    clockDivider <= 0;
                    bitToSend <= 0;
                    state <= {1'b0,instruction};
                end
            end
            INST_START_TX: begin
                isSending <= 1;
                clockDivider <= clockDivider + 1;
                if (clockDivider[6:5] == 2'b00) begin
                    scl <= 1;
                    sdaOutReg <= 1;
                end else if (clockDivider[6:5] == 2'b01) begin
                    sdaOutReg <= 0;
                end else if (clockDivider[6:5] == 2'b10) begin
                    scl <= 0;
                end else if (clockDivider[6:5] == 2'b11) begin
                    state <= STATE_DONE;
                end
            end
            INST_STOP_TX: begin
                isSending <= 1;
                clockDivider <= clockDivider + 1;
                if (clockDivider[6:5] == 2'b00) begin
                    scl <= 0;
                    sdaOutReg <= 0;
                end else if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end else if (clockDivider[6:5] == 2'b10) begin
                    sdaOutReg <= 1;
                end else if (clockDivider[6:5] == 2'b11) begin
                    state <= STATE_DONE;
                end
            end
            INST_READ_BYTE: begin
                isSending <= 0;
                clockDivider <= clockDivider + 1;
                if (clockDivider[6:5] == 2'b00) begin
                    scl <= 0;
                end else if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end else if (clockDivider == 7'b1000000) begin
                    byteReceived <= {byteReceived[6:0], sdaIn ? 1'b1 : 1'b0};
                end else if (clockDivider == 7'b1111111) begin
                    bitToSend <= bitToSend + 1;
                    if (bitToSend == 3'b111) begin
                        state <= STATE_SEND_ACK;
                    end
                end else if (clockDivider[6:5] == 2'b11) begin
                    scl <= 0;
                end
            end
            STATE_SEND_ACK: begin
                isSending <= 1;
                sdaOutReg <= 0;
                clockDivider <= clockDivider + 1;
                if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end else if (clockDivider == 7'b1111111) begin
                    state <= STATE_DONE;
                end else if (clockDivider[6:5] == 2'b11) begin
                    scl <= 0;
                end
            end
            INST_WRITE_BYTE: begin
                isSending <= 1;
                clockDivider <= clockDivider + 1;
                sdaOutReg <= byteToSend[3'd7-bitToSend] ? 1'b1 : 1'b0;

                if (clockDivider[6:5] == 2'b00) begin
                    scl <= 0;
                end else if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end else if (clockDivider == 7'b1111111) begin
                    bitToSend <= bitToSend + 1;
                    if (bitToSend == 3'b111) begin
                        state <= STATE_RCV_ACK;
                    end
                end else if (clockDivider[6:5] == 2'b11) begin
                    scl <= 0;
                end
            end
            STATE_RCV_ACK: begin
                isSending <= 0;
                clockDivider <= clockDivider + 1;

                if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end else if (clockDivider == 7'b1111111) begin
                    state <= STATE_DONE;
                end else if (clockDivider[6:5] == 2'b11) begin
                    scl <= 0;
                end
                // else if (clockDivider == 7'b1000000) begin
                //     sdaIn should be 0
                // end 
            end
            STATE_DONE: begin
                complete <= 1;
                if (~enable)
                    state <= STATE_IDLE;
            end
        endcase
    end
endmodule



module toHex(
    input clk,
    input [3:0] value,
    output reg [7:0] hexChar = "0"
);
    always @(posedge clk) begin
        hexChar <= (value <= 9) ? 8'd48 + value : 8'd55 + value;
    end
endmodule

module toDec(
    input clk,
    input [11:0] value,
    output reg [7:0] thousands = "0",
    output reg [7:0] hundreds = "0",
    output reg [7:0] tens = "0",
    output reg [7:0] units = "0"
);
    reg [15:0] digits = 0;
    reg [11:0] cachedValue = 0;
    reg [3:0] stepCounter = 0;
    reg [3:0] state = 0;

    localparam START_STATE = 0;
    localparam ADD3_STATE = 1;
    localparam SHIFT_STATE = 2;
    localparam DONE_STATE = 3;

    always @(posedge clk) begin
        case (state)
            START_STATE: begin
                cachedValue <= value;
                stepCounter <= 0;
                digits <= 0;
                state <= ADD3_STATE;
            end
            ADD3_STATE: begin
                digits <= digits + 
                    ((digits[7:4] >= 5) ? 16'd48 : 16'd0) + 
                    ((digits[3:0] >= 5) ? 16'd3 : 16'd0) + 
                    ((digits[11:8] >= 5) ? 16'd768 : 16'd0) + 
                    ((digits[15:12] >= 5) ? 16'd12288 : 16'd0);
                state <= SHIFT_STATE;
            end
            SHIFT_STATE: begin
                digits <= {digits[14:0],cachedValue[11] ? 1'b1 : 1'b0};
                cachedValue <= {cachedValue[10:0],1'b0};
                if (stepCounter == 11)
                    state <= DONE_STATE;
                else begin
                    state <= ADD3_STATE;
                    stepCounter <= stepCounter + 1;
                end
            end
            DONE_STATE: begin
                thousands <= 8'd48 + digits[15:12];
                hundreds <= 8'd48 + digits[11:8];
                tens <= 8'd48 + digits[7:4];
                units <= 8'd48 + digits[3:0];
                state <= START_STATE;
            end
        endcase
    end
endmodule



module top
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    output ioSclk,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset,
    inout i2cSda,
    output i2cScl
);
    wire [9:0] pixelAddress;
    wire [7:0] textPixelData;
    wire [5:0] charAddress;
    reg [7:0] charOutput = "A";

    screen #(STARTUP_WAIT) scr(
        clk, 
        ioSclk, 
        ioSdin, 
        ioCs, 
        ioDc, 
        ioReset, 
        pixelAddress,
        textPixelData
    );

    textEngine te(
        clk,
        pixelAddress,
        textPixelData,
        charAddress,
        charOutput
    );

    wire [1:0] i2cInstruction;
    wire [7:0] i2cByteToSend;
    wire [7:0] i2cByteReceived;
    wire i2cComplete;
    wire i2cEnable;

    wire sdaIn;
    wire sdaOut;
    wire isSending;
    assign i2cSda = (isSending & ~sdaOut) ? 1'b0 : 1'bz;
    assign sdaIn = i2cSda ? 1'b1 : 1'b0;

    i2c c(
        clk,
        sdaIn,
        sdaOut,
        isSending,
        i2cScl,
        i2cInstruction,
        i2cEnable,
        i2cByteToSend,
        i2cByteReceived,
        i2cComplete
    );

    reg [1:0] adcChannel = 0;
    wire [15:0] adcOutputData;
    wire adcDataReady;
    reg adcEnable = 0;

    adc #(7'b1001001) a(
        clk,
        adcChannel,
        adcOutputData,
        adcDataReady,
        adcEnable,
        i2cInstruction,
        i2cEnable,
        i2cByteToSend,
        i2cByteReceived,
        i2cComplete
    );

    reg [15:0] adcOutputBufferCh1 = 0;
    reg [15:0] adcOutputBufferCh2 = 0;
    reg [11:0] voltageCh1 = 0;
    reg [11:0] voltageCh2 = 0;

    localparam STATE_TRIGGER_CONV = 0;
    localparam STATE_WAIT_FOR_START = 1;
    localparam STATE_SAVE_VALUE_WHEN_READY = 2;

    reg [2:0] drawState = 0;
    
    always @(posedge clk) begin
        case (drawState)
            STATE_TRIGGER_CONV: begin
                adcEnable <= 1;
                drawState <= STATE_WAIT_FOR_START;
            end
            STATE_WAIT_FOR_START: begin
                if (~adcDataReady) begin
                    drawState <= STATE_SAVE_VALUE_WHEN_READY;
                end
            end
            STATE_SAVE_VALUE_WHEN_READY: begin
                if (adcDataReady) begin
                    adcChannel <= adcChannel[0] ? 2'b00 : 2'b01;
                    if (~adcChannel[0]) begin
                        adcOutputBufferCh1 <= adcOutputData;
                        voltageCh1 <= adcOutputData[15] ? 12'd0 : adcOutputData[14:3];
                    end
                    else begin
                        adcOutputBufferCh2 <= adcOutputData;
                        voltageCh2 <= adcOutputData[15] ? 12'd0 : adcOutputData[14:3];
                    end
                    drawState <= STATE_TRIGGER_CONV;
                    adcEnable <= 0;
                end
            end
        endcase
    end

    wire [1:0] rowNumber;
    assign rowNumber = charAddress[5:4];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin: hexValCh1 
            wire [7:0] hexChar;
            toHex converter(clk, adcOutputBufferCh1[{i,2'b0}+:4], hexChar);
        end
    endgenerate
    generate
        for (i = 0; i < 4; i = i + 1) begin: hexValCh2
            wire [7:0] hexChar;
            toHex converter(clk, adcOutputBufferCh2[{i,2'b0}+:4], hexChar);
        end
    endgenerate

    wire [7:0] thousandsCh1, hundredsCh1, tensCh1, unitsCh1;
    wire [7:0] thousandsCh2, hundredsCh2, tensCh2, unitsCh2;

    toDec dec(
        clk,
        voltageCh1,
        thousandsCh1,
        hundredsCh1,
        tensCh1,
        unitsCh1
    );

    toDec dec2(
        clk,
        voltageCh2,
        thousandsCh2,
        hundredsCh2,
        tensCh2,
        unitsCh2
    );

    always @(posedge clk) begin
        if (rowNumber == 2'd0) begin
            case (charAddress[3:0])
                0: charOutput <= "C";
                1: charOutput <= "h";
                2: charOutput <= "1";
                4: charOutput <= "r";
                5: charOutput <= "a";
                6: charOutput <= "w";
                8: charOutput <= "0";
                9: charOutput <= "x";
                10: charOutput <= hexValCh1[3].hexChar;
                11: charOutput <= hexValCh1[2].hexChar;
                12: charOutput <= hexValCh1[1].hexChar;
                13: charOutput <= hexValCh1[0].hexChar;
                default: charOutput <= " ";
            endcase
        end
        else if (rowNumber == 2'd1) begin
            case (charAddress[3:0])
                0: charOutput <= "C";
                1: charOutput <= "h";
                2: charOutput <= "1";
                4: charOutput <= thousandsCh1;
                5: charOutput <= ".";
                6: charOutput <= hundredsCh1;
                7: charOutput <= tensCh1;
                8: charOutput <= unitsCh1;
                10: charOutput <= "V";
                11: charOutput <= "o";
                12: charOutput <= "l";
                13: charOutput <= "t";
                14: charOutput <= "s";
                default: charOutput <= " ";
            endcase
        end
        else if (rowNumber == 2'd2) begin
            case (charAddress[3:0])
                0: charOutput <= "C";
                1: charOutput <= "h";
                2: charOutput <= "2";
                4: charOutput <= "r";
                5: charOutput <= "a";
                6: charOutput <= "w";
                8: charOutput <= "0";
                9: charOutput <= "x";
                10: charOutput <= hexValCh2[3].hexChar;
                11: charOutput <= hexValCh2[2].hexChar;
                12: charOutput <= hexValCh2[1].hexChar;
                13: charOutput <= hexValCh2[0].hexChar;
                default: charOutput <= " ";
            endcase
        end
        else if (rowNumber == 2'd3) begin
            case (charAddress[3:0])
                0: charOutput <= "C";
                1: charOutput <= "h";
                2: charOutput <= "2";
                4: charOutput <= thousandsCh2;
                5: charOutput <= ".";
                6: charOutput <= hundredsCh2;
                7: charOutput <= tensCh2;
                8: charOutput <= unitsCh2;
                10: charOutput <= "V";
                11: charOutput <= "o";
                12: charOutput <= "l";
                13: charOutput <= "t";
                14: charOutput <= "s";
                default: charOutput <= " ";
            endcase
        end
    end
    
endmodule


module screen
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    output ioSclk,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset,
    output [9:0] pixelAddress,
    input [7:0] pixelData
);

  localparam STATE_INIT_POWER = 8'd0;
  localparam STATE_LOAD_INIT_CMD = 8'd1;
  localparam STATE_SEND = 8'd2;
  localparam STATE_CHECK_FINISHED_INIT = 8'd3;
  localparam STATE_LOAD_DATA = 8'd4;

  reg [32:0] counter = 0;
  reg [2:0] state = 0;

  reg dc = 1;
  reg sclk = 1;
  reg sdin = 0;
  reg reset = 1;
  reg cs = 0;

  reg [7:0] dataToSend = 0;
  reg [3:0] bitNumber = 0;  
  reg [9:0] pixelCounter = 0;

  localparam SETUP_INSTRUCTIONS = 23;
  reg [(SETUP_INSTRUCTIONS*8)-1:0] startupCommands = {
    8'hAE,  // display off

    8'h81,  // contast value to 0x7F according to datasheet
    8'h7F,  

    8'hA6,  // normal screen mode (not inverted)

    8'h20,  // horizontal addressing mode
    8'h00,  

    8'hC8,  // normal scan direction

    8'h40,  // first line to start scanning from

    8'hA1,  // address 0 is segment 0

    8'hA8,  // mux ratio
    8'h3f,  // 63 (64 -1)

    8'hD3,  // display offset
    8'h00,  // no offset

    8'hD5,  // clock divide ratio
    8'h80,  // set to default ratio/osc frequency

    8'hD9,  // set precharge
    8'h22,  // switch precharge to 0x22 default

    8'hDB,  // vcom deselect level
    8'h20,  //  0x20 

    8'h8D,  // charge pump config
    8'h14,  // enable charge pump

    8'hA4,  // resume RAM content

    8'hAF   // display on
  };
  reg [7:0] commandIndex = SETUP_INSTRUCTIONS * 8;

  assign ioSclk = sclk;
  assign ioSdin = sdin;
  assign ioDc = dc;
  assign ioReset = reset;
  assign ioCs = cs;

  assign pixelAddress = pixelCounter;

  always @(posedge clk) begin
    case (state)
      STATE_INIT_POWER: begin
        counter <= counter + 1;
        if (counter < STARTUP_WAIT*2)
          reset <= 1;
        else if (counter < STARTUP_WAIT * 3)
          reset <= 0;
        else if (counter < STARTUP_WAIT * 4)
          reset <= 1;
        else begin
          state <= STATE_LOAD_INIT_CMD;
          counter <= 32'b0;
        end
      end
      STATE_LOAD_INIT_CMD: begin
        dc <= 0;
        dataToSend <= startupCommands[(commandIndex-1)-:8'd8];
        state <= STATE_SEND;
        bitNumber <= 3'd7;
        cs <= 0;
        commandIndex <= commandIndex - 8'd8;
      end
      STATE_SEND: begin
        if (counter == 32'd0) begin
          sclk <= 0;
          sdin <= dataToSend[bitNumber];
          counter <= 32'd1;
        end
        else begin
          counter <= 32'd0;
          sclk <= 1;
          if (bitNumber == 0)
            state <= STATE_CHECK_FINISHED_INIT;
          else
            bitNumber <= bitNumber - 1;
        end
      end
      STATE_CHECK_FINISHED_INIT: begin
          cs <= 1;
          if (commandIndex == 0) begin
            state <= STATE_LOAD_DATA; 
          end
          else
            state <= STATE_LOAD_INIT_CMD; 
      end
      STATE_LOAD_DATA: begin
        pixelCounter <= pixelCounter + 1;
        cs <= 0;
        dc <= 1;
        bitNumber <= 3'd7;
        state <= STATE_SEND;
        dataToSend <= pixelData;
      end
    endcase
  end
endmodule


module textEngine (
    input clk,
    input [9:0] pixelAddress,
    output [7:0] pixelData,
    output [5:0] charAddress,
    input [7:0] charOutput
);
    reg [7:0] fontBuffer [1519:0];
    initial $readmemh("font.hex", fontBuffer);

    wire [2:0] columnAddress;
    wire topRow;

    reg [7:0] outputBuffer;
    wire [7:0] chosenChar;

    always @(posedge clk) begin
        outputBuffer <= fontBuffer[((chosenChar-8'd32) << 4) + (columnAddress << 1) + (topRow ? 0 : 1)];
    end

    assign charAddress = {pixelAddress[9:8],pixelAddress[6:3]};
    assign columnAddress = pixelAddress[2:0];
    assign topRow = !pixelAddress[7];

    assign chosenChar = (charOutput >= 32 && charOutput <= 126) ? charOutput : 32;
    assign pixelData = outputBuffer;
endmodule
