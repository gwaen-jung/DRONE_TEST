# 🎙️ KỊCH BẢN THUYẾT TRÌNH 10 PHÚT & CẨM NANG 15 CÂU HỎI PHẢN BIỆN (Q&A) — VÒNG BÁN KẾT
**Cuộc thi Thiết kế Vi mạch cho Đô thị Thông minh lần 3 — Bảng Sinh viên**  
**Đề tài:** Thiết kế lõi IP/ASIC điều khiển bay số cố định 3 trục (`pid_ctrl`) siêu tiết kiệm năng lượng cho UAV Đô thị Thông minh  
**Đơn vị:** Nhóm **FPOLY UAV** — ReShape Lab, Bộ môn Điện – Cơ khí, FPT Polytechnic Đà Nẵng

---

## PHẦN 1: PHÂN VAI & KỊCH BẢN THUYẾT TRÌNH 10 PHÚT (THEO TỪNG SLIDE)

### 👥 Phân công 3 thành viên (Khớp Checklist BTC)
1. **Thành viên 1 — System & Application Lead (Nguyễn Trung / Cinq):**
   - Phụ trách: **Slide 1, 2, 3, 10** + Điều phối chung + Trả lời câu hỏi về **Hệ thống UAV thực tế, PCB 2-MCU, Cơ khí Quadcopter, AI Voice Copilot (Gemini Live)**.
2. **Thành viên 2 — RTL & Micro-Architecture Lead:**
   - Phụ trách: **Slide 4, 5, 6, 7** + Trả lời câu hỏi về **Fixed-Point Q.FE, Máy trạng thái FSM 20 chu kỳ, Chia sẻ 1 bộ nhân, Giao tiếp 7 chân `spi_pid_wrapper.v`, Synthesis/STA & FoM**.
3. **Thành viên 3 — Verification & Live Demo Lead:**
   - Phụ trách: **Slide 8, 9** + Bấm chạy lệnh Live Demo `run_demo_ban_ket.ps1` + Trả lời câu hỏi về **Golden Model Python, Bit-exact 16.000 mẫu, Fault Injection & Bẫy Anti-windup**.

---

### ⏱️ Chi tiết lời thoại & Điểm nhấn theo từng Slide (Tổng thời gian: 09 phút 30 giây)

#### **Slide 1 — Trang bìa & Câu giới thiệu 1 dòng (0:00 – 0:45 | Người nói: Thành viên 1)**
> *"Kính chào Hội đồng Ban Giám khảo. Nhóm em là **FPOLY UAV** đến từ FPT Polytechnic Đà Nẵng.  
> Để mở đầu bằng đúng một câu tóm tắt đề tài: **Nhóm em chuyển toàn bộ thuật toán điều khiển bay PID 3 trục và bộ trộn 4 động cơ đang chạy bằng phần mềm số thực trên vi điều khiển của nguyên mẫu Drone thực tế thành lõi vi mạch số cố định `pid_ctrl`, dùng duy nhất 1 bộ nhân chia sẻ theo thời gian để hoàn tất mỗi vòng lặp điều khiển chỉ trong 20 chu kỳ clock (2,0 µs tại 10 MHz) với năng lượng tiêu thụ mỗi vòng thấp hơn hơn 2 triệu lần so với MCU.**"*

#### **Slide 2 — Vị trí dự án trên Design Flow (0:45 – 1:35 | Người nói: Thành viên 1)**
> *"Thưa Hội đồng, để mọi con số kỹ thuật phía sau được hiểu đúng mức độ tin cậy — vì số Post-Synthesis khác số Post-Layout — nhóm xin định vị rõ dự án đang ở đâu trên luồng thiết kế Digital ASIC:  
> - **3 khối màu xanh đậm (Đã hoàn thành 100%)**: Nhóm đã chốt **Spec & Architecture** từ nguyên mẫu bay thực tế, hoàn thiện **RTL Verilog-2001** cho cả lõi `pid_ctrl` và vỏ bọc 7 chân `spi_pid_wrapper`, và vượt qua **Verification bit-exact 16.000/16.000 mẫu**.  
> - **Khối màu cam (Đang thực hiện tại Bán kết)**: Nhóm đã viết sẵn kịch bản tổng hợp **Cadence Genus & STA (`syn_genus.tcl`)** và đang kết nối PDK trong đợt tập huấn để lấy báo cáo Timing/Area/Power chuẩn Post-Synthesis.  
> - **2 khối nét đứt (Kế hoạch đến Chung kết)**: Thực hiện **Place & Route trên Cadence Innovus, kiểm tra DRC/LVS**, xuất **GDSII** và nhúng kiểm chứng phần cứng **Hardware-in-the-Loop trên FPGA**."*

