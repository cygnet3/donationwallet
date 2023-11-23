import 'package:donationwallet/ffi.dart';
import 'package:donationwallet/home.dart';
import 'package:donationwallet/storage.dart';
import 'package:flutter/material.dart';

class WalletFromSeedPage extends StatefulWidget {
  const WalletFromSeedPage({super.key});

  @override
  State<WalletFromSeedPage> createState() => _WalletFromSeedPage();
}

class _WalletFromSeedPage extends State<WalletFromSeedPage> {
  final seedphraseController = TextEditingController();
  final passphraseController = TextEditingController();
  final birthdayController = TextEditingController();
  final signet = true;

  @override
  void dispose() {
    seedphraseController.dispose();
    passphraseController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 40.0,
          child: ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final keys = await api.getKeysFromSeed(
                  seedphrase: seedphraseController.text);
              await SecureStorageService().initializeWithCustomSettings(
                  keys.$2, keys.$1, birthdayController.text);
              navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
            child: const Text('Continue'),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 8.0,
                ),
                const Text('mainnet'),
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      // todo
                    });
                  },
                  value: signet,
                ),
                const Text('signet'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: seedphraseController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'seed phrase',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: passphraseController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'passphrase',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: birthdayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'birthday block',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
