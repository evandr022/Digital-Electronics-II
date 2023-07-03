module I2C_Master_ADS1115_Display (
  input wire reset,
  input wire start_conversion,
  input wire reset_display,
  inout wire sda,
  output wire [6:0] seg_display,
  output reg scl
);

  // Parâmetros de tempo
  parameter SCL_LOW_TIME = 5;  // Tempo em unidades de clk
  parameter SCL_HIGH_TIME = 5; // Tempo em unidades de clk
  parameter START_SETUP_TIME = 5;
  parameter STOP_SETUP_TIME = 5;

  // Estados do mestre I2C
  parameter IDLE = 2'b00;
  parameter START = 2'b01;
  parameter WRITE = 2'b10;
  parameter STOP = 2'b11;

  reg [1:0] state;
  reg [15:0] data;
  reg [3:0] bit_counter;
  reg [7:0] address;
  reg sda_drive;
  reg [6:0] display_data;
  reg [3:0] voltage_bits;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      bit_counter <= 0;
      sda_drive <= 1;
      data <= 16'b0;
      display_data <= 7'b0000000;
      voltage_bits <= 3'b0000;
    end else begin
      case (state)
        IDLE: begin
          if (start_condition) begin
            state <= START;
          end
        end
        START: begin
          scl <= 0;
          sda <= 0;
          state <= WRITE;
          bit_counter <= 0;
          address <= 7'b1001000;  // Endereço do ADS1115
          data <= 16'b0000000100000011;  // Configuração padrão (Bits 15:8 = 00000001, Bits 7:0 = 00000011)
        end
        WRITE: begin
          if (bit_counter < 8) begin
            sda <= address[bit_counter];
            bit_counter <= bit_counter + 1;
          end else if (bit_counter < 16) begin
            sda <= data[bit_counter - 8];
            bit_counter <= bit_counter + 1;
          end else if (bit_counter == 16) begin
            sda_drive <= 1;
            sda <= 1;
            state <= STOP;
            bit_counter <= 0;
          end
        end
        STOP: begin
          scl <= 1;
          sda <= 1;
          state <= IDLE;
          if (start_conversion) begin
            voltage_bits <= data[15:12];  // Atualiza os bits de tensão com base na leitura do ADS1115
          end
          if (reset_display) begin
            display_data <= 7'b0000000;  // Reinicia o display para 000
          end else begin
            case (voltage_bits)
              3'b0000: display_data <= 7'b0000000;  // 0V
              3'b0001: display_data <= 7'b0000001;  // 0.5V
              3'b0010: display_data <= 7'b0000010;  // 1V
              3'b0011: display_data <= 7'b0000011;  // 1.5V
              3'b0100: display_data <= 7'b0000100;  // 2V
              3'b0101: display_data <= 7'b0000101;  // 2.5V
              3'b0110: display_data <= 7'b0000110;  // 3V
              3'b0111: display_data <= 7'b0000111;  // 3.5V
              3'b1000: display_data <= 7'b0001000;  //4.0V
              3'b1001: display_data <= 7'b0001001;  //4.5V
              3'b1010: display_data <= 7'b0001010;  //5.0V
              default: display_data <= 7'b0000000;  // Valor padrão para outras faixas de tensão não especificadas
            endcase
          end
        end
      endcase
    end
  end
  // Controlador do mestre I2C
  always @(posedge clk) begin
    case (state)
      IDLE: begin
        sda_drive <= 1;
      end
      START: begin
        sda_drive <= 0;
      end
      WRITE: begin
        sda_drive <= 0;
      end
      STOP: begin
        sda_drive <= 1;
      end
    endcase
  end

  // Gerador de sinal SCL
  always @(posedge clk) begin
    case (state)
      START, WRITE: begin
        scl <= 0;
        #(SCL_LOW_TIME);
        scl <= 1;
        #(SCL_HIGH_TIME);
      end
      STOP: begin
        scl <= 0;
        #(SCL_LOW_TIME);
        scl <= 1;
        #(SCL_HIGH_TIME);
      end
      default: begin
        scl <= 1;
      end
    endcase
  end

endmodule

module seven_seg_display (
    input wire [15:0] data,
    output wire [6:0] seg
);
    always @(*) begin
        case (data)
            6'd0: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b1000000;
            end
            6'd1: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b1111001;
            end
            6'd2: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0100100;
            end
            6'd3: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0110000;
            end
            6'd4: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0011001;
            end
            6'd5: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0010010;
            end
            6'd6: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0000010;
            end
            6'd7: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b1111000;
            end
            6'd8: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0000000;
            end
            6'd9: begin
                firstDigit = 7'b1000000;
                secondDigit = 7'b0010000;
            end
            6'd10: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b1000000;
            end
                6'd11: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b1111001;
            end
            6'd12: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0100100;
            end
            6'd13: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0110000;
            end
            6'd14: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0011001;
            end
            6'd15: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0010010;
            end
            6'd16: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0000010;
            end
            6'd17: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b1111000;
            end
            6'd18: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0000000;
            end
            6'd19: begin
                firstDigit = 7'b1111001;
                secondDigit = 7'b0010000;
            end
            6'd20: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b1000000;
            end
            6'd21: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b1111001;
            end
            6'd22: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0100100;
            end
            6'd23: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0110000;
            end
            6'd24: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0011001;
            end
            6'd25: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0010010;
            end
            6'd26: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0000010;
            end
            6'd27: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b1111000;
            end
            6'd28: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0000000;
            end
            6'd29: begin
                firstDigit = 7'b0100100;
                secondDigit = 7'b0010000;
            end
            6'd30: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b1000000;
            end
            6'd31: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b1111001;
            end
            6'd32: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0100100;
            end
            6'd33: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0110000;
            end
            6'd34: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0011001;
            end
            6'd35: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0010010;
            end
            6'd36: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0000010;
            end
            6'd37: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b1111000;
            end
            6'd38: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0000000;
            end
            6'd39: begin
                firstDigit = 7'b0110000;
                secondDigit = 7'b0010000;
            end
            6'd40: begin
                firstDigit = 7'b0011001;
                secondDigit = 7'b1000000;
            end
            
            // Continue with additional cases if needed
            default: begin
                firstDigit = 7'b0000000;
                secondDigit = 7'b0000000;
            end
        endcase
    end
endmodule

module top_module (
    input  clk,
    input  reset,
    input  start,
    inout  sda,
    output reg [6:0] display,
    output  scl
);
    wire [15:0] adc_data;
    
    i2c_master i2c_master (
        .clk(clk),
        .reset(reset),
        .start(start),
        .sda(sda),
        .scl(scl),
        .data_out(adc_data)
    );
    
    seven_seg_display seven_seg_display (
        .data(adc_data),
        .seg(display)
    );
endmodule
