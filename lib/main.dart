import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum ScreenSelection { monitor, plotter, controller, audio, settings, usage }

class HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SerialBench')),
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
            ListTile(leading: const Icon(Icons.terminal_rounded), title: const Text('Serial Monitor')),
            ListTile(leading: const Icon(Icons.insert_chart_rounded), title: const Text('Serial Plotter')),
            // ListTile(leading: const Icon(Icons.gamepad_rounded), title: const Text('Serial Controller')),
            // ListTile(leading: const Icon(Icons.graphic_eq_rounded), title: const Text('Serial Audio')),
            const Divider(),
            ListTile(leading: const Icon(Icons.settings_rounded), title: const Text('Settings')),
            ListTile(leading: const Icon(Icons.help_rounded), title: const Text('Usage')),
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
    );
  }
}
