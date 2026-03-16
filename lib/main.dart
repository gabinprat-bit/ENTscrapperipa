import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'services/app_state.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/screens/root_screen.dart';

const String _bgTask = 'ent_refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == _bgTask) {
      try {
        final storage = StorageService();
        final token   = await storage.getToken();
        final url     = await storage.getServerUrl();
        if (token != null && url != null) {
          final data = await ApiService(serverUrl: url).fetchData(token);
          if (data['ok'] == true) {
            final notifService = NotificationService();
            await notifService.init();
            final notifNotes   = await storage.getNotifNotes();
            final notifDevoirs = await storage.getNotifDevoirs();
            for (final n in (data['notifications'] as List? ?? [])) {
              final type  = n['type']  as String;
              final title = n['title'] as String;
              final body  = n['body']  as String;
              if (type == 'note'   && notifNotes)   await notifService.show(title, body);
              if (type == 'devoir' && notifDevoirs) await notifService.show(title, body);
            }
          }
        }
      } catch (_) {}
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await NotificationService().init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    _bgTask, _bgTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  runApp(const ENTApp());
}

class ENTApp extends StatelessWidget {
  const ENTApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mon ENT',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED), brightness: Brightness.dark),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
    ),
    home: const RootScreen(),
  );
}
