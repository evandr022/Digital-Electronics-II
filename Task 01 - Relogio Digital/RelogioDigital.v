module divisorDeFrequenciaSegundos(
    input clk,
    output reg clkDiv
);
    // Divisor de frequencia de 50MHz para 1Hz
    reg [25:0] count;
    always @(posedge clk) begin
        if (count == 50000000) begin
            count <= 0;
            clkDiv <= ~clkDiv;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module divisorDeFrequenciaMinutos(
    input clk,
    output reg clkDiv
);
    // Divisor de frequencia de 50MHz para 1Hz
    reg [25:0] count;
    always @(posedge clk) begin
        if (count == 3000000000) begin
            count <= 0;
            clkDiv <= ~clkDiv;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule

module divisorDeFrequenciaHoras(
    input clk,
    output reg clkDiv
);
    // Divisor de frequencia de 50MHz para 1Hz
    reg [25:0] count;
    always @(posedge clk) begin
        if (count == 108000000000) begin
            count <= 0;
            clkDiv <= ~clkDiv;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule


module segDisplayControl(
    input [3:0] number,
    output reg [6:0] segment
);
    always @(*) begin
        case(number)
            4'b0000: segment = 7'b1000000; // 0
            4'b0001: segment = 7'b1111001; // 1
            4'b0010: segment = 7'b0100100; // 2
            4'b0011: segment = 7'b0110000; // 3
            4'b0100: segment = 7'b0011001; // 4
            4'b0101: segment = 7'b0010010; // 5
            4'b0110: segment = 7'b0000010; // 6
            4'b0111: segment = 7'b1111000; // 7
            4'b1000: segment = 7'b0000000; // 8
            4'b1001: segment = 7'b0010000; // 9
            default: segment = 7'b1111111; // OFF
        endcase
    end
endmodule