#### **Slide 3 — Bài toán thực tế & Hệ sinh thái 5 trụ cột (1:35 – 2:35 | Người nói: Thành viên 1)**
> *"Điểm khác biệt của nhóm là con chip này không nằm trên giấy. Nó sinh ra từ chính hệ sinh thái Drone tuần tra đô thị mà nhóm đã tự thiết kế từ khung cơ khí Carbon, mạch PCB tích hợp, tay cầm RF, trạm mặt đất 3D cho tới trợ lý giọng nói AI:  
> - Hiện tại trên mạch bay, cảm biến **BNO085** xuất góc nghiêng ở tần số **400 Hz** (tức mỗi **2500 µs** mới có một mẫu mới).  
> - Nhưng vi điều khiển **STM32F103C8 (Cortex-M3, không có FPU)** phải gánh toàn bộ phép nhân chia dấu phẩy động 32-bit bằng phần mềm, tốn khoảng **18,5 µs** (~1330 chu kỳ CPU) và tiêu thụ gần **119 mW** liên tục chỉ để làm một việc lặp đi lặp lại.  
> - Vì vậy, nhóm tách riêng khối điều khiển thời gian thực khắt khe nhất này thành **lõi phần cứng chuyên dụng `pid_ctrl`**, giải phóng hoàn toàn MCU cho bài toán định vị GPS và giao tiếp AI."*

#### **Slide 4 — Đặc tả kỹ thuật (Specification) & Khảo sát Lượng tử hóa (2:35 – 3:40 | Người nói: Thành viên 2)**
> *"Để chuyển từ phần mềm sang phần cứng mà không cần mạch dấu phẩy động (FPU) hay bộ chia cồng kềnh, nhóm đổi toàn bộ hệ số sang định dạng dấu phẩy tĩnh **Q.FE** và biến mọi phép chia cho chu kỳ lấy mẫu `dt = 0,0025 s` thành **phép dịch phải bit số học (`>>>`)**.  
> Nhóm đã viết công cụ tự động `analyze.py` quét từ `FE = 4` đến `FE = 16` bit trên 7 kịch bản bay và phát hiện một tính chất vật lý rất quan trọng:  
> - Hệ số lọc đạo hàm `alpha = 0,2 = 1/5` trong nhị phân là phân số vô hạn tuần hoàn (`0,00110011...`), gây sai số làm tròn nếu ít bit.  
> - Từ đó nhóm cung cấp **2 cấu hình tham số hóa**:  
>   - **Cấu hình A (`FE = 10`, giữ nguyên `alpha = 0,2`)**: Dùng bộ nhân `14×29 bit`, sai số lớn nhất trên cả 16.000 mẫu chỉ **1 µs** (tương đương **0,1% độ rộng xung ESC**, nhỏ hơn nhiễu tự nhiên của cảm biến).  
>   - **Cấu hình B (`FE = 6`, tối ưu `alpha = 13/64 = 0,203125`)**: Khai thác mẫu số là lũy thừa của 2 để biểu diễn chính xác tuyệt đối chỉ với 6 bit lẻ, thu nhỏ bộ nhân xuống **11×21 bit** và đạt **sai số 0 µs tuyệt đối** trên toàn bộ 16.000 mẫu!"*

