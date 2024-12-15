import serial
import time

# Configuration du port série
port = 'COM4'       # Windows
# Pour Linux
# port = '/dev/ttyUSB1'       # Remplacez par le bon port
baud_rate = 4800          # Baud rate à utiliser (doit correspondre à celui du FPGA)

try:
    # Ouvrir le port série
    with serial.Serial(port, baud_rate, timeout=5) as ser:
        print(f"Port série ouvert : {ser.is_open}")
        
        # Envoi de données vers le FPGA

        # Commande pour choisir entre SIMON, SHA et RSA
        commande = bytes([0x01])  # Envoi de 0x00 en tant qu'octet
        ser.write(commande)  # Envoi du message en binaire (hex)
        print(f"Message envoyé : {commande.hex()}")
        time.sleep(2)  # Délai de 500 ms

        # Clé à envoyer
        k1 = 0x1234
        k2 = 0x5678
        k3 = 0x9ABC
        k4 = 0xDEF0
        
        # Conversion des clés en bytes et envoi avec délais
        ser.write(k1.to_bytes(2, byteorder='big'))  # Envoi de k1, 2 octets
        print(f"Clé envoyée : {hex(k1)}")
        time.sleep(2)  # Délai de 500 ms
        
        ser.write(k2.to_bytes(2, byteorder='big'))  # Envoi de k2, 2 octets
        print(f"Clé envoyée : {hex(k2)}")
        time.sleep(2)  # Délai de 500 ms
        
        ser.write(k3.to_bytes(2, byteorder='big'))  # Envoi de k3, 2 octets
        print(f"Clé envoyée : {hex(k3)}")
        time.sleep(2)  # Délai de 500 ms
        
        ser.write(k4.to_bytes(2, byteorder='big'))  # Envoi de k4, 2 octets
        print(f"Clé envoyée : {hex(k4)}")
        time.sleep(2)  # Délai de 500 ms

        # Données à crypter
        text0 = 0xFFFF
        text1 = 0x0000
        
        # Envoi des données à crypter avec délais
        ser.write(text0.to_bytes(2, byteorder='big'))  # Envoi de text0, 2 octets
        print(f"text0 envoyé : {hex(text0)}")
        time.sleep(2)  # Délai de 500 ms
        
        ser.write(text1.to_bytes(2, byteorder='big'))  # Envoi de text1, 2 octets
        print(f"text1 envoyé : {hex(text1)}")

    
        print("En attente de la réponse du FPGA...")
        response = ser.read(4)  # Lire jusqu'à 4 octets pour s'assurer
        if response:
            print("Données brutes reçues :", response)
            print("Réponse hexadécimale :", response.hex())
        else:
            print("Aucune donnée reçue. Vérifiez le FPGA.")

except serial.SerialException as e:
    print(f"Erreur avec le port série : {e}")
except Exception as ex:
    print(f"Une erreur est survenue : {ex}")