module moduleSeveSegmentDisplay(
    input [3:0] number,
    input [3:0] number2,
    input clk,
    input reset,
    output  [6:0] segment
);

    reg selectionSegment = 0;
    reg [3:0] counter = 0;
    wire [6:0] segment1;
    wire [6:0] segment2;

    // 7 segment display switch Case


    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
            selectionSegment <= 0;
        end
        else begin
            if(counter == 4'b1111) begin
                counter <= 0;
                selectionSegment <= ~selectionSegment;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    segDisplayControl segDisplay1(
        .number(number),
        .segment(segment1)
    );

    segDisplayControl segDisplay2(
        .number(number2),
        .segment(segment2)
    );

    assign segment = selectionSegment ? segment1 : segment2;
endmodule

// Count Second First Digit
module countSecondFirstDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] second
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            second <= 4'b0000;
        else if (second == 4'b1001)
            second <= 4'b0000;
        else
            second <= second + 1;
    end
endmodule

// Count Second Second Digit
module countSecondSecondDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] second
);
    reg [3:0] contandor;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contandor <= 4'b0000;
            second <= 4'b0000;
        end
        else begin
            if (contandor == 4'b1001) begin
                contandor <= 4'b0000;
                if (second == 4'd5) // reset if it reaches 5
                    second <= 4'b0000;
                else
                    second <= second + 4'b0001;
            end
            else
                contandor <= contandor + 4'b0001;
        end
    end
endmodule


// Count Minute First Digit
module countMinuteFirstDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] minute
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            minute <= 4'b0000;
        else if (minute == 4'b1001)
            minute <= 4'b0000;
        else
            minute <= minute + 1;
    end
endmodule


// Count Minute Second Digit
module countMinuteSecondDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] minute
);
    reg [3:0] contandor;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contandor <= 4'b0000;
            minute <= 4'b0000;
        end
        else begin
            if (contandor == 4'b1001) begin // increment at 10
                contandor <= 4'b0000;
                if (minute == 4'b0101) // reset at 6
                    minute <= 4'b0000;
                else
                    minute <= minute + 4'b0001;
            end
            else
                contandor <= contandor + 4'b0001;
        end
    end
endmodule


// Count Hour First Digit
module countHourFirstDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] hour
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            hour <= 4'b0000;
        else if (hour == 4'b1001)
            hour <= 4'b0000;
        else
            hour <= hour + 1;
    end
endmodule


// Count Hour Second Digit
module countHourSecondDigit(
    input wire clk,
    input wire rst,
    output reg [3:0] hour
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            hour <= 4'b0000;
        else if (hour == 4'b0011) // Reset at '3'
            hour <= 4'b0000;
        else
            hour <= hour + 4'b0001; // Increment by 1
    end
endmodule




module RelogioDigital(
    input clk,
    input rst,
    output [6:0] f1,
    output [6:0] f2,
    output [6:0] f3,
    output [6:0] f4
);

    
    wire [3:0] countSecondFirstDigitWire;
    wire [3:0] countSecondSecondDigitWire;
    wire [3:0] countMinuteFirstDigitWire;
    wire [3:0] countMinuteSecondDigitWire;
    wire [3:0] countHourFirstDigitWire;
    wire [3:0] countHourSecondDigitWire;

    wire clkDivSegundos;
    wire clkDivMinutos;
    wire clkDivHoras;


    //divisor de frequencia
    divisorDeFrequenciaSegundos divisorDeFrequenciaSegundos(
        .clk(clk),
        .clkDiv(clkDivSegundos)
    );

    divisorDeFrequenciaMinutos divisorDeFrequenciaMinutos(
        .clk(clk),
        .clkDiv(clkDivMinutos)
    );

    divisorDeFrequenciaHoras divisorDeFrequenciaHoras(
        .clk(clk),
        .clkDiv(clkDivHoras)
    );

    //Second
    countSecondFirstDigit countSecondFirstDigitModule(
        .clk(clkDivSegundos),
        .rst(~rst),
        .second(countSecondFirstDigitWire)
    );
    
    countSecondSecondDigit countSecondSecondDigitModule(
        .clk(clkDivSegundos),
        .rst(~rst),
        .second(countSecondSecondDigitWire)
    );

    //Minute
    countMinuteFirstDigit countMinuteFirstDigiteModule(
        .clk(clkDivMinutos),
        .rst(~rst),
        .minute(countMinuteFirstDigitWire)
    );

    countMinuteSecondDigit countMinuteSecondDigitModule(
        .clk(clkDivMinutos),
        .rst(~rst),
        .minute(countMinuteSecondDigitWire)
    );

    //Hour

    countHourFirstDigit countHourFirstDigitModule(
        .clk(clkDivHoras),
        .rst(~rst),
        .hour(countHourFirstDigitWire)
    );

    countHourSecondDigit countHourSecondDigitModule(
        .clk(clkDivHoras),
        .rst(~rst),
        .hour(countHourSecondDigitWire)
    );
   
    // 7 segment display
    moduleSeveSegmentDisplay moduleSeveSegmentDisplay1(
        .clk(clkDivSegundos),
        .number(countHourFirstDigitWire),
        .number2(countMinuteFirstDigitWire),
        .segment(f1)
    );

    moduleSeveSegmentDisplay moduleSeveSegmentDisplay2(
        .clk(clkDivSegundos),
        .number(countHourSecondDigitWire),
        .number2(countMinuteSecondDigitWire),
        .segment(f2)
    );

    moduleSeveSegmentDisplay moduleSeveSegmentDispla3(
        .clk(clkDivSegundos),
        .number(countMinuteFirstDigitWire),
        .number2(countSecondFirstDigitWire),
        .segment(f3)
    );

    moduleSeveSegmentDisplay moduleSeveSegmentDisplay4(
        .clk(clkDivSegundos),
        .number(countMinuteSecondDigitWire),
        .number2(countSecondSecondDigitWire),
        .segment(f4)
    );

endmodule
