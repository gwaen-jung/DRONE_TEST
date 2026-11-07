// =============================================================================
// tb_spi_pid_wrapper - Testbench kiem thu bit-exact giao tiep SPI Slave 7-chan
// Nhom FPOLY UAV - Cuoc thi Thiet ke vi mach cho Do thi thong minh lan 3
//
// Kiem tra:
//   - Doc N_TEST mau dau tien tu vectors.txt (mac dinh 100 mau).
//   - Dong goi khung 192-bit gui qua 4 chan SPI Mode 0 (spi_cs_n, spi_sclk, spi_mosi).
//   - Cho xung irq_out_valid bao pid_ctrl da tinh xong (20 clock he thong).
//   - O khung SPI tiep theo, doc 192-bit tu spi_miso va so sanh bit-exact
//     m1..m4, mix_roll, mix_pitch, mix_yaw voi dap an golden model Python.
// =============================================================================
`timescale 1ns / 1ps

module tb_spi_pid_wrapper;
`include "pid_params.vh"

    // Clock he thong 50 MHz (chu ky 20 ns), SPI SCLK ~6.25 MHz (4 chu ky clk moi nua chu ky SCLK)
    reg clk = 1'b0;
    always #10 clk = ~clk;

    reg  rst_n    = 1'b0;
    reg  spi_sclk = 1'b0;
    reg  spi_cs_n = 1'b1;
    reg  spi_mosi = 1'b0;
    wire spi_miso;
    wire irq_out_valid;
    wire busy;

    spi_pid_wrapper dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .spi_sclk      (spi_sclk),
        .spi_cs_n      (spi_cs_n),
        .spi_mosi      (spi_mosi),
        .spi_miso      (spi_miso),
        .irq_out_valid (irq_out_valid),
        .busy          (busy)
    );

    reg [191:0] tx_frame, rx_frame;
    integer i;

    task spi_transfer_192;
        input  [191:0] data_in;
        output [191:0] data_out;
        begin
            spi_sclk = 1'b0;
            spi_cs_n = 1'b0;
            repeat (6) @(posedge clk); // setup cs_n fall synchronization
            for (i = 191; i >= 0; i = i - 1) begin
                spi_mosi = data_in[i];
                repeat (4) @(posedge clk);
                spi_sclk = 1'b1;       // rising edge: slave samples MOSI
                data_out[i] = spi_miso;
                repeat (4) @(posedge clk);
                spi_sclk = 1'b0;       // falling edge: slave shifts MISO
            end
            repeat (4) @(posedge clk);
            spi_cs_n = 1'b1;
            repeat (6) @(posedge clk); // allow frame_done & 20-cycle PID computation
        end
    endtask

    reg [8*512-1:0] vec_file;
    integer fd, n, samples, errors, max_samples;
    integer v_clear, v_armed, v_thr, v_spr, v_spp, v_spy, v_r, v_p, v_gz;
    integer x_mr, x_mp, x_my, x_m1, x_m2, x_m3, x_m4;

    reg [10:0]        got_m1, got_m2, got_m3, got_m4;
    reg signed [9:0]  got_mr, got_mp, got_my;
    reg [10:0]        thr_u;
    reg signed [W_IN-1:0] spr_s, spp_s, spy_s, r_s, p_s, gz_s;

    initial begin
        if (!$value$plusargs("VEC=%s", vec_file)) vec_file = "vectors.txt";
        if (!$value$plusargs("N=%d", max_samples)) max_samples = 100;

        fd = $fopen(vec_file, "r");
        if (fd == 0) begin
            $display("FATAL: khong mo duoc %0s", vec_file);
            $finish;
        end
        samples = 0; errors = 0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        while (!$feof(fd) && samples < max_samples) begin
            n = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                        v_clear, v_armed, v_thr, v_spr, v_spp, v_spy, v_r, v_p, v_gz,
                        x_mr, x_mp, x_my, x_m1, x_m2, x_m3, x_m4);
            if (n == 16) begin
                if (v_clear) begin
                    // Gui khung lenh clear = 1 qua SPI
                    tx_frame = {1'b1, 191'd0};
                    spi_transfer_192(tx_frame, rx_frame);
                    repeat (10) @(posedge clk);
                end

                thr_u = v_thr[10:0];
                spr_s = v_spr; spp_s = v_spp; spy_s = v_spy;
                r_s   = v_r;   p_s   = v_p;   gz_s  = v_gz;

                tx_frame = 192'd0;
                tx_frame[191]          = 1'b0; // clear = 0 -> sample_valid = 1
                tx_frame[190]          = v_armed[0];
                tx_frame[189:179]      = thr_u;
                tx_frame[178 -: W_IN]  = spr_s;
                tx_frame[156 -: W_IN]  = spp_s;
                tx_frame[134 -: W_IN]  = spy_s;
                tx_frame[112 -: W_IN]  = r_s;
                tx_frame[90  -: W_IN]  = p_s;
                tx_frame[68  -: W_IN]  = gz_s;

                spi_transfer_192(tx_frame, rx_frame);

                // Cho pid_ctrl tinh xong (toi da 20 chu ky clk sau khi cs_n len 1)
                repeat (30) @(posedge clk);

                // Gui khung read-only (bit [46] = 1) de doc 192-bit MISO ma khong kich sample moi
                tx_frame = 192'd0;
                tx_frame[46] = 1'b1;
                spi_transfer_192(tx_frame, rx_frame);

                got_m1 = rx_frame[190:180];
                got_m2 = rx_frame[179:169];
                got_m3 = rx_frame[168:158];
                got_m4 = rx_frame[157:147];
                got_mr = rx_frame[146:137];
                got_mp = rx_frame[136:127];
                got_my = rx_frame[126:117];

                if (got_m1 !== x_m1 || got_m2 !== x_m2 || got_m3 !== x_m3 || got_m4 !== x_m4 ||
                    got_mr !== x_mr || got_mp !== x_mp || got_my !== x_my) begin
                    errors = errors + 1;
                    if (errors <= 5)
                        $display("SPI LECH mau %0d: got m=%0d,%0d,%0d,%0d | exp m=%0d,%0d,%0d,%0d",
                                 samples, got_m1, got_m2, got_m3, got_m4, x_m1, x_m2, x_m3, x_m4);
                end
                samples = samples + 1;
            end
        end
        $fclose(fd);

        $display("----------------------------------------------------------------");
        if (errors == 0 && samples > 0)
            $display("PASS SPI WRAPPER: %0d/%0d mau giao tiep 4-day SPI khop bit-exact 100%%", samples, samples);
        else
            $display("FAIL SPI WRAPPER: %0d/%0d mau lech", errors, samples);
        $display("----------------------------------------------------------------");
        $finish;
    end

endmodule