#### **Slide 5 — Kiến trúc Vi mạch & Máy trạng thái FSM 20 Chu kỳ (3:40 – 4:45 | Người nói: Thành viên 2)**
> *"Về vi kiến trúc (Micro-architecture), câu hỏi lớn nhất là: **Tại sao 3 trục Roll, Pitch, Yaw với 9 phép nhân lại chỉ dùng đúng 1 bộ nhân duy nhất?**  
> - Với tốc độ lấy mẫu IMU 400 Hz, chúng ta có tới **2500 µs** giữa 2 mẫu. Nếu đặt 3 bộ nhân song song sẽ tốn gấp 3 diện tích silicon nhưng 99,9% thời gian mạch chỉ nằm chờ.  
> - Thay vào đó, nhóm thiết kế **máy trạng thái hữu hạn 8 bước (FSM)** điều phối bộ chọn **MUX** nạp lần lượt các cặp toán hạng vào **1 bộ nhân có dấu duy nhất**:  
>   - Chu kỳ 1 (`S_LOAD`): chốt mẫu và trừ sai số 3 trục.  
>   - Mỗi trục lần lượt đi qua **6 chu kỳ** (`S_FILT1`, `S_FILT2`, `S_P`, `S_I`, `S_D`, `S_SAT`): 5 chu kỳ đầu dùng bộ nhân, chu kỳ thứ 6 cộng `P + I + D` và kẹp bão hòa `±400`.  
>   - 3 trục tốn `3 × 6 = 18` chu kỳ, cộng thêm 1 chu kỳ trộn 4 động cơ (`S_MIX`) là đúng **20 chu kỳ clock (2,0 µs tại 10 MHz)** — nhanh gấp **1250 lần** thời hạn cho phép!  
> - Đặc biệt, để chống hiện tượng **Pad-limited** khi đóng gói ASIC (do lõi có ~160 bit I/O song song), nhóm đã thiết kế thêm vỏ bọc **`spi_pid_wrapper.v`** gom toàn bộ giao tiếp về đúng **7 chân** (4 dây SPI Mode 0 + `clk`, `rst_n`, `irq_out_valid`)."*

#### **Slide 6 — Giản đồ sóng 20 Chu kỳ & Khắc phục Bẫy Anti-windup (4:45 – 5:40 | Người nói: Thành viên 2)**
> *"Trên giản đồ sóng RTL trích xuất trực tiếp từ mô phỏng, tại mốc `0 µs` khi có xung `sample_valid`, cờ `busy` lập tức dựng lên mức 1, FSM tuần tự duyệt qua trục `0 -> 1 -> 2` và đúng tại con trỏ màu cam **`+2,0 µs` (chu kỳ thứ 20)**, xung `out_valid` bật lên cùng 4 lệnh động cơ `m1..m4` hoàn toàn khớp với mô hình chuẩn.  
> Trong quá trình thiết kế RTL, nhóm cũng phát hiện và xử lý triệt để **bẫy bão hòa tích phân (Anti-windup)**: trong code C gốc, biến tích phân được cộng *trước* rồi mới xét điều kiện kẹp; nếu phần cứng kiểm tra cờ kẹp từ chu kỳ trước sẽ lệch ngay 1 bước tích phân. Mạch của nhóm giải quyết bằng cách tính sẵn cả 2 nhánh (`a_Accum` và `a_acc_cand`) và dùng MUX chọn nhánh ngay trong trạng thái `S_SAT`, đảm bảo khớp 100% hành vi của chuyến bay thực tế."*

#### **Slide 7 — Bảng So sánh với Published Designs & Chỉ số FoM (5:40 – 6:40 | Người nói: Thành viên 2)**
> *"Tuân thủ chuẩn trình bày của Ban Tổ chức, nhóm đặt thiết kế cạnh MCU thực tế trên Drone và các kiến trúc đã công bố, quy đổi về cùng chỉ số **FoM = Năng lượng tiêu thụ trên mỗi vòng lặp điều khiển 3 trục (nJ/loop)**:  
> - So với **STM32F103C8 (72 MHz)** tốn `18,5 µs` và `2197,8 nJ/loop`, lõi `pid_ctrl` của nhóm ở 10 MHz chỉ mất `2,0 µs` và hoạt động ở chế độ **Duty Cycle 0,08%** (nghỉ 99,92% thời gian), đưa mức tiêu thụ năng lượng mỗi vòng xuống dưới **0,001 nJ/loop**.  
> - So với kiến trúc **PID song song trên FPGA** dùng tới 9 khối DSP48E1, kiến trúc tuần tự chia sẻ **1 bộ nhân** của nhóm tiết kiệm ~65% diện tích logic tương đương (~3,1k – 4,2k GE) mà vẫn dư 99,92% thời gian thực."*

