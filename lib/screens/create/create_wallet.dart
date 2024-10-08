import 'dart:async';

import 'package:danawallet/constants.dart';
import 'package:danawallet/generated/rust/api/structs.dart';
import 'package:danawallet/generated/rust/api/wallet.dart';
import 'package:danawallet/screens/home/home.dart';
import 'package:danawallet/repositories/settings_repository.dart';
import 'package:danawallet/states/chain_state.dart';
import 'package:danawallet/states/theme_notifier.dart';
import 'package:danawallet/states/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  CreateWalletScreenState createState() => CreateWalletScreenState();
}

class CreateWalletScreenState extends State<CreateWalletScreen> {
  Network _selectedNetwork = Network.signet;

  @override
  void initState() {
    super.initState();
  }

  void _updateNetwork(Network? newValue) {
    if (newValue == null) {
      throw Exception("Trying to update network with null value");
    }

    setState(() {
      _selectedNetwork = newValue;
    });
  }

  Future<void> _setupWallet(
      ApiSetupWalletType setupWalletType, int? birthday) async {
    final walletState = Provider.of<WalletState>(context, listen: false);
    final chainState = Provider.of<ChainState>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    // todo settings has to be initialized before chainstate, make this independent
    await SettingsRepository().defaultSettings(_selectedNetwork);

    await chainState.initialize();
    themeNotifier.setTheme(_selectedNetwork);

    // todo check this only happens when creating new wallet
    if (birthday == null) {
      try {
        birthday = chainState.tip;
      } catch (e) {
        Logger().w(
            'Unable to get block height, using default network birthday instead');
        birthday = _selectedNetwork.defaultBirthday;
      }
    }

    final args = ApiSetupWalletArgs(
        setupType: setupWalletType,
        birthday: birthday,
        network: _selectedNetwork.toBitcoinNetwork);

    try {
      final setupResult = setupWallet(setupArgs: args);

      final walletBlob = setupResult.walletBlob;
      final seedPhrase = setupResult.mnemonic;
      await walletState.saveWalletToSecureStorage(walletBlob);
      if (seedPhrase != null) {
        await walletState.saveSeedPhraseToSecureStorage(seedPhrase);
      }
      await walletState.updateWalletStatus();
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createNewWallet() async {
    const setupWalletType = ApiSetupWalletType.newWallet();

    await _setupWallet(setupWalletType, null);
  }

  Future<void> _importFromSeed(String mnemonic, int birthday) async {
    final setupWalletType = ApiSetupWalletType.mnemonic(mnemonic);

    await _setupWallet(setupWalletType, birthday);
  }

  Future<void> _importFromKeys(
      bool watchOnly, String scanKey, String spendKey, int birthday) async {
    ApiSetupWalletType setupWalletType;

    if (watchOnly) {
      setupWalletType = ApiSetupWalletType.watchOnly(scanKey, spendKey);
    } else {
      setupWalletType = ApiSetupWalletType.full(scanKey, spendKey);
    }

    await _setupWallet(setupWalletType, birthday);
  }

  Future<void> _showKeysInputDialog(
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
                  await _importFromKeys(watchOnly, scanKey, spendKey, birthday);
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

  Future<void> _showSeedInputDialog() async {
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
                  await _importFromSeed(mnemonic, birthday);
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
                DropdownButton<Network>(
                  hint: const Text('Select a network'),
                  value: _selectedNetwork,
                  onChanged: (Network? newValue) {
                    _updateNetwork(newValue);
                  },
                  items: [
                    Network.mainnet,
                    Network.testnet,
                    Network.signet,
                  ].map((Network network) {
                    return DropdownMenuItem<Network>(
                        value: network, child: Text(network.toString()));
                  }).toList(),
                ),
                const Spacer(),
                Expanded(
                  child: _buildButton(
                    context,
                    'Create New Wallet',
                    () async {
                      try {
                        await _createNewWallet();
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
                      _showSeedInputDialog();
                    },
                  ),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    'Restore from keys',
                    () {
                      _showKeysInputDialog(false);
                    },
                  ),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    'Watch-only',
                    () {
                      _showKeysInputDialog(true);
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
