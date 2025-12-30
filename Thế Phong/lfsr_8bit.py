class GaloisLFSR_LeftShift:
    def __init__(self, seed):
        self.state = seed & 0xFF  # Đảm bảo chỉ dùng 8 bit
        if self.state == 0:
            raise ValueError("Seed không thể là 0.")
        # Tương ứng: x^8(implied), x^6, x^5, x^4
        # Vì dịch trái, ta kiểm tra MSB, nếu MSB=1 thì XOR với phần còn lại
        self.taps = 0b00011101

    def next_state(self):
        # Kiểm tra bit cao nhất (Bit 7 - MSB)
        msb = (self.state >> 7) & 1
        
        # Dịch TRÁI 1 bit
        self.state = (self.state << 1) & 0xFF
        if msb == 1:
            self.state = self.state ^ self.taps
            
        return self.state

# --- PHẦN CHẠY THỬ ---

# Cấu hình:
# Seed (hạt giống) = 10101100 (tùy chọn, miễn khác 0)
# Taps (đa thức)   = 10110100 (x^8 + x^6 + x^5 + x^4 + 1)
my_lfsr = GaloisLFSR_LeftShift(seed=0b10100011)

print("--- Bắt đầu chạy tìm chu kỳ ---")

# 1. Lưu lại trạng thái xuất phát để làm mốc so sánh
gia_tri_ban_dau = my_lfsr.state 
dem_buoc = 0

# 2. Dùng while True để lặp "vô tận" cho đến khi ta ra lệnh dừng
while True:
    # Tính trạng thái tiếp theo
    ket_qua = my_lfsr.next_state()
    dem_buoc += 1 # Tăng biến đếm bước nhảy
    
    # In ra kết quả
    print(f"Bước {dem_buoc}: {ket_qua:08b}")
    
    # 3. ĐIỀU KIỆN DỪNG
    if ket_qua == gia_tri_ban_dau:
        print(f"--> Đã phát hiện lặp lại! Chu kỳ dừng sau {dem_buoc} bước.")
        break