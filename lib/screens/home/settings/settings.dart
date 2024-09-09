import 'package:bitcoin_ui/bitcoin_ui.dart';
import 'package:danawallet/global_functions.dart';
import 'package:danawallet/generated/rust/api/wallet.dart';
import 'package:danawallet/screens/create/create_wallet.dart';
import 'package:danawallet/services/settings_service.dart';
import 'package:danawallet/states/chain_state.dart';
import 'package:danawallet/states/home_state.dart';
import 'package:danawallet/states/spend_state.dart';
import 'package:danawallet/states/theme_notifier.dart';
import 'package:danawallet/states/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _removeWallet(
    WalletState walletState,
    ChainState chainState,
    SpendState spendSelectionState,
    ThemeNotifier themeNotifier,
  ) async {
    try {
      await walletState.rmWalletFromSecureStorage();
      await walletState.reset();

      await SettingsService().resetAll();
      spendSelectionState.reset();
      chainState.reset();
      themeNotifier.setTheme(null);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _getSeedPhrase(WalletState walletState) async {
    try {
      final wallet = await walletState.getWalletFromSecureStorage();
      return showMnemonic(encodedWallet: wallet);
    } catch (e) {
      displayNotification(e.toString());
      return null;
    }
  }

  Future<void> _setBirthday(
      BuildContext context, HomeState homeProvider) async {
    TextEditingController controller = TextEditingController();
    showInputAlertDialog(controller, TextInputType.number, 'Enter Birthday',
            'Enter wallet\'s birthday (numeric value)')
        .then((value) async {
      if (value != null && int.tryParse(value) != null) {
        final walletState = Provider.of<WalletState>(context, listen: false);
        try {
          final wallet = await walletState.getWalletFromSecureStorage();
          final updatedWallet =
              changeBirthday(encodedWallet: wallet, birthday: int.parse(value));
          await walletState.saveWalletToSecureStorage(updatedWallet);
          await walletState.updateWalletStatus();
          homeProvider.showMainScreen();
        } catch (e) {
          rethrow;
        }
      }
    });
  }

  Future<void> _setBlindbitUrl(BuildContext context) async {
    SettingsService settings = SettingsService();
    final controller = TextEditingController();
    controller.text = await settings.getBlindbitUrl() ?? '';

    showInputAlertDialog(controller, TextInputType.url, 'Set blindbit url',
            'Only blindbit is currently supported')
        .then((value) async {
      if (value != null) {
        await settings.setBlindbitUrl(value);
      }
    });
  }

  Future<void> _changeDustLimit(BuildContext context) async {
    SettingsService settings = SettingsService();
    final controller = TextEditingController();
    final dustLimit = await settings.getDustLimit();
    if (dustLimit != null) {
      controller.text = dustLimit.toString();
    } else {
      controller.text = '';
    }

    showInputAlertDialog(controller, TextInputType.number, 'Set dust limit',
            'Payments below this value are ignored')
        .then((value) async {
      if (value != null && int.tryParse(value) != null) {
        await settings.setDustLimit(int.parse(value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = Provider.of<WalletState>(context, listen: false);
    final chainState = Provider.of<ChainState>(context, listen: false);
    final spendState = Provider.of<SpendState>(context, listen: false);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final homeProvider = Provider.of<HomeState>(context, listen: false);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BitcoinButtonOutlined(
            title: 'Show seed phrase',
            onPressed: () async {
              const title = 'Backup seed phrase';
              final text = await _getSeedPhrase(walletState) ??
                  'Seed phrase unknown! Did you import from keys?';

              showAlertDialog(title, text);
            },
          ),
          BitcoinButtonOutlined(
              title: 'Set wallet birthday',
              onPressed: () => _setBirthday(context, homeProvider)),
          BitcoinButtonOutlined(
            title: 'Set backend url',
            onPressed: () {
              _setBlindbitUrl(context);
            },
          ),
          BitcoinButtonOutlined(
            title: 'Set dust threshold',
            onPressed: () {
              _changeDustLimit(context);
            },
          ),
          BitcoinButtonOutlined(
              title: 'Wipe wallet',
              onPressed: () async {
                await _removeWallet(
                    walletState, chainState, spendState, themeNotifier);
                homeProvider.showMainScreen();
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateWalletScreen()));
                }
              }),
        ],
      ),
    );
  }
}
