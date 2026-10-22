class apb_driver;

    // =====================================================
    // GENERATOR → DRIVER MAILBOX
    // =====================================================

    mailbox gen2drv;


    // =====================================================
    // VIRTUAL INTERFACE
    // =====================================================

    virtual apb_if vif;


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox gen2drv,
        virtual apb_if vif
    );

        this.gen2drv = gen2drv;
        this.vif = vif;

    endfunction


    // =====================================================
    // DRIVER
    // =====================================================

    task run();

        apb_transaction trans;

        forever begin

            // -------------------------------------------------
            // Get transaction from generator
            // -------------------------------------------------

            gen2drv.get(trans);


            // -------------------------------------------------
            // SETUP PHASE
            // -------------------------------------------------

            @(posedge vif.PCLK);

            vif.PSEL    <= 1'b1;
            vif.PENABLE <= 1'b0;
            vif.PWRITE  <= trans.write;
            vif.PADDR   <= trans.addr;
            vif.PWDATA  <= trans.wdata;


            // -------------------------------------------------
            // ACCESS PHASE
            // -------------------------------------------------

            @(posedge vif.PCLK);

            vif.PENABLE <= 1'b1;


            // -------------------------------------------------
            // Wait for slave to complete transfer
            // -------------------------------------------------

            wait (vif.PREADY == 1'b1);


            // -------------------------------------------------
            // Capture read data
            // -------------------------------------------------

            if (!trans.write) begin

                trans.rdata = vif.PRDATA;

            end


            // -------------------------------------------------
            // Return to IDLE
            // -------------------------------------------------

            @(posedge vif.PCLK);

            vif.PSEL    <= 1'b0;
            vif.PENABLE <= 1'b0;

        end

    endtask

endclass
