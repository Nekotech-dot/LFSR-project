def gf_mul_25(a, b):
    RED = (1 << 22) | 1
    res = 0
    for _ in range(25):
        if b & 1:
            res ^= a
        b >>= 1
        if a & (1 << 24):
            a = ((a << 1) & 0x1FFFFFF) ^ RED
        else:
            a = (a << 1) & 0x1FFFFFF
    return res


def gf_mul_17(a, b):
    RED = (1 << 15) | 1
    res = 0
    for _ in range(17):
        if b & 1:
            res ^= a
        b >>= 1
        if a & (1 << 16):
            a = ((a << 1) & 0x1FFFF) ^ RED
        else:
            a = (a << 1) & 0x1FFFF
    return res


def css_simulation_gf_jump(key_hex, num_bytes=10):
    key_int = int(key_hex, 16)
    key_bin = bin(key_int)[2:].zfill(40)

    lfsr1 = int("1" + key_bin[:16], 2)   # 17 bit
    lfsr2 = int("1" + key_bin[16:], 2)   # 25 bit

    carry = 0
    keystream = []

    JUMP1 = 1 << 8
    JUMP2 = 1 << 8

    print(f"Init LFSR1: {hex(lfsr1)}")
    print(f"Init LFSR2: {hex(lfsr2)}")
    print("-" * 60)
    print(f"{'Byte':<4} | {'LFSR1':<10} | {'LFSR2':<10} | {'Out':<4}")
    print("-" * 60)

    for i in range(num_bytes):
        # === NHẢY 8 BƯỚC LFSR ===
        lfsr1 = gf_mul_17(lfsr1, JUMP1)
        lfsr2 = gf_mul_25(lfsr2, JUMP2)

        byte1 = lfsr1 & 0xFF
        byte2 = lfsr2 & 0xFF

        total = byte1 + byte2 + carry
        out_byte = total & 0xFF
        carry = 1 if total > 255 else 0

        keystream.append(out_byte)

        print(f"{i+1:<4} | {hex(lfsr1):<10} | {hex(lfsr2):<10} | {out_byte:<4}")

    return keystream

example_key = "85F8CE98A9"

out = css_simulation_gf_jump(example_key, num_bytes=5)
print("Keystream:", [hex(b) for b in out])
# Ví dụ chạy thử