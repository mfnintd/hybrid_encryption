import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

String encryptByAES(String plainText, String key) {
  final standardKey = encrypt.Key.fromUtf8(key);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(standardKey));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

String decryptByAES(String cirpherText, String key) {
  final standardKey = encrypt.Key.fromUtf8(key);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(standardKey));

  final decrypted =
      encrypter.decrypt(encrypt.Encrypted.fromBase64(cirpherText), iv: iv);
  return decrypted;
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    {int bitLength = 2048}) {
  // Create an RSA key generator and initialize it

  SecureRandom exampleSecureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        exampleSecureRandom()));

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

String encryptByRSA(String plainText, RSAPublicKey publicKey) {
  final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));

  final encrypted = encrypter.encrypt(plainText);

  return encrypted.base64;
}

String decryptByRSA(String cirpherText, RSAPrivateKey privKey) {
  final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privKey));

  final decrypted =
      encrypter.decrypt(encrypt.Encrypted.fromBase64(cirpherText));

  return decrypted;
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

void saveStringAsTxt(String content, String filePath) {
  File file = File(filePath);
  file.writeAsStringSync(content);
}

String generateAES128Key() {
  String chars =
      'qwertyuiop[]asdfghjkl;zxcvbnm,./QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?1234567890-=!@#%^&*()_+';
  Random rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  final key = getRandomString(16);
  return key;
}
