# Rotation circulaire gauche
def rotate_left(val, r_bits, bit_size=16):
    return ((val << r_bits) & (2**bit_size - 1)) | (val >> (bit_size - r_bits))

# Rotation circulaire droite
def rotate_right(val, r_bits, bit_size=16):
    return (val >> r_bits) | ((val & (2**r_bits - 1)) << (bit_size - r_bits))

# Constante de z0 (même que votre code C)
z0 = [
    1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,
    0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0
]

def key_expansion(k):
    """ Expansion de clé pour l'algorithme SIMON """
    for i in range(4, 32):
        tmp = rotate_right(k[i-1], 3)
        print(f"tmp: 0x{tmp:X}")
        tm1 = tmp ^ k[i-3]
        print(f"tm1: 0x{tm1:X}")
        tm2 = tm1 ^ rotate_right(tm1, 1)
        print(f"tm2: 0x{tm2:X}")
        k.append(~k[i-4] & 0xFFFF ^ tm2 ^ z0[i-4] ^ 3)  # Masque pour simuler u16
        print(f"k[{i}]: 0x{k[i]:X}, z0[{i-4}]: 0x{z0[i-4]:X}")

def encrypt(text, k):
    """ Chiffrement SIMON """
    crypt = [text[0], text[1]]

    for i in range(32):
        tmp = crypt[0]
        crypt[0] = crypt[1] ^ ((rotate_left(crypt[0], 1) & rotate_left(crypt[0], 8))) ^ (rotate_left(crypt[0], 2)) ^ k[i]
        crypt[1] = tmp
        print(f"Round {i}: {crypt[0]:04X} {crypt[1]:04X}")

    return crypt

def decrypt(crypt, k):
    """ Déchiffrement SIMON """
    text = [crypt[0], crypt[1]]

    for i in range(32):
        tmp = text[1]
        text[1] = text[0] ^ ((rotate_left(text[1], 1) & rotate_left(text[1], 8))) ^ (rotate_left(text[1], 2)) ^ k[31-i]
        text[0] = tmp

    return text

# === MAIN ===
if __name__ == "__main__":
    # Initialisation des valeurs
    text = [0x6565, 0x6877]
    k = [0x0100, 0x0908, 0x1110, 0x1918]

    print(f"k[0]: 0x{k[0]:X}")
    print(f"k[1]: 0x{k[1]:X}")
    print(f"k[2]: 0x{k[2]:X}")
    print(f"k[3]: 0x{k[3]:X}")

    # Expansion de clé
    key_expansion(k)

    # Chiffrement
    print("\n=== ENCRYPTION ===")
    crypt = encrypt(text, k)
    print(f"Chiffré: {crypt[0]:04X} {crypt[1]:04X}\n")

    # Déchiffrement
    print("\n=== DECRYPTION ===")
    decrypted = decrypt(crypt, k)
    print(f"Déchiffré: {decrypted[0]:04X} {decrypted[1]:04X}\n")

    # Vérification
    if decrypted == text:
        print("Le déchiffrement est correct!")
    else:
        print("Erreur dans le déchiffrement!")
