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
`default_nettype none

module i2c (
    input clk,
    input sdaIn,
    input enable,
    input [1:0] instruction,
    input [7:0] dataIn,
    output reg sdaOut = 1,
    output reg scl = 1,
    output reg isSending = 0,
    output reg [7:0] byteToSend,
    output reg [7:0] byteReceived = 0,
    output reg complete
    );

    /*1. Iniciar I2C
      2. Parar I2C
      3. Ler byte + confirmar
      4. Escrever byte + confirmar*/
    
    // Maquina de Estados I2C
    localparam START_TX = 0;
    localparam STOP_TX = 1;
    localparam READ_BYTE = 2;
    localparam WRITE_BYTE = 3;
    localparam STATE_IDLE = 4;
    localparam STATE_DONE = 5;
    localparam SEND_ACK = 6;
    localparam RCV_ACK = 7;

    //divisor de frequencia do clock 50MHz para algo abaixo de 400KHz
    reg[6:0] clockDivider = 0;

    reg[2:0] state = STATE_IDLE;
    reg[2:0] bitToSend = 0;


    
    always @(posedge clk) begin
        case (state) 

            STATE_IDLE: begin
                if(enable) begin
                    complete <= 0;
                    clockDivider <= 0;
                    bitToSend <= 0;
                    state <= {1'b0, instruction};
                end
            end

            START_TX: begin
                isSending <= 1;
                clockDivider <= clockDivider + 1;
                
                if(clockDivider[6:5] == 2'b00) begin
                    sclout <= 1;
                    sdaOut <= 1;
                end

                else if(clockDivider[6:5] == 2'b01) begin
                    sdaOut <= 0;
                end

                else if(clockDivider[6:5] == 2'b10) begin
                    scl <= 0;
                end

                else if(clockDivider[6:5] == 2'b11) begin
                    state <= STATE_DONE;
                end
            end

            STOP_TX: begin
                isSending <= 1;
                clockDivider <= clockDivider + 1;

                if(clockDivider[6:5] == 2'b00) begin
                    sclout <= 0;
                    sdaOut <= 0;
                end

                else if(clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end

                else if(clockDivider[6:5] == 2'b10) begin
                    sdaOut <= 1;
                end

                else if(clockDivider[6:5] == 2'b11) begin
                    state <= STATE_DONE;
                end
            end

            READ_BYTE: begin
                isSending <= 0;
                clockDivider <= clockDivider + 1;

                if(clockDivider[6:5] == 2'b00) begin
                    sclout <= 0;
                end

                else if(clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end

                else if(clockDivider == 7'b1000000) begin
                    byteReceived <= {byteReceived[6:0], sdaIn ? 1'b1 : 1'b0};
                end

                else if(clockDivider == 7'b1111111) begin
                    bitToSend <= bitToSend + 1;
                    if (bitToSend == 3'b111) begin
                        state <= SEND_ACK;  
                    end
                end

                else if(clockDivider[6:5] == 2'b11) begin
                  scl <= 0;
                end
            end

            SEND_ACK: begin
                isSending <= 1;
                sdaOut <= 0;
                clockDivider <= clockDivider + 1;

                if (clockDivider[6:5] == 2'b01) begin
                    scl <= 1;
                end

                else if()
            end

        endcase
    end


endmodule

module top(inout i2cSDA);
    assign i2cSDA = isSending ? sdaOut : 1'bz;
endmodule