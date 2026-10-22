module apb_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  logic PCLK,
    input  logic PRESETn,

    input  logic PSEL,
    input  logic PENABLE,
    input  logic PWRITE,

    input  logic [ADDR_WIDTH-1:0] PADDR,
    input  logic [DATA_WIDTH-1:0] PWDATA,

    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic PREADY,
    output logic PSLVERR
);

    // =====================================================
    // REGISTERS
    // =====================================================

    logic [DATA_WIDTH-1:0] reg0;
    logic [DATA_WIDTH-1:0] reg1;
    logic [DATA_WIDTH-1:0] reg2;
    logic [DATA_WIDTH-1:0] reg3;


    // =====================================================
    // WRITE LOGIC
    // =====================================================

    always_ff @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            reg0 <= '0;
            reg1 <= '0;
            reg2 <= '0;
            reg3 <= '0;

        end

        else begin

            if (PSEL && PENABLE && PWRITE) begin

                case (PADDR)

                    8'h00:
                        reg0 <= PWDATA;

                    8'h04:
                        reg1 <= PWDATA;

                    8'h08:
                        reg2 <= PWDATA;

                    8'h0C:
                        reg3 <= PWDATA;

                    default:
                        ;

                endcase

            end

        end

    end


    // =====================================================
    // READ LOGIC
    // =====================================================

    always_comb begin

        PRDATA = '0;

        if (PSEL && PENABLE && !PWRITE) begin

            case (PADDR)

                8'h00:
                    PRDATA = reg0;

                8'h04:
                    PRDATA = reg1;

                8'h08:
                    PRDATA = reg2;

                8'h0C:
                    PRDATA = reg3;

                default:
                    PRDATA = '0;

            endcase

        end

    end


    // =====================================================
    // READY
    // =====================================================

    assign PREADY = 1'b1;


    // =====================================================
    // ERROR RESPONSE
    // =====================================================

    always_comb begin

        PSLVERR = 1'b0;

        if (PSEL && PENABLE) begin

            case (PADDR)

                8'h00,
                8'h04,
                8'h08,
                8'h0C:
                    PSLVERR = 1'b0;

                default:
                    PSLVERR = 1'b1;

            endcase

        end

    end

endmodule
