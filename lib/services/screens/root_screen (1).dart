import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/space_background.dart';
import 'login_screen.dart';
import 'notif_setup_screen.dart';
import 'main_app_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late AppState _state;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _state = AppState();
    _state.init().then((_) => setState(() => _initialized = true));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Consumer<AppState>(
        builder: (ctx, state, _) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Fond spatial permanent
                const SpaceBackground(),

                // Écran actif
                if (!_initialized)
                  const _LoadingScreen()
                else if (!state.isLoggedIn)
                  const LoginScreen()
                else if (!state.prefsSet)
                  const NotifSetupScreen()
                else
                  const MainAppScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Color(0xFF2F80ED), strokeWidth: 2),
        SizedBox(height: 18),
        Text('Chargement du cosmos…',
            style: TextStyle(color: Colors.white30, fontSize: 13)),
      ],
    ),
  );
}
