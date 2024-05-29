// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.36.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../constants.dart';
import '../frb_generated.dart';
import '../logger.dart';
import '../stream.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Stream<LogEntry> createLogStream(
        {required LogLevel level,
        required bool logDependencies,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleCreateLogStream(
        level: level, logDependencies: logDependencies, hint: hint);

Stream<SyncStatus> createSyncStream({dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleCreateSyncStream(hint: hint);

Stream<ScanProgress> createScanProgressStream({dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleCreateScanProgressStream(hint: hint);

Stream<BigInt> createAmountStream({dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleCreateAmountStream(hint: hint);

Future<bool> walletExists(
        {required String label, required String filesDir, dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleWalletExists(
        label: label, filesDir: filesDir, hint: hint);

Future<String> setup(
        {required String label,
        required String filesDir,
        required WalletType walletType,
        required int birthday,
        required bool isTestnet,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleSetup(
        label: label,
        filesDir: filesDir,
        walletType: walletType,
        birthday: birthday,
        isTestnet: isTestnet,
        hint: hint);

/// Change wallet birthday
/// Since this method doesn't touch the known outputs
/// the caller is responsible for resetting the wallet to its new birthday
Future<void> changeBirthday(
        {required String path,
        required String label,
        required int birthday,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleChangeBirthday(
        path: path, label: label, birthday: birthday, hint: hint);

/// Reset the last_scan of the wallet to its birthday, removing all outpoints
Future<void> resetWallet(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleResetWallet(path: path, label: label, hint: hint);

Future<void> removeWallet(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleRemoveWallet(path: path, label: label, hint: hint);

Future<void> syncBlockchain({dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleSyncBlockchain(hint: hint);

Future<void> scanToTip(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleScanToTip(path: path, label: label, hint: hint);

Future<WalletStatus> getWalletInfo(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleGetWalletInfo(path: path, label: label, hint: hint);

Future<String> getReceivingAddress(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleGetReceivingAddress(
        path: path, label: label, hint: hint);

Future<List<OwnedOutput>> getSpendableOutputs(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleGetSpendableOutputs(
        path: path, label: label, hint: hint);

Future<List<OwnedOutput>> getOutputs(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleGetOutputs(path: path, label: label, hint: hint);

Future<String> createNewPsbt(
        {required String label,
        required String path,
        required List<OwnedOutput> inputs,
        required List<Recipient> recipients,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleCreateNewPsbt(
        label: label,
        path: path,
        inputs: inputs,
        recipients: recipients,
        hint: hint);

Future<String> addFeeForFeeRate(
        {required String psbt,
        required int feeRate,
        required String payer,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleAddFeeForFeeRate(
        psbt: psbt, feeRate: feeRate, payer: payer, hint: hint);

Future<String> fillSpOutputs(
        {required String path,
        required String label,
        required String psbt,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleFillSpOutputs(
        path: path, label: label, psbt: psbt, hint: hint);

Future<String> signPsbt(
        {required String path,
        required String label,
        required String psbt,
        required bool finalize,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleSignPsbt(
        path: path, label: label, psbt: psbt, finalize: finalize, hint: hint);

Future<String> extractTxFromPsbt({required String psbt, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleExtractTxFromPsbt(psbt: psbt, hint: hint);

Future<String> broadcastTx({required String tx, dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleBroadcastTx(tx: tx, hint: hint);

Future<void> markTransactionInputsAsSpent(
        {required String path,
        required String label,
        required String tx,
        dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleMarkTransactionInputsAsSpent(
        path: path, label: label, tx: tx, hint: hint);

Future<String?> showMnemonic(
        {required String path, required String label, dynamic hint}) =>
    RustLib.instance.api
        .crateApiSimpleShowMnemonic(path: path, label: label, hint: hint);

String greet({required String name, dynamic hint}) =>
    RustLib.instance.api.crateApiSimpleGreet(name: name, hint: hint);

class WalletStatus {
  final BigInt amount;
  final int birthday;
  final int scanHeight;

  const WalletStatus({
    required this.amount,
    required this.birthday,
    required this.scanHeight,
  });

  @override
  int get hashCode => amount.hashCode ^ birthday.hashCode ^ scanHeight.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletStatus &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          birthday == other.birthday &&
          scanHeight == other.scanHeight;
}
