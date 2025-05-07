import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:erv/pages/action_page.dart';
import 'package:erv/pages/home.dart';
import 'package:erv/pages/pin_input_page.dart';
import 'package:erv/pages/settings_page.dart';
import 'package:erv/utils/application_settings.dart';
import 'package:erv/utils/http_overrides.dart';

import 'model/user_action.dart';

void setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.loggerName} '
        '-- ${record.time} -- ${record.message}');
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await dotenv.load();
  setupLogging();
  await Hive.initFlutter();
  Hive.registerAdapter(UserActionAdapter());
  await Hive.openBox<UserAction>('user_action');
  await initializeDateFormatting('sr_Latn');
  HttpOverrides.global = CertificateCheckHttpOverrides(await AppSettings.isCertificateCheckActive());

  try {
    ByteData data = await PlatformAssetBundle().load('assets/ca/certificate.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  } catch (e) {
    Logger('main').severe('Certificate loading failed! Error message: $e', e);
  }

  runApp(const MyApp());

  Future<void> closeHiveBoxes() async {
    await Hive.close();
  }

  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(onDetached: closeHiveBoxes),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/action_page': (context) => const ActionPage(),
        '/home_page': (context) => const HomePage(),
        '/pin_input_page': (context) => const PinInputPage(),
        '/settings_page': (context) => const SettingsPage(),
      },
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function() onDetached;

  LifecycleEventHandler({required this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onDetached();
    }
  }
}