#### **Slide 8 & Slide 9 — Kiểm thử Bit-exact 16.000 Mẫu & Kịch bản Live Demo A-B-C (6:40 – 8:30 | Người nói: Thành viên 3)**
> *"Thưa Hội đồng, về mặt Kiểm thử (Verification), nhóm xây dựng hệ thống kiểm tra tự động **Self-checking Testbench** trên **16.000 mẫu vector** trải dài qua 7 kịch bản bay khắc nghiệt nhất: từ đứng yên, đáp ứng bậc thang Roll/Pitch, đảo chiều Yaw, cho đến kịch bản số 5 ép kẹp bão hòa Anti-windup và kịch bản số 6 kiểm tra khóa an toàn Disarm (`m1..m4 = 1000 µs`).  
> Ngay bây giờ, em xin phép chạy **Phương án A (Live Demo 1 lệnh trực tiếp)** qua script `run_demo_ban_ket.ps1` (và nhóm cũng đã chuẩn bị sẵn Phương án B — Video + Phương án C — Hình chụp trên Slide 9):"*  
> *(Bấm chạy lệnh PowerShell — màn hình hiện log biên dịch Icarus Verilog `-Wall` 0 warning và dòng chữ màu xanh lá: **`PASS: 16000/16000 mau khop bit-exact (20 chu ky/mau)`**)*  
> *"Không chỉ dừng ở việc báo PASS, để chứng minh Testbench không bị 'báo PASS giả', nhóm đã thực hiện **Fault Injection (tiêm lỗi chủ đích)**: sửa lệch đúng 1 LSB ở mẫu đầu tiên trong bộ đề, và Testbench lập tức bắt trúng lỗi `FAIL: 1/16000` ngay tức khắc!"*

#### **Slide 10 — Kế hoạch hoàn thiện đến Chung kết & Checklist BTC (8:30 – 9:30 | Người nói: Thành viên 1)**
> *"Từ nay đến Vòng Chung kết, nhóm tập trung vào 3 mục tiêu cụ thể:  
> 1. Chạy **Synthesis & STA trên Cadence Genus** và **Place & Route + DRC/LVS trên Cadence Innovus** ngay trong đợt đào tạo của Ban Tổ chức để điền số đo Post-Layout thực tế.  
> 2. Đổ bitstream lõi `pid_ctrl` + `spi_pid_wrapper` lên **board FPGA**, nối dây SPI 4-dây trực tiếp với mạch bay **QUAD-UAV** để trình diễn **Hardware-in-the-Loop (HIL)** kết hợp điều khiển giọng nói AI trực tiếp tại bàn chấm thi Chung kết.  
> Nhóm FPOLY UAV xin chân thành cảm ơn Hội đồng và rất mong nhận được các câu hỏi phản biện ạ!"*

---

## PHẦN 2: CẨM NANG 15 CÂU HỎI PHẢN BIỆN Hóc BÚA NHẤT TỪ GIÁM KHẢO & CÁCH TRẢ LỜI GỌN – TRÚNG ĐÍCH

### Nhóm câu hỏi 1: Kiến trúc Vi mạch & RTL (Micro-Architecture & Verilog)

#### **Câu 1: Tại sao nhóm chỉ dùng 1 bộ nhân cho cả 3 trục mà không dùng 3 bộ nhân song song cho nhanh?**
- **Trả lời (TV2):** Thưa thầy/cô, đây là quyết định đánh đổi **Area vs. Latency** dựa trên ràng buộc vật lý của cảm biến: IMU BNO085 cập nhật ở 400 Hz, tức cứ **2500 µs** mới có 1 mẫu. Với 1 bộ nhân duy nhất chạy ở clock chỉ 10 MHz, cả 3 trục tính xong trong **20 chu kỳ = 2,0 µs** (mới dùng hết **0,08%** thời gian cho phép). Nếu dùng 3 bộ nhân song song để giảm xuống 0,7 µs thì **diện tích silicon tăng gần gấp 3 lần** nhưng 2499,3 µs còn lại mạch vẫn phải nằm chờ mẫu IMU tiếp theo. Do đó, chia sẻ 1 bộ nhân qua MUX + FSM 20 chu kỳ là điểm tối ưu tuyệt đối về diện tích và công suất rò.

#### **Câu 2: Làm sao mạch thực hiện được phép chia cho chu kỳ lấy mẫu `dt = 0,0025 s` và nhân với `0,2` mà không có bộ chia phần cứng?**
- **Trả lời (TV2):** Trong công thức PID rời rạc:
  - Phép nhân với `dt = 0,0025` ở khâu Tích phân và phép chia cho `dt` ở khâu Đạo hàm đều là các hằng số cố định theo tần số lấy mẫu 400 Hz. Nhóm **gộp (fold) trực tiếp `dt` vào các hệ số tĩnh**: `ki_d = Ki · dt` và `kd_d = Kd / dt`, sau đó nhân trước với $2^{\text{FE}}$ để thành số nguyên (`KI_Q`, `KD_Q`).
  - Khi mạch chạy, sau khi nhân với số nguyên đó, phép chia cho $2^{\text{FE}}$ chỉ đơn giản là **dịch phải số học (`>>> FE`)** — tức nối dây lại trên phần cứng, tốn **0 cổng logic và 0 chu kỳ clock**.

