class apb_monitor;

    // =====================================================
    // MONITOR → SCOREBOARD MAILBOX
    // =====================================================

    mailbox mon2scb;


    // =====================================================
    // VIRTUAL INTERFACE
    // =====================================================

    virtual apb_if vif;


    // =====================================================
    // TRANSACTION
    // =====================================================

    apb_transaction trans;


    // =====================================================
    // FUNCTIONAL COVERAGE
    // =====================================================

    covergroup apb_coverage (
        ref apb_transaction t
    );

        // -------------------------------------------------
        // READ / WRITE COVERAGE
        // -------------------------------------------------

        cp_write: coverpoint t.write {

            bins READ  = {0};
            bins WRITE = {1};

        }


        // -------------------------------------------------
        // ADDRESS COVERAGE
        // -------------------------------------------------

        cp_addr: coverpoint t.addr {

            bins ADDR_00 = {8'h00};
            bins ADDR_04 = {8'h04};
            bins ADDR_08 = {8'h08};
            bins ADDR_0C = {8'h0C};

        }


        // -------------------------------------------------
        // READ/WRITE × ADDRESS
        // -------------------------------------------------

        operation_address: cross cp_write, cp_addr;

    endgroup


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox mon2scb,
        virtual apb_if vif
    );

        this.mon2scb = mon2scb;
        this.vif = vif;

        // Create coverage instance using transaction
        apb_coverage = new(trans);

    endfunction


    // =====================================================
    // MONITOR
    // =====================================================

    task run();

        forever begin

            // -------------------------------------------------
            // Wait for clock
            // -------------------------------------------------

            @(posedge vif.PCLK);


            // -------------------------------------------------
            // Check for APB ACCESS phase
            // -------------------------------------------------

            if (vif.PSEL && vif.PENABLE) begin

                // Create transaction
                trans = new();


                // -------------------------------------------------
                // Capture common signals
                // -------------------------------------------------

                trans.write = vif.PWRITE;
                trans.addr  = vif.PADDR;


                // -------------------------------------------------
                // Capture WRITE data
                // -------------------------------------------------

                if (vif.PWRITE) begin

                    trans.wdata = vif.PWDATA;

                end


                // -------------------------------------------------
                // Wait for transfer completion
                // -------------------------------------------------

                wait (vif.PREADY == 1'b1);


                // -------------------------------------------------
                // Capture READ data
                // -------------------------------------------------

                if (!vif.PWRITE) begin

                    trans.rdata = vif.PRDATA;

                end


                // -------------------------------------------------
                // Check APB error
                // -------------------------------------------------

                trans.valid = !vif.PSLVERR;


                // -------------------------------------------------
                // Sample functional coverage
                // -------------------------------------------------

                apb_coverage.sample();


                // -------------------------------------------------
                // Send transaction to scoreboard
                // -------------------------------------------------

                mon2scb.put(trans);


                // -------------------------------------------------
                // Display observed transaction
                // -------------------------------------------------

                if (trans.write) begin

                    $display(
                        "MONITOR: WRITE ADDR=%0h DATA=%0h VALID=%0b",
                        trans.addr,
                        trans.wdata,
                        trans.valid
                    );

                end

                else begin

                    $display(
                        "MONITOR: READ ADDR=%0h DATA=%0h VALID=%0b",
                        trans.addr,
                        trans.rdata,
                        trans.valid
                    );

                end

            end

        end

    endtask


    // =====================================================
    // COVERAGE REPORT
    // =====================================================

    function void report_coverage();

        $display(
            "APB FUNCTIONAL COVERAGE = %0.2f%%",
            apb_coverage.get_coverage()
        );

    endfunction

endclass
