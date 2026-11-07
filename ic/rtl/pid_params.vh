// Tu dong sinh boi ic/model/export_rtl.py - KHONG sua tay, sua mo hinh roi chay lai.
// Cau hinh B: fe=6 wk=10 fa=8 fd=2 fu=6 rnd=1, dt = 2.5 ms
// Dau vao sp_*/roll/pitch/gz: so nguyen co dau Q.FE (do, do/s). Dau ra motor: us.

localparam integer FE     = 6;
localparam integer FD     = 2;
localparam integer FA     = 8;
localparam integer FU     = 6;
localparam integer ROUND  = 1;

localparam integer W_IN   = 18;
localparam integer W_E    = 19;
localparam integer W_ACC  = 23;
localparam integer W_DE   = 22;
localparam integer W_DF   = 22;
localparam integer W_DIFF = 23;
localparam integer W_MA   = 11;
localparam integer W_MB   = 23;
localparam integer W_P    = 34;
localparam integer W_U    = 25;

localparam integer ALPHA   = 51;       // 0.2 * 2^FA
localparam integer ACC_LIM = 2560000;  // 100.0/dt * 2^FE
localparam integer U_LIM   = 16000;     // 250 * 2^FU

localparam integer KP_M0  = 922;  localparam integer SH_P0 = 9;  // roll KP' = 1.8
localparam integer KI_M0  = 629;  localparam integer SH_I0 = 21;  // roll KI' = 0.0003
localparam integer KD_M0  = 576;  localparam integer SH_D0 = 6;  // roll KD' = 36
localparam integer MIX_LIM0 = 250;
localparam integer KP_M1  = 937;  localparam integer SH_P1 = 9;  // pitch KP' = 1.83
localparam integer KI_M1  = 645;  localparam integer SH_I1 = 21;  // pitch KI' = 0.0003075
localparam integer KD_M1  = 576;  localparam integer SH_D1 = 6;  // pitch KD' = 36
localparam integer MIX_LIM1 = 250;
localparam integer KP_M2  = 998;  localparam integer SH_P2 = 8;  // yaw KP' = 3.9
localparam integer KI_M2  = 0;  localparam integer SH_I2 = 0;  // yaw KI' = 0
localparam integer KD_M2  = 0;  localparam integer SH_D2 = 2;  // yaw KD' = 0
localparam integer MIX_LIM2 = 80;