#### **Câu 3: Lõi `pid_ctrl` có tới 119 bit đầu vào và 76 bit đầu ra (~195 chân tín hiệu). Nếu đem đi Tape-out ASIC thật thì chip sẽ bị Pad-limited (diện tích pad I/O lớn hơn diện tích logic). Nhóm giải quyết thế nào?**
- **Trả lời (TV2):** Nhóm đã lường trước chính xác vấn đề này và đã viết hoàn chỉnh module **`rtl/spi_pid_wrapper.v`** kèm testbench kiểm chứng bit-exact **`tb_spi_pid_wrapper.v`**. Wrapper này đóng gói toàn bộ khung dữ liệu 192-bit vào giao tiếp **SPI Slave Mode 0 chỉ gồm 4 dây** (`spi_sclk`, `spi_cs_n`, `spi_mosi`, `spi_miso`) cộng với `clk`, `rst_n` và chân báo ngắt `irq_out_valid` — tổng cộng **chỉ 7 chân tín hiệu**, cho phép đóng gói chip vào vỏ nhỏ gọn như **SOP-8 hoặc QFN-16** mà không hề bị Pad-limited.

#### **Câu 4: Trong `spi_pid_wrapper.v`, tín hiệu `spi_sclk` từ ESP32 gửi sang lệch pha với clock hệ thống `clk` của chip. Nhóm xử lý đồng bộ miền xung nhịp (CDC / Metastability) như thế nào?**
- **Trả lời (TV2):** Nhóm sử dụng kỹ thuật **Multi-stage Flip-Flop Synchronizer** kinh điển và an toàn trong thiết kế số: tín hiệu `spi_sclk` và `spi_cs_n` được đưa qua **thanh ghi dịch 3 tầng D-FF (`sclk_sync[2:0]`, `csn_sync[2:0]`)** đồng bộ theo cạnh lên của `clk` hệ thống (với $f_{\text{clk}} \ge 4 \times f_{\text{SCLK}}$), và phát hiện cạnh lên/cạnh xuống bằng logic `sclk_sync[2:1] == 2'b01`. Cách này triệt tiêu hoàn toàn hiện tượng Metastability mà không cần tạo thêm miền clock thứ hai trong lúc chạy STA.

#### **Câu 5: Đường критический (Critical Path) dài nhất trong mạch `pid_ctrl.v` nằm ở đâu? Tần số tối đa $f_{\max}$ ước tính là bao nhiêu và nếu muốn đẩy lên >200 MHz thì sửa thế nào?**
- **Trả lời (TV2):** Đường tổ hợp dài nhất (Critical Path) hiện nằm ở **bộ nhân có dấu `14×29 bit` (Cấu hình A) hoặc `11×21 bit` (Cấu hình B)** nối tiếp với bộ dịch phải `>>>`. Trên tiến trình CMOS 180 nm hoặc 130 nm, bộ nhân `14×29` tổ hợp có độ trễ khoảng `4,5 – 6,5 ns`, tức mạch dư sức đạt **$f_{\max} \approx 100 - 150\,\text{MHz}$** (cao gấp 10 lần tần số yêu cầu 10 MHz). Nếu cần đẩy lên `>250 MHz`, ta chỉ cần chèn **1 tầng thanh ghi Pipeline ở giữa bộ nhân** (tăng lịch FSM từ 20 lên 23 chu kỳ clock).

---

### Nhóm câu hỏi 2: Lượng tử hóa Fixed-Point, Thuật toán Điều khiển & Cỡ Bit

#### **Câu 6: Tại sao Cấu hình B (`FE = 6`, ít bit hơn) lại có sai số `0 µs` trên cả 16.000 mẫu, trong khi Cấu hình A (`FE = 10`, nhiều bit hơn) lại có 13 mẫu lệch `1 µs`?**
- **Trả lời (TV2):** Vì ở Cấu hình A, nhóm giữ nguyên hệ số lọc `alpha = 0,2 = 1/5` của code STM32. Trong hệ nhị phân, `1/5 = 0,001100110011...` là số thập phân vô hạn tuần hoàn, nên dù lấy `FE = 10` bit (`205/1024 = 0,2001953125`) vẫn còn một sai số làm tròn cực nhỏ `0,000195`, dẫn đến ở 13/16.000 mẫu tại ranh giới làm tròn `.5` bị lệch đúng 1 LSB (`1 µs`). Còn ở Cấu hình B, nhóm đề xuất đổi `alpha` thành **`13/64 = 0,203125`** — vì mẫu số `64 = 2^6` nên biểu diễn nhị phân **chính xác tuyệt đối không dư một bit nào** ở `FE = 6`, giúp phần cứng và phần mềm trùng khớp 100% (0 lỗi trên 16.000 mẫu) mà còn tiết kiệm được 7 bit chiều rộng thanh ghi!

