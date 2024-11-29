#include <stdio.h>
#include <stdlib.h>

#define LCS _lrotl //left circular shift
#define u64 unsigned long long
#define f(x) ((LCS(x,1) & LCS(x,8)) ^ LCS(x,2))
#define R2(x,y,k1,k2) (y^=f(x), y^=k1, x^=f(y), x^=k2)

#include <stdint.h>
uint32_t _lrotl(uint32_t value, unsigned int count) {
    return (value << count) | (value >> (32 - count));
}

/* Simon64/128
Key: 1b1a1918 13121110 0b0a0908 03020100
Plaintext: 656b696c 20646e75
Ciphertext: 44c8fc20 b9dfa07a */

/*Simon128/128
Key: 0f0e0d0c0b0a0908 0706050403020100
Plaintext: 6373656420737265 6c6c657661727420
Ciphertext: 49681b1e1e54fe3f 65aa832af84e0bbc*/

void Simon128Encrypt(u64 pt[], u64 ct[], u64 k[])
{
    u64 i;
    ct[0] = pt[0]; 
    ct[1] = pt[1];
    for(i = 0; i < 68; i += 2) {
        R2(ct[1], ct[0], k[i], k[i + 1]);
    }
}

//0x0706050403020100
//0x0f0e0d0c0b0a0908

z = [0b11111010001001010110000111001101111101000100101011000011100110,
0b10001110111110010011000010110101000111011111001001100001011010,
0b10101111011100000011010010011000101000010001111110010110110011,
0b11011011101011000110010111100000010010001010011100110100001111,
0b11010001111001101011011000100000010111000011001010010011101111];

int main()
{   
    // Example plaintext and key values (you should replace these with correct values)
    u64 pt[] = {0x6373656420737265, 0x6c6c657661727420};   // Plaintext (2 elements)
    u64 ct[] = {0, 0};   // Ciphertext (2 elements)
    u64 k[]  = {0x0f0e0d0c0b0a0908, 0x0706050403020100}; // Example round keys (add more as needed)

    printf("Before encryption:\n");
    printf("pt = %llx %llx\n", pt[0], pt[1]);
    printf("ct = %llx %llx\n", ct[0], ct[1]);

    Simon128Encrypt(pt, ct, k);

    printf("After encryption:\n");
    printf("pt = %llx %llx\n", pt[0], pt[1]);
    printf("ct = %llx %llx\n", ct[0], ct[1]);

    return 0;
}
