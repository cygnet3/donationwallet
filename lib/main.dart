// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:donationwallet/ffi.dart';
import 'package:donationwallet/home.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class WalletState extends ChangeNotifier {
  final String label = "default";
  Directory dir = Directory("/");
  int amount = 0;
  int birthday = 0;
  int lastScan = 0;
  int tip = 0;
  double progress = 0.0;
  int peercount = 0;
  String network = 'signet';
  bool walletLoaded = false;
  String address = "";
  List<OwnedOutput> ownedOutputs = List.empty();
  List<OwnedOutput> selectedOutputs = List.empty();

  late StreamSubscription logStreamSubscription;
  late StreamSubscription scanProgressSubscription;
  late StreamSubscription amountStreamSubscription;

  WalletState();

  Future<void> initialize() async {
    try {
      await _initDir();
      await _setupNakamoto();
      await _initStreams();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initDir() async {
    try {
      dir = await getApplicationSupportDirectory();
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _setupNakamoto() async {
    while (dir == Directory("/")) {
      sleep(const Duration(milliseconds: 100));
    }
    try {
      await api.setupNakamoto(network: network, path: dir.path);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initStreams() async {
    api.createLogStream().listen((event) {
      print('RUST: ${event.msg}');
    });

    api.createScanProgressStream().listen(((event) {
      int start = event.start;
      int current = event.current;
      int end = event.end;
      double scanned = (current - start).toDouble();
      double total = (end - start).toDouble();
      double progress = scanned / total;
      if (current == end) {
        progress = 0.0;
      }
      this.progress = progress;
      tip = current;
      notifyListeners();
    }));

    api.createAmountStream().listen((event) {
      amount = event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    logStreamSubscription.cancel();
    scanProgressSubscription.cancel();
    amountStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> reset() async {
    amount = 0;
    birthday = 0;
    lastScan = 0;
    tip = 0;
    progress = 0.0;
    peercount = 0;
    network = 'signet';
    walletLoaded = false;
    address = "";
    ownedOutputs = List.empty();
    // dir stays as it is

    notifyListeners();
  }

  Future<void> getAddress() async {
    try {
      address = await api.getReceivingAddress(path: dir.path, label: label);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWalletStatus() async {
    try {
      final wallet = await api.getWalletInfo(path: dir.path, label: label);
      amount = wallet.amount;
      birthday = wallet.birthday;
      lastScan = wallet.scanHeight;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOwnedOutputs() async {
    try {
      ownedOutputs = await api.getOutputs(path: dir.path, label: label);
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  List<OwnedOutput> getSpendableOutputs() {
    return ownedOutputs.where((output) => !output.spent).toList();
  }

  void toggleOutputSelection(OwnedOutput output) {
    if (selectedOutputs.contains(output)) {
      selectedOutputs.remove(output);
    } else {
      selectedOutputs.add(output);
    }
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final walletState = WalletState();
  await walletState.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: walletState,
      child: const SilentPaymentApp(),
    ),
  );
}

class SilentPaymentApp extends StatelessWidget {
  const SilentPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent payments',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