#### **Câu 7: Nhóm tính toán độ rộng thanh ghi (`W_IN = 22`, `W_ACC = 27`, `W_DF = 28`) dựa trên cơ sở nào để dám khẳng định mạch "không bao giờ tràn số (No Overflow)"?**
- **Trả lời (TV2):** Nhóm tính theo **cận trên vật lý tuyệt đối (Worst-case Range Analysis)** trong `model/analyze.py`:
  - Góc nghiêng/setpoint giới hạn trong `±180°`, tốc độ góc gyro cảm biến BNO085/MPU6050 tối đa `±2000°/s`. Với `FE = 10` (nhân 1024), giá trị lớn nhất là `2000 × 1024 = 2.048.000 < 2^21`, thêm 1 bit dấu là đúng **`W_IN = 22 bit`**.
  - Thanh ghi tích phân `A` được bảo vệ bởi cơ chế Anti-windup kẹp cứng ở `±400`, nên ngay cả khi cộng thêm 1 bước sai số cực đại trước khi kẹp, nó không bao giờ vượt quá `2^26`, tức **`W_ACC = 27 bit`** là an toàn tuyệt đối.

#### **Câu 8: "Bẫy Anti-windup" mà nhóm nhắc đến trong Slide 6 cụ thể là gì?**
- **Trả lời (TV3):** Trong hàm C trên STM32:
  ```c
  integral_roll += error_roll * dt;
  float out = Kp*error + Ki*integral_roll + Kd*d_filt;
  if (out > 400) { out = 400; integral_roll -= error_roll * dt; }
  ```
  Tức là phần mềm **cộng tích phân mới vào trước**, dùng giá trị mới đó để tính `out`, rồi nếu `out` vượt `±400` mới **trừ trả lại** (`khôi phục tích phân cũ`). Trong mạch phần cứng tuần tự, bước tính `I = KI_Q * A` diễn ra ở trạng thái `S_I`, còn bước biết tổng `P + I + D` có vượt `±400` hay không lại nằm ở trạng thái `S_SAT` (2 nhịp sau đó). Do đó ở trạng thái `S_I`, mạch phải nhân `KI_Q` với **tích phân ứng viên `a_acc_cand = a_A + e`** (đã cộng trước), rồi đến `S_SAT` nếu thấy tràn mới giữ nguyên `a_Accum` cũ, không tràn mới gán `a_Accum <= a_acc_cand`. Nhờ vậy mới đạt Bit-exact 100%.

#### **Câu 9: Nhóm có phát hiện lỗi tiềm ẩn nào trong chính code C gốc của STM32 khi làm mô hình chuẩn không?**
- **Trả lời (TV1):** Dạ có! Khi viết Golden Model, nhóm phát hiện trên STM32 khi hạ cần ga Disarm (`armed = 0`), code C chỉ xuất `1000 µs` ra 4 motor nhưng **quên không xóa thanh ghi tích phân `integral`** và bộ nhớ đạo hàm `prev_error`. Nếu lần bay trước tích phân đang bị tích tụ lớn, lần Arm tiếp theo drone sẽ bị giật nghiêng ngay lúc cất cánh. Trên chip `pid_ctrl`, nhóm vừa giữ tương thích bit-exact với hành vi cũ khi `clear = 0`, vừa thiết kế riêng chân **`clear` đồng bộ** để MCU hoặc phần cứng tự động xóa sạch toàn bộ trạng thái PID ngay khi Disarm!

---

### Nhóm câu hỏi 3: So sánh Hiệu năng (FoM, Normalization) & Kiểm thử (Verification)

