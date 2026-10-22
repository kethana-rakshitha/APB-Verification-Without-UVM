class apb_generator;

    // =====================================================
    // GENERATOR → DRIVER MAILBOX
    // =====================================================

    mailbox gen2drv;


    // =====================================================
    // NUMBER OF TRANSACTIONS
    // =====================================================

    int num_transactions;


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox gen2drv,
        int num_transactions
    );

        this.gen2drv = gen2drv;
        this.num_transactions = num_transactions;

    endfunction


    // =====================================================
    // GENERATE TRANSACTIONS
    // =====================================================

    task run();

        apb_transaction trans;

        repeat (num_transactions) begin

            // Create transaction
            trans = new();


            // Randomize transaction
            assert(trans.randomize())
                else $fatal(
                    "APB transaction randomization failed"
                );


            // Send transaction to driver
            gen2drv.put(trans);

        end

    endtask

endclass
