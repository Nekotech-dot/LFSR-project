Explaination for lfsr_8bit_galois_field.

Overview: 
Simulating digital model of pseudo-random number generater through 8 bit LFSR (linear-feedback shift register)

Architecture: Galois Field Implementation

Polynomial: x^8 + x^4 + x^3 + x^2 + 1

Shift: Left direction( << 1 )

Taps configuration: 00011101
                  
                 MSB      LSB
Bit-Width: 1 byte (8 bits)

Max-sequence: 255

Prerequisites: Python 3.x

Logic:
Shift 7 bit to the right to take the MSB of the seed gotten in

Basing on the value of MSB, 0 or 1, the seed would shift 1 bit to the left or shift 1 bit to the left and use XOR logic with taps to generate number.

Explain:

When MSB = 1, the shift register was overflowed, now exists a extra ninth bit.

Hence, we need to use the Polynomial to have register keeping the sequence pseudo-random.

The XOR with Taps performs this feedback, effectively replacing the overflowing bit with the pattern defined by the polynomial.
