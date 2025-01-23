import serial
import time
import random

def rotate_left(val, r_bits, bit_size=16):
    return ((val << r_bits) & (2**bit_size - 1)) | (val >> (bit_size - r_bits))

def rotate_right(val, r_bits, bit_size=16):
    return (val >> r_bits) | ((val & (2**r_bits - 1)) << (bit_size - r_bits))

def key_expansion(k):
    z0 = [1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0]
    for i in range(4, 32):
        tmp = rotate_right(k[i-1], 3)
        tm1 = tmp ^ k[i-3]
        tm2 = tm1 ^ rotate_right(tm1, 1)
        k.append(~k[i-4] & 0xFFFF ^ tm2 ^ z0[i-4] ^ 3)

def encrypt(text, k):
    crypt = [text[0], text[1]]
    for i in range(32):
        tmp = crypt[0]
        crypt[0] = crypt[1] ^ ((rotate_left(crypt[0], 1) & rotate_left(crypt[0], 8))) ^ (rotate_left(crypt[0], 2)) ^ k[i]
        crypt[1] = tmp
    return crypt

def send_to_fpga(ser, k, text):
    ser.write(bytes([0x01]))
    time.sleep(1)
    for ki in k:
        ser.write(ki.to_bytes(2, byteorder='little'))
        time.sleep(1)
    for ti in text:
        ser.write(ti.to_bytes(2, byteorder='little'))
        time.sleep(1)
    response = ser.read(4)
    if response:
        return [int.from_bytes(response[:2], 'little'), int.from_bytes(response[2:], 'little')]
    return None

def main():
    port = 'COM4'
    baud_rate = 1149430
    
    with serial.Serial(port, baud_rate, timeout=5) as ser:
        for i in range(10):
            text = [random.randint(0, 0xFFFF), random.randint(0, 0xFFFF)]
            k = [random.randint(0, 0xFFFF) for _ in range(4)]
            key_expansion(k)
            python_result = encrypt(text, k)
            fpga_result = send_to_fpga(ser, k[:4], text)
            
            print(f"Test {i+1}: Text={text[0]:04X} {text[1]:04X}, Key={k[0]:04X} {k[1]:04X} {k[2]:04X} {k[3]:04X}")
            print(f"Python: {python_result[0]:04X} {python_result[1]:04X}, FPGA: {fpga_result[0]:04X} {fpga_result[1]:04X}")
            if python_result == fpga_result:
                print("Test réussi !\n")
            else:
                print("Test échoué !\n")

if __name__ == "__main__":
    main()