#### **Câu 10: Công thức tính FoM = 2197,8 nJ/loop của STM32F103C8 và <0,001 nJ/loop của ASIC được tính cụ thể như thế nào?**
- **Trả lời (TV2):** Chỉ số **FoM (Figure of Merit)** cho bộ điều khiển thời gian thực theo chu kỳ lấy mẫu cố định là **Năng lượng tiêu thụ cho 1 vòng lặp tính toán 3 trục (`Energy per Control Loop`)**:
  $$E_{\text{loop}} = P_{\text{active}} \times T_{\text{exec}}$$
  - Với **STM32F103C8T6** ở 72 MHz ($V_{DD} = 3,3\,\text{V}$, $I_{DD} \approx 36\,\text{mA} \Rightarrow P_{\text{active}} \approx 118,8\,\text{mW}$), thời gian tính 3 trục float32 + mixer là $T_{\text{exec}} \approx 18,5\,\mu\text{s}$:
    $$E_{\text{loop, MCU}} = 118,8\,\text{mW} \times 18,5\,\mu\text{s} = 2197,8\,\text{nJ}$$
  - Với **Lõi `pid_ctrl` ASIC** ước lượng ở 10 MHz ($P_{\text{dynamic}} \approx 0,32 - 0,45\,\text{mW}$ khi chạy), thời gian tính đúng 20 chu kỳ là $T_{\text{exec}} = 2,0\,\mu\text{s}$:
    $$E_{\text{loop, ASIC}} = 0,45\,\text{mW} \times 2,0\,\mu\text{s} = 0,9\,\text{pJ} = 0,0009\,\text{nJ}$$

#### **Câu 11: Khi so sánh thiết kế của nhóm (ví dụ trên PDK 180 nm) với một bài báo dùng tiến trình 130 nm hoặc 65 nm, nhóm quy đổi (Normalize) như thế nào?**
- **Trả lời (TV2):** Nhóm áp dụng chuẩn **CMOS Technology Scaling Normalization**:
  - Về **Diện tích (Area)**: Quy về đơn vị độc lập công nghệ là **Gate Equivalent ($\text{GE} = \text{Area} / \text{Area}_{\text{NAND2\_X1}}$)**, hoặc quy đổi diện tích vật lý theo bình phương tỉ lệ chiều dài kênh dẫn $S = L_1 / L_2$: $A_{\text{norm}} = A / S^2$.
  - Về **Năng lượng/Công suất**: Quy đổi theo cả tỉ lệ kích thước $S$ và bình phương tỉ lệ điện áp nguồn $U = V_{DD1} / V_{DD2}$: $E_{\text{norm}} = E / (S \cdot U^2)$.

#### **Câu 12: 16.000 mẫu trong `vectors.txt` có đảm bảo kích hoạt hết các nhánh logic (Code Coverage / Branch Coverage) trong `pid_ctrl.v` không?**
- **Trả lời (TV3):** Dạ đạt **100% State Coverage và 100% Branch Coverage** cho toàn bộ các nhánh điều khiển chính, vì 7 kịch bản được thiết kế có chủ đích để quét qua mọi biên:
  - Kịch bản 1: Sai số = 0 (kiểm tra điểm tĩnh).
  - Kịch bản 2, 3, 4: Đáp ứng bậc thang dương/âm trên từng trục Roll (`axis=0`), Pitch (`axis=1`), Yaw (`axis=2`) — quét hết cả 3 nhánh MUX chọn trục.
  - Kịch bản 5: Cố tình giữ sai số lớn trong 2000 mẫu để ép tổng `u'` vượt cả ngưỡng trên `+400` lẫn ngưỡng dưới `-400` — kích hoạt 100% các nhánh kẹp bão hòa `u_sat` và nhánh chống bão hòa tích phân `sat_hi / sat_lo`.
  - Kịch bản 6: Đảo cờ `armed = 0` và `armed = 1` cùng xung `clear = 1` giữa các kịch bản — kích hoạt nhánh khóa an toàn động cơ `1000 µs` và nhánh kẹp xung ESC `[1000, 2000] µs`.
  - Kịch bản 7: Nhiễu ngẫu nhiên biên độ lớn kiểm tra tổ hợp đồng thời cả 3 trục.

---

### Nhóm câu hỏi 4: Ứng dụng Thực tế, Tích hợp Hệ thống & Định hướng Chung kết

