import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serialbench/core/serial_service.dart';
import 'package:serialbench/screens/serial_monitor.dart';
import 'package:serialbench/screens/serial_plotter.dart';
import 'package:serialbench/screens/settings.dart';
import 'package:serialbench/screens/usage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(SerialBenchApp(themeMode: prefs.getInt('theme_mode') ?? 2));
}

class SerialBenchApp extends StatelessWidget {
  final int themeMode;
  const SerialBenchApp({super.key, this.themeMode = 2});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SerialBench',
      theme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.dark, useMaterial3: true),
      themeMode: ThemeMode.values[themeMode], //Dark[0], Light[1], System[2]
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

enum ScreenSelection { monitor, plotter, settings, usage }

class HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  ScreenSelection currScreen = ScreenSelection.settings;
  bool connected = false;
  StreamSubscription<String>? statusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connected = SerialService.instance.isConnected;
    statusSub = SerialService.instance.status.listen((_) {
      if (!mounted) return;
      setState(() => connected = SerialService.instance.isConnected);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    statusSub?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      SerialService.instance.disconnect();
    }
  }

  String get appBarTitle {
    switch (currScreen) {
      case ScreenSelection.monitor:
        return 'Serial Monitor';
      case ScreenSelection.plotter:
        return 'Serial Plotter';
      case ScreenSelection.settings:
        return 'Settings';
      case ScreenSelection.usage:
        return 'Usage Guide';
    }
  }

  Widget screenBody() {
    switch (currScreen) {
      case ScreenSelection.monitor:
        return const SerialMonitor();
      case ScreenSelection.plotter:
        return const SerialPlotter();
      case ScreenSelection.settings:
        return const Settings();
      case ScreenSelection.usage:
        return const Usage();
    }
  }

  void selectScreen(ScreenSelection selection, {bool closeDrawer = true}) {
    setState(() => currScreen = selection);
    if (closeDrawer) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: connected ? Colors.greenAccent : Colors.redAccent),
            onPressed: () => selectScreen(ScreenSelection.settings, closeDrawer: false),
            icon: Icon(connected ? Icons.usb_rounded : Icons.usb_off_rounded, color: Color(0xFF212121)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
                image: DecorationImage(image: AssetImage('assets/plug-serial-256-svgrepo-com.png'), alignment: Alignment.centerLeft),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'SerialBench',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'monospace'),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.terminal_rounded),
              title: const Text('Serial Monitor'),
              selected: currScreen == ScreenSelection.monitor,
              onTap: () => selectScreen(ScreenSelection.monitor),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_rounded),
              title: const Text('Serial Plotter'),
              selected: currScreen == ScreenSelection.plotter,
              onTap: () => selectScreen(ScreenSelection.plotter),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              selected: currScreen == ScreenSelection.settings,
              onTap: () => selectScreen(ScreenSelection.settings),
            ),
            ListTile(
              leading: const Icon(Icons.help_rounded),
              title: const Text('Usage'),
              selected: currScreen == ScreenSelection.usage,
              onTap: () => selectScreen(ScreenSelection.usage),
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Repository'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () async {
                Navigator.pop(context);
                await launchUrl(
                  Uri(scheme: 'https', host: 'github.com', path: 'iamansuman/serialbench'),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ],
        ),
      ),
      body: screenBody(),
    );
  }
}
