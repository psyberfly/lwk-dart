import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:path_provider/path_provider.dart';

class DecodedPset {
  final int amount;
  final int fee;

  DecodedPset({required this.amount, required this.fee});
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});
  static const mnemonic =
      "bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon";
  static const network = LiquidNetwork.Testnet;

  static const electrumUrl = 'blockstream.info:465';
  static const outAmount = 10000;
  static const outAddress =
      "tlq1qqt4hjkl6sug5ld89sdaekt7ew04va8w7c63adw07l33vcx86vpj5th3w7rkdnckmfpraufnnrfcep4thqt6024phuav99djeu";
  static const fee = 300.0;

  static Future<String> getDbDir() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/lwk-db";
      return path;
    } catch (e) {
      print('Error getting current directory: $e');
      rethrow;
    }
  }

  static Future<LiquidWallet> createWallet() async {
    final dbPath = await getDbDir();

    final wallet = await LiquidWallet.create(
      mnemonic: mnemonic,
      network: network,
      dbPath: dbPath,
    );

    return wallet;
  }

  static Future<String> getAddress(LiquidWallet wallet) async {
    final address = await wallet.address();
    return address;
  }

  static Future<bool> sync(LiquidWallet wallet) async {
    await wallet.sync(electrumUrl);
    return true;
  }

  static Future<Balance> balance(LiquidWallet wallet) async {
    final Balance balance = await wallet.balance();
    return balance;
  }

  static Future<List<Map<String, int>>> txs(LiquidWallet wallet) async {
    final txs = await wallet.txs();
    List<Map<String, int>> res = [];
    for (int i = 0; i < txs.length; i++) {
      res.add({txs[i].txid: txs[i].amount});
    }
    return res;
  }

  static Future<String> build(LiquidWallet wallet) async {
    final pset = await wallet.build(
        sats: outAmount, outAddress: outAddress, absFee: fee);
    return pset;
  }

  static Future<DecodedPset> decode(LiquidWallet wallet, String pset) async {
    final decodedPset = await wallet.decode(pset: pset);
    return DecodedPset(amount: decodedPset.balances.lbtc, fee: decodedPset.fee);
  }

  static Future<Uint8List> sign(LiquidWallet wallet, String pset) async {
    final signedTxBytes =
        await wallet.sign(network: network, pset: pset, mnemonic: mnemonic);

    return signedTxBytes;
  }

  static Future<String> broadcast(
      LiquidWallet wallet, Uint8List signedTxBytes) async {
    final tx = await wallet.broadcast(
        electrumUrl: electrumUrl, txBytes: signedTxBytes);
    return tx;
  }

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  bool loading = false;
  LiquidWallet? wallet;
  bool isWalletSynced = false;
  Balance? balance;
  List<Map<String, int>>? txs;
  String newAddress = "...";
  String? pset;
  DecodedPset? decodedPset;
  Uint8List? signedTxBytes;
  String? tx;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scrollbarTheme: const ScrollbarThemeData(
          minThumbLength: 10,
          thumbVisibility: MaterialStatePropertyAll<bool>(true),
          thumbColor: MaterialStatePropertyAll<Color>(Colors.grey),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18.0),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStatePropertyAll<Color>(Colors.red.shade400),
            foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade400,
          title: const Text("LWK Flutter Lib Test:"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: loading,
                      child: const LinearProgressIndicator(),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.createWallet();
                                setState(() {
                                  wallet = res;
                                  loading = false;
                                });
                              },
                              child: const Text(
                                'Create Wallet',
                              ),
                            ),
                            Text(wallet == null ? "..." : "wallet created"),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.sync(wallet!);
                                setState(() {
                                  loading = false;
                                  isWalletSynced = res;
                                });
                              },
                              child: const Text(
                                'Sync Wallet',
                              ),
                            ),
                            Text(isWalletSynced ? "Wallet Synced" : "..."),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.balance(wallet!);
                                setState(() {
                                  loading = false;
                                  balance = res;
                                });
                              },
                              child: const Text(
                                'Get Balance',
                              ),
                            ),
                            Text(balance == null
                                ? "..."
                                : "${balance!.lbtc} sats"),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.txs(wallet!);
                                setState(() {
                                  loading = false;
                                  txs = res;
                                });
                              },
                              child: const Text(
                                'Get Txs',
                              ),
                            ),
                            txs == null
                                ? const Text("...")
                                : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    height: 300,
                                    child: ListView.builder(
                                      itemCount: txs!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(
                                              'Transaction ID: ${txs![index].keys}'),
                                          subtitle: Text(
                                              'Amount: ${txs![index].values}'),
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.getAddress(wallet!);
                                setState(() {
                                  loading = false;
                                  newAddress = res;
                                });
                              },
                              child: const Text(
                                'Get Address',
                              ),
                            ),
                            Text(newAddress),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.build(wallet!);
                                setState(() {
                                  loading = false;
                                  pset = res;
                                });
                              },
                              child: const Text(
                                'Build',
                              ),
                            ),
                            pset == null
                                ? const Text("...")
                                : Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                        child: Text(pset!)),
                                  ),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res =
                                    await TestApp.decode(wallet!, pset!);
                                setState(() {
                                  loading = false;
                                  decodedPset = res;
                                });
                              },
                              child: const Text(
                                'Decode Pset',
                              ),
                            ),
                            decodedPset == null
                                ? const Text("...")
                                : Text(
                                    'Amount: ${decodedPset!.amount}, Fee: ${decodedPset!.fee}'),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.sign(wallet!, pset!);
                                setState(() {
                                  loading = false;
                                  signedTxBytes = res;
                                });
                              },
                              child: const Text(
                                'Sign Pset',
                              ),
                            ),
                            Text(signedTxBytes == null ? "..." : "Tx Signed"),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final res = await TestApp.broadcast(
                                    wallet!, signedTxBytes!);
                                setState(() {
                                  loading = false;
                                  tx = res;
                                });
                              },
                              child: const Text(
                                'Broadcast Tx',
                              ),
                            ),
                            Text(tx == null ? "..." : tx!),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
