#include <stdint.h>
#include <stdio.h>
#include "Functions.h"

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint64_t u64;
typedef uint32_t u32;

static u8 z0[62] =
{1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0};

void KeyExpansion ( u16 k[] )
{
    u8 i;
    u16 tmp;
    u16 tm1;
    u16 tm2;
    for ( i=4 ; i<32 ; i++ )
    {
        tmp = ROTATE_RIGHT_16(k[i-1],3);
        printf("tmp: 0x%x\n", tmp);
        tm1 = tmp ^ k[i-3];
        printf("tm1: 0x%x\n", tm1);
        tm2 = tm1 ^ ROTATE_RIGHT_16(tm1,1);
        printf("tm2: 0x%x\n", tm2);
        k[i] = ~k[i-4] ^ tm2 ^ z0[i-4] ^ 3;
        printf("k[i]: 0x%x\n", k[i]);
        printf("z0[i-4]: 0x%x\n", z0[i-4]);
        printf("clé numéro i %d\t, %d\n", i, k[i]);
        //k[i] = ~k[i-4] ^ ROTATE_RIGHT_16(k[i-1],3)^ k[i-3] ^ ROTATE_RIGHT_16(ROTATE_RIGHT_16(k[i-1],3)^k[i-3],1) ^ z0[i-4] ^ 3;
    }
}

void Encrypt ( u16 text[], u16 crypt[], u16 key[] )
{
    u8 i;
    u16 tmp;
    crypt[0] = text[0];
    crypt[1] = text[1];

    for ( i=0 ; i<32 ; i++ )
    {
        tmp = crypt[0];
        crypt[0] = crypt[1] ^ ((ROTATE_LEFT_16(crypt[0],1)) & (ROTATE_LEFT_16(crypt[0],8))) ^ (ROTATE_LEFT_16(crypt[0],2)) ^ key[i];
        crypt[1] = tmp;
    }
}

void Decrypt ( u16 text[], u16 crypt[], u16 key[] )
{
    u8 i;
    u32 tmp;
    crypt[0] = text[0];
    crypt[1] = text[1];

    for ( i=0 ; i<32 ; i++ )
    {
        tmp = crypt[1];
        crypt[1] = crypt[0] ^ ((ROTATE_LEFT_16(crypt[1],1)) & (ROTATE_LEFT_16(crypt[1],8))) ^ (ROTATE_LEFT_16(crypt[1],2)) ^ key[31-i];
        crypt[0] = tmp;
    }
}

int main ()
{
    /*
    u16 text[2];
    text[0] = 0x6565;
    text[1] = 0x6877;
    u16 crypt[2] = {0};
    u16 k[32];

    
    k[0] = 0x0100;
    k[1] = 0x0908;
    k[2] = 0x1110;
    k[3] = 0x1918;

    printf("k[0]: 0x%x\n", k[0]);
    printf("k[1]: 0x%x\n", k[1]);
    printf("k[2]: 0x%x\n", k[2]);
    printf("k[3]: 0x%x\n", k[3]);

        char input;
        
        
    KeyExpansion ( k );
    Encrypt ( text, crypt, k );
    printf("%x %x\n%x %x\n\n\n", text[0], text[1], crypt[0], crypt[1]);
        
    KeyExpansion ( k );
    Decrypt ( crypt, text, k );
    printf("%x %x\n%x %x\n\n\n", text[0], text[1], crypt[0], crypt[1]);
        printf("Press ENTER To Exit");
        getchar();*/

    for (int i= 61; i > 0; i--)
    {
        printf("%d",z0[i]);
    }
    return 0;
}