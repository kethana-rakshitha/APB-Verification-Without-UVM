interface apb_if #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
);

    logic PCLK;
    logic PRESETn;

    logic PSEL;
    logic PENABLE;
    logic PWRITE;

    logic [ADDR_WIDTH-1:0] PADDR;
    logic [DATA_WIDTH-1:0] PWDATA;
    logic [DATA_WIDTH-1:0] PRDATA;

        logic PREADY;
    logic PSLVERR;


    // =====================================================
    // APB PROTOCOL ASSERTIONS
    // =====================================================

    // -----------------------------------------------------
    // ASSERTION 1:
    // SETUP phase must be followed by ACCESS phase
    // -----------------------------------------------------

    property setup_to_access;
        @(posedge PCLK)
        disable iff (!PRESETn)
        (PSEL && !PENABLE) |=> (PSEL && PENABLE);
    endproperty

    assert property (setup_to_access)
        else $error("APB ERROR: SETUP phase was not followed by ACCESS phase");


    // -----------------------------------------------------
    // ASSERTION 2:
    // PENABLE can only be high when PSEL is high
    // -----------------------------------------------------

    property penable_requires_psel;
        @(posedge PCLK)
        disable iff (!PRESETn)
        PENABLE |-> PSEL;
    endproperty

    assert property (penable_requires_psel)
        else $error("APB ERROR: PENABLE is high while PSEL is low");


    // -----------------------------------------------------
    // ASSERTION 3:
    // ACCESS phase must remain active while PREADY is low
    // -----------------------------------------------------

    property access_waits_for_ready;
        @(posedge PCLK)
        disable iff (!PRESETn)
        (PSEL && PENABLE && !PREADY)
        |=> (PSEL && PENABLE);
    endproperty

    assert property (access_waits_for_ready)
        else $error("APB ERROR: ACCESS phase ended before PREADY");



endinterface
