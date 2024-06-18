// ignore: file_names
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  final key = encrypt.Key.fromUtf8(
      "laskfyrowpertnvxtuqorwcnzmxycvxb"); // Ensure key length is 32 bytes (256 bits)
  // final iv = encrypt.IV.fromLength(16); // 16 bytes IV

  late final encrypter = encrypt.Encrypter(encrypt.AES(key));

  String encryptData(String data) {
    final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
    final encrypted = encrypter.encrypt(data, iv: iv);
    return "${iv.base64}:${encrypted.base64}"; // Return IV and encrypted data together
  }

  String decryptData(String encryptedData) {
    try {
      print("Encrypted data : $encryptedData");
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw ArgumentError("Invalid encrypted data format");
      }
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = parts[1];
      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      // Catch and handle the decryption error
      print("Error during decryption: $e");
      rethrow;
    }
  }
}
