def gf_mul(a, b, n, red):
    """
    Multiply in GF(2^n) with reduction polynomial (without x^n term)
    """
    res = 0
    mask = (1 << n) - 1

    for _ in range(n):
        if b & 1:
            res ^= a
        b >>= 1

        # check overflow (bit n-1 before shift)
        if a & (1 << (n - 1)):
            a = ((a << 1) & mask) ^ red
        else:
            a = (a << 1) & mask

    return res


# === GF wrappers ===
def gf_mul_17(a, b):
    RED = (1 << 3) | 1   # x^3 + 1
    return gf_mul(a, b, 17, RED)


def gf_mul_25(a, b):
    RED = (1 << 3) | 1   # x^3 + 1
    return gf_mul(a, b, 25, RED)


# === CSS Simulation with jump ===
def css_simulation_gf_jump(key_hex, num_bytes=10):
    key_int = int(key_hex, 16)
    key_bin = bin(key_int)[2:].zfill(40)

    # init LFSR (CSS style)
    lfsr1 = int("1" + key_bin[:16], 2)   # 17 bit
    lfsr2 = int("1" + key_bin[16:], 2)   # 25 bit

    carry = 0
    keystream = []

    # x^8
    JUMP = 1 << 8

    print(f"Init LFSR1: {hex(lfsr1)}")
    print(f"Init LFSR2: {hex(lfsr2)}")
    print("-" * 60)
    print(f"{'Byte':<4} | {'LFSR1':<10} | {'LFSR2':<10} | {'Out':<4}")
    print("-" * 60)

    for i in range(num_bytes):
        # jump 8 steps (multiply by x^8)
        lfsr1 = gf_mul_17(lfsr1, JUMP)
        lfsr2 = gf_mul_25(lfsr2, JUMP)

        byte1 = lfsr1 & 0xFF
        byte2 = lfsr2 & 0xFF

        total = byte1 + byte2 + carry
        out_byte = total & 0xFF
        carry = 1 if total > 255 else 0

        keystream.append(out_byte)

        print(f"{i+1:<4} | {hex(lfsr1):<10} | {hex(lfsr2):<10} | {out_byte:<4}")

    return keystream


# === TEST ===
example_key = "85F8CE98A9"
out = css_simulation_gf_jump(example_key, num_bytes=5)
print("Keystream:", [hex(b) for b in out])