#### **Câu 13: Tại sao trục Yaw lại chỉ dùng góc quay vận tốc `gz` từ Gyro mà không dùng góc Euler như Roll và Pitch?**
- **Trả lời (TV1):** Trong cơ học bay Quadcopter, người lái điều khiển trục Roll và Pitch theo chế độ **Angle Stabilize Mode** (buông tay cần là máy bay tự cân bằng về góc $0^\circ$), nên đầu vào là góc nghiêng tuyệt đối (`roll`, `pitch` đơn vị độ). Ngược lại, trục Yaw (xoay mũi máy bay) hoạt động ở chế độ **Rate Mode** (người lái đẩy cần Yaw để quay mũi với tốc độ góc mong muốn, buông cần là giữ nguyên hướng mũi hiện tại chứ không quay ngược về hướng Bắc ban đầu), nên đầu vào phản hồi của trục Yaw là tốc độ góc `gz` (đơn vị độ/giây) và hệ số tích phân `Ki_yaw = 0`. Lõi `pid_ctrl` của nhóm tham số hóa riêng hệ số cho trục Yaw nên hỗ trợ hoàn hảo cả 2 chế độ này.

#### **Câu 14: Trợ lý AI Giọng nói (Gemini Live) và Trạm mặt đất liên kết với con chip PID này như thế nào?**
- **Trả lời (TV1):** Trong kiến trúc 2 tầng của nhóm:
  - **Tầng Cao (High-level Autonomy)**: Trợ lý AI giọng nói và MCU chính (ESP32) xử lý ngôn ngữ tự nhiên (ví dụ lệnh thoại *"Bay tuần tra khu vực A, giữ độ cao 15m"*) để sinh ra các **Setpoint góc mục tiêu (`sp_roll`, `sp_pitch`, `sp_yaw`)** và mức ga `throttle`.
  - **Tầng Thấp (Hard Real-time Silicon)**: Lõi vi mạch `pid_ctrl` nhận các Setpoint đó qua bus SPI 7 chân cùng góc đo từ IMU 400 lần/giây để khóa cứng tư thế bay trong 2,0 µs. Nhờ có chip `pid_ctrl` gánh trọn vòng lặp 400 Hz, ESP32 không bao giờ bị trễ nhịp điều khiển khi đang bận xử lý gói tin WiFi/RF hay luồng âm thanh AI.

#### **Câu 15: Từ nay đến Chung kết, làm sao nhóm chứng minh được con chip này điều khiển bay được thật khi chưa kịp đúc chip silicon (Tape-out mất nhiều tháng)?**
- **Trả lời (TV1 & TV3):** Nhóm sẽ thực hiện **Hardware-in-the-Loop (HIL) trên board FPGA** song song với bản vẽ Layout GDSII trên Cadence Innovus:
  1. Trên **Cadence Genus & Innovus**: Xuất đầy đủ báo cáo Post-Layout STA, Power, Area, DRC/LVS Clean và bản vẽ GDSII của chip.
  2. Trên **Phần cứng thực tế**: Nạp đúng file RTL `pid_ctrl.v` + `spi_pid_wrapper.v` lên board FPGA, nối 4 dây SPI trực tiếp vào mạch PCB Drone thực tế (thay thế hoàn toàn con chip STM32F103 hiện tại) để điều khiển 4 động cơ Brushless trên khung Quadcopter Carbon ngay tại bàn chấm thi Chung kết!

---

## PHẦN 3: CHECKLIST KIỂM TRA LẦN CUỐI TRƯỚC GIỜ BÁO CÁO (15 PHÚT TRƯỚC KHI LÊN SÓNG)

- [x] **Mở sẵn file Slide PDF 16:9**: `ic/doc/FPOLY_UAV_Bao_Cao_Ban_Ket_Slides.pdf` ở chế độ Fullscreen (`Ctrl + L`).
- [x] **Mở sẵn cửa sổ PowerShell** tại thư mục gốc `D:\TRIAD_PROJECT\Projects\TRIAD_CODE_SPACE\DRONE_TEST`, gõ sẵn lệnh:
  ```powershell
  powershell -ExecutionPolicy Bypass -File ic/sim/run_demo_ban_ket.ps1
  ```
  *(Chỉ chờ đến Slide 8 là bấm `Enter` — chạy mất đúng 2 giây!)*
- [x] **Mở sẵn file Báo cáo giải thích chi tiết (Word/PDF)**: `ic/doc/FPOLY_UAV_chip_PID_giai_thich.pdf` ở tab bên cạnh để nếu Giám khảo hỏi sâu vào bảng tính bit hoặc sơ đồ đấu nối nguyên mẫu (Phụ lục A1–A3) là chiếu lên ngay.
- [x] **Kiểm tra Phương án B & C**: Nếu máy chiếu phòng thi không cho mở terminal, lật ngay sang **Slide 9** (đã có sẵn khung hình 4-trong-1 gồm Waveform có cursor `+2.0 µs`, Log `PASS 16000/16000`, Sơ đồ khối kiến trúc và Phụ đề kết quả).
