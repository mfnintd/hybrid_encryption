import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:pointycastle/pointycastle.dart';
import 'function.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final TextEditingController _plainTextController = TextEditingController();

  final TextEditingController _aesKeyController = TextEditingController();

  final TextEditingController _cirpherTextController = TextEditingController();

  final TextEditingController _encryptedAESKeyController =
      TextEditingController();

  final TextEditingController _rsaPublicKeyController = TextEditingController();

  final TextEditingController _rsaPrivateKeyController =
      TextEditingController();

  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> rsaPairOfKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Plain Text'),
                      TextFormField(
                        controller: _plainTextController,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'plain_text.txt',
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _plainTextController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: const Text('Save as .txt'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'plain_text.xml',
                                type: FileType.custom,
                                allowedExtensions: ['xml'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _plainTextController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: const Text('Save as Document'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text('AES Key'),
                      TextFormField(
                        controller: _aesKeyController,
                        decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween, // added line
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.repeat),
                                onPressed: () {
                                  _aesKeyController.text = generateAES128Key();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () async {
                                  String? result =
                                      await FilePicker.platform.saveFile(
                                    dialogTitle:
                                        'Please select an output file:',
                                    fileName: 'aeskey.txt',
                                    type: FileType.custom,
                                    allowedExtensions: ['txt'],
                                  );
                                  if (result != null) {
                                    saveStringAsTxt(
                                        _rsaPublicKeyController.text, result);
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _plainTextController.text =
                              _aesKeyController.text = '';
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text('RSA Public Key'),
                      TextFormField(
                        controller: _rsaPublicKeyController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'rsa_public_key.txt',
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _rsaPublicKeyController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _cirpherTextController.text = encryptByAES(
                          _plainTextController.text, _aesKeyController.text);
                      _encryptedAESKeyController.text = encryptByRSA(
                          _aesKeyController.text, rsaPairOfKey.publicKey);
                    },
                    child: const Text('Encrypt'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _aesKeyController.text = decryptByRSA(
                          _encryptedAESKeyController.text,
                          rsaPairOfKey.privateKey);
                      _plainTextController.text = decryptByAES(
                          _cirpherTextController.text, _aesKeyController.text);
                    },
                    child: const Text('Decrypt'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      rsaPairOfKey = generateRSAkeyPair();
                      _rsaPublicKeyController.text =
                          '{${rsaPairOfKey.publicKey.e}, ${rsaPairOfKey.publicKey.n}}';
                      _rsaPrivateKeyController.text =
                          '{${rsaPairOfKey.privateKey.d}, ${rsaPairOfKey.privateKey.p}, ${rsaPairOfKey.privateKey.q}}';
                    },
                    child: const Text('Generate RSA Key'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null) {
                        io.File file = io.File(result.files.single.path!);
                        //print(result.files.single.path);
                        if (extension(result.files.single.path!) == '.txt') {
                          final content = await file.readAsString();
                          _plainTextController.text = content;
                        } else {
                          final document =
                              XmlDocument.parse(file.readAsStringSync());
                          _plainTextController.text = document.toString();
                        }
                        //_plainTextController.text = '1232';
                        //print(_plainTextController.text);
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: const Text('Read file'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _plainTextController.text = _aesKeyController.text =
                          _rsaPublicKeyController.text =
                              _cirpherTextController.text =
                                  _encryptedAESKeyController.text =
                                      _rsaPrivateKeyController.text = "";
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Cirpher Text'),
                      TextFormField(
                        controller: _cirpherTextController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'cirpher_text.txt',
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _cirpherTextController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text('Encrypted AES Key'),
                      TextFormField(
                        controller: _encryptedAESKeyController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'encrypted_aes_key.txt',
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _encryptedAESKeyController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _cirpherTextController.text =
                              _encryptedAESKeyController.text = '';
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text('RSA Private Key'),
                      TextFormField(
                        controller: _rsaPrivateKeyController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              String? result =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'Please select an output file:',
                                fileName: 'rsa_private_key.txt',
                                type: FileType.custom,
                                allowedExtensions: ['txt'],
                              );
                              if (result != null) {
                                saveStringAsTxt(
                                    _rsaPrivateKeyController.text, result);
                              } else {
                                // User canceled the picker
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
