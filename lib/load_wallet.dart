import 'dart:async';

import 'package:donationwallet/rust/api/wallet.dart';
import 'package:donationwallet/states/chain_state.dart';
import 'package:donationwallet/states/theme_notifier.dart';
import 'package:donationwallet/states/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class LoadWalletScreen extends StatefulWidget {
  const LoadWalletScreen({super.key});

  @override
  LoadWalletScreenState createState() => LoadWalletScreenState();
}

class LoadWalletScreenState extends State<LoadWalletScreen> {
  String _network = "signet";

  @override
  void initState() {
    super.initState();
  }

  void _updateNetwork(String? newValue) {
    if (newValue == null) {
      throw Exception("Trying to update network with null value");
    }

    setState(() {
      _network = newValue;
    });
  }

  Future<void> _setup(
      WalletState walletState,
      ChainState chainState,
      ThemeNotifier themeNotifier,
      String? mnemonic,
      String? scanKey,
      String? spendKey,
      int? birthday) async {
    await chainState.initialize(_network);
    themeNotifier.setTheme(_network);

    try {
      await walletState.updateWalletStatus();
      walletState.walletLoaded = true;
      return;
    } catch (e) {
      Logger().i("Creating a new wallet");
    }

    if (birthday == null) {
      try {
        birthday = chainState.tip;
      } catch (e) {
        rethrow;
      }
    }

    try {
      final wallet = await setup(
        label: walletState.label,
        mnemonic: mnemonic,
        scanKey: scanKey,
        spendKey: spendKey,
        birthday: birthday,
        network: _network,
      );
      await walletState.saveWalletToSecureStorage(wallet);
      await walletState.updateWalletStatus();
      walletState.walletLoaded = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _showKeysInputDialog(
    WalletState walletState,
    ChainState chainState,
    ThemeNotifier themeNotifier,
    bool watchOnly,
  ) async {
    TextEditingController scanKeyController = TextEditingController();
    TextEditingController spendKeyController = TextEditingController();
    TextEditingController birthdayController = TextEditingController();
    String hint;

    if (watchOnly) {
      hint = "Spend public key";
    } else {
      hint = "Spend private key";
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Enter keys"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Use min size for the column
            children: [
              TextField(
                controller: scanKeyController,
                decoration: InputDecoration(
                  hintText: "Scan private key",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null) {
                        scanKeyController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10), // Spacing between text fields
              TextField(
                controller: spendKeyController,
                decoration: InputDecoration(
                  hintText: hint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null) {
                        spendKeyController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10), // Spacing between text fields
              TextField(
                controller: birthdayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Wallet birthday (in blocks)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null) {
                        birthdayController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Submit"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Process the input from the two text fields
                final scanKey = scanKeyController.text;
                final spendKey = spendKeyController.text;
                final birthday = int.parse(birthdayController.text);

                if (scanKey.isEmpty || spendKey.isEmpty) {
                  throw Error();
                }

                try {
                  await _setup(walletState, chainState, themeNotifier, null,
                      scanKey, spendKey, birthday);
                } catch (e) {
                  rethrow;
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSeedInputDialog(
    WalletState walletState,
    ChainState chainState,
    ThemeNotifier themeNotifier,
  ) async {
    TextEditingController seedController = TextEditingController();
    TextEditingController birthdayController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Enter Seed"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Use min size for the column
            children: [
              TextField(
                controller: seedController,
                decoration: InputDecoration(
                  hintText: "Seed",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null) {
                        seedController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10), // Spacing between text fields
              TextField(
                controller: birthdayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Wallet birthday (in blocks)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null) {
                        birthdayController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Submit"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Process the input from the two text fields
                final mnemonic = seedController.text;
                final birthday = int.parse(birthdayController.text);
                try {
                  await _setup(walletState, chainState, themeNotifier, mnemonic,
                      null, null, birthday);
                } catch (e) {
                  rethrow;
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = Provider.of<WalletState>(context, listen: false);
    final chainState = Provider.of<ChainState>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Wallet creation/restoration'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'Select a Network',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  hint: const Text('Select a network'),
                  value: _network,
                  onChanged: (String? newValue) {
                    _updateNetwork(newValue);
                  },
                  items: [
                    {'display': 'Bitcoin Mainnet', 'value': 'main'},
                    {'display': 'Signet', 'value': 'signet'},
                    {'display': 'Test', 'value': 'test'}
                  ].map<DropdownMenuItem<String>>((Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['display']!),
                    );
                  }).toList(),
                ),
                const Spacer(),
                Expanded(
                  child: _buildButton(
                    context,
                    'Create New Wallet',
                    () async {
                      try {
                        await _setup(walletState, chainState, themeNotifier,
                            null, null, null, null);
                      } catch (e) {
                        rethrow;
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    'Restore from seed',
                    () {
                      _showSeedInputDialog(
                        walletState,
                        chainState,
                        themeNotifier,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    'Restore from keys',
                    () {
                      _showKeysInputDialog(
                          walletState, chainState, themeNotifier, false);
                    },
                  ),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    'Watch-only',
                    () {
                      _showKeysInputDialog(
                          walletState, chainState, themeNotifier, true);
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ));
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: Theme.of(context).textTheme.headlineLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(double.infinity, 60),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
