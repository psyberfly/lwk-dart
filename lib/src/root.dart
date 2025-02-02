import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:lwk_dart/src/utils/loader.dart';
import 'generated/bridge_definitions.dart';

Future<void> setCurrentDirectory() async {
  try {
    await Dylib.downloadUnitTestDylib(Directory.current.path);
  } catch (e) {
    print(e.toString());
  }
}

class LiquidWallet {
  final String _liquidWallet;

  LiquidWallet._(this._liquidWallet);

  String get liquidWallet => _liquidWallet;

  static Future<LiquidWallet> create(
      {required String mnemonic,
      required LiquidNetwork network,
      required String dbPath,
      dynamic hint}) async {
    try {
      final res = await ffi.newWalletStaticMethodApi(
          mnemonic: mnemonic, network: network, dbPath: dbPath);
      return LiquidWallet._(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sync(
    String electrumUrl,
  ) async {
    try {
      final res = await ffi.syncStaticMethodApi(
        walletId: _liquidWallet,
        electrumUrl: electrumUrl,
      );
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletAddress> address() async {
    try {
      final res = await ffi.addressLastUnusedStaticMethodApi(
        walletId: _liquidWallet,
      );
      return res;
    } catch (e) {
      rethrow;
    }
  }

//   String descriptor() {
//     try {
// final res = await ffi.descriptor(
//         walletId: _liquidWallet,
//       );
//       return res;    } catch (e) {
//       rethrow;
//     }
//   }

  Future<Balance> balance() async {
    try {
      final res = await ffi.balanceStaticMethodApi(walletId: _liquidWallet);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Tx>> txs() async {
    try {
      final res = await ffi.txsStaticMethodApi(walletId: _liquidWallet);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> build(
      {required int sats,
      required String outAddress,
      required double absFee}) async {
    try {
      final res = await ffi.buildTxStaticMethodApi(
          walletId: _liquidWallet,
          sats: sats,
          outAddress: outAddress,
          absFee: absFee);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<PsetAmounts> decode({required String pset}) async {
    try {
      final res =
          await ffi.decodeTxStaticMethodApi(walletId: _liquidWallet, pset: pset);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> sign(
      {required LiquidNetwork network,
      required String pset,
      required String mnemonic}) async {
    try {
      final res = await ffi.signTxStaticMethodApi(
          walletId: _liquidWallet,
          network: network,
          pset: pset,
          mnemonic: mnemonic);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> broadcast(
      {required String electrumUrl, required Uint8List txBytes}) async {
    try {
      final res = await ffi.broadcastTxStaticMethodApi(
          electrumUrl: electrumUrl, txBytes: txBytes);
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
