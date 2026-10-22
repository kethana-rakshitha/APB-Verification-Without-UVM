class apb_scoreboard;

    // =====================================================
    // MONITOR → SCOREBOARD MAILBOX
    // =====================================================

    mailbox mon2scb;


    // =====================================================
    // REFERENCE MODEL
    // =====================================================

    logic [7:0] expected_mem [logic [7:0]];


    // =====================================================
    // COUNTERS
    // =====================================================

    int pass_count = 0;
    int fail_count = 0;
    int transaction_count = 0;


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox mon2scb
    );

        this.mon2scb = mon2scb;

        // Initialize expected register values

        expected_mem[8'h00] = 8'h00;
        expected_mem[8'h04] = 8'h00;
        expected_mem[8'h08] = 8'h00;
        expected_mem[8'h0C] = 8'h00;

    endfunction


    // =====================================================
    // SCOREBOARD
    // =====================================================

    task run();

        apb_transaction trans;

        logic [7:0] expected_data;

        forever begin

            // -------------------------------------------------
            // Wait for monitor transaction
            // -------------------------------------------------

            mon2scb.get(trans);


            // -------------------------------------------------
            // Ignore invalid transaction
            // -------------------------------------------------

            if (!trans.valid) begin

                $display(
                    "SCOREBOARD: Invalid APB transaction"
                );

                continue;

            end


            transaction_count++;


            // =================================================
            // WRITE TRANSACTION
            // =================================================

            if (trans.write) begin

                // Update reference model

                expected_mem[trans.addr] = trans.wdata;


                $display(
                    "SCOREBOARD: WRITE ADDR=%0h DATA=%0h",
                    trans.addr,
                    trans.wdata
                );

            end


            // =================================================
            // READ TRANSACTION
            // =================================================

            else begin

                // Get expected value

                expected_data =
                    expected_mem[trans.addr];


                // Compare expected vs actual

                if (trans.rdata == expected_data) begin

                    pass_count++;

                    $display(
                        "UART/APB PASS: READ ADDR=%0h EXPECTED=%0h ACTUAL=%0h",
                        trans.addr,
                        expected_data,
                        trans.rdata
                    );

                end

                else begin

                    fail_count++;

                    $display(
                        "APB FAIL: READ ADDR=%0h EXPECTED=%0h ACTUAL=%0h",
                        trans.addr,
                        expected_data,
                        trans.rdata
                    );

                end

            end

        end

    endtask


    // =====================================================
    // FINAL REPORT
    // =====================================================

    function void report();

        $display("========================================");
        $display("          APB SCOREBOARD SUMMARY        ");
        $display("========================================");

        $display(
            "Transactions : %0d",
            transaction_count
        );

        $display(
            "PASS         : %0d",
            pass_count
        );

        $display(
            "FAIL         : %0d",
            fail_count
        );

        $display("========================================");

    endfunction

endclass
