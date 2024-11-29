#include <stdio.h>
#include <stdint.h>

#define LCS(x, shift, word_size) (((x) << (shift)) | ((x) >> ((word_size) - (shift)))) // Left Circular Shift
#define RCS(x, shift, word_size) (((x) >> (shift)) | ((x) << ((word_size) - (shift)))) // Right Circular Shift

typedef uint64_t u64;
typedef uint32_t u32;
typedef uint8_t u8;

// Example z-sequences (predefined)
/*const u64 z_sequences[5] = {
    0b11111010001001010110000111001101111101000100101011000011100110,
    0b10001110111110010011000010110101000111011111001001100001011010,
    0b10101111011100000011010010011000101000010001111110010110110011,
    0b11011011101011000110010111100000010010001010011100110100001111,
    0b11010001111001101011011000100000010111000011001010010011101111
};*/

static u8 z0[62] =
{1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0};

/*
void KeyExpansion ( u16 k[] )
{
    u8 i;
    u16 tmp;
    for ( i=4 ; i<32 ; i++ )
    {
        tmp = ROTATE_RIGHT_16(k[i-1],3);
        tmp = tmp ^ k[i-3];
        tmp = tmp ^ ROTATE_RIGHT_16(tmp,1);
        k[i] = ~k[i-4] ^ tmp ^ z0[i-4] ^ 3;
    }
}*/

void simon_key_expansion(u64 *k, u64 *round_keys, int m, int T, int word_size, int z_index) {
    for (int i = 0; i < m; i++) {
        round_keys[i] = k[i];
    }

    for (int i = m; i < T; i++) {
        u64 tmp = RCS(round_keys[i - 1], 3, word_size);
        if (m == 4) {
            tmp ^= round_keys[i - 3];
        }
        tmp ^= RCS(tmp, 1, word_size);
        round_keys[i] = ~round_keys[i - m] ^ tmp ^ z0[i-m] ^ 3;
    }
}

void simon_encrypt(u64 *x, u64 *y, u64 *round_keys, int T, int word_size) {
    for (int i = 0; i < T; i++) {
        u64 tmp = *x;
        *x = *y ^ (LCS(*x, 1, word_size) & LCS(*x, 8, word_size)) ^ LCS(*x, 2, word_size) ^ round_keys[i];
        *y = tmp;
    }
}

int main() {
    int n = 16;  // word size
    int m = 4;   // number of key words
    int T = 32;  // number of rounds
    int z_index = 0;  // z-sequence index

    u64 key[4] = {0x1918, 0x1110 ,0x0908 ,0x0100};
    u64 round_keys[T];
    u64 x = 0x6565;
    u64 y = 0x6877;

    simon_key_expansion(key, round_keys, m, T, n, z_index);
    printf("Plaintext: %llx %llx\n", x, y);
    simon_encrypt(&x, &y, round_keys, T, n);
    printf("Ciphertext: %llx %llx\n", x, y);

    return 0;
}

