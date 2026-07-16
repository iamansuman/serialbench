import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:serialbench/core/serial_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final SharedPreferences prefs;

  int? currThemeMode;
  int? initialThemeMode;
  static const List<int> baudOptions = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600];

  final serial = SerialService.instance;
  late int selectedBaud = serial.baudRate;

  List<UsbDevice> devices = [];
  UsbDevice? selectedDevice;
  String status = 'Not connected';
  StreamSubscription<String>? statusSub;
  StreamSubscription<void>? deviceListSub;

  @override
  void initState() {
    super.initState();
    initPrefs();
    refreshDevices();
    statusSub = serial.status.listen((s) {
      if (!mounted) return;
      setState(() => status = s);
    });
    deviceListSub = serial.deviceListChanged.listen((_) {
      refreshDevices();
    });
  }

  @override
  void dispose() {
    statusSub?.cancel();
    super.dispose();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      initialThemeMode = currThemeMode = prefs.getInt('theme_mode') ?? 0;
      selectedBaud = prefs.getInt('baudrate') ?? serial.baudRate;
    });
  }

  Future<void> refreshDevices() async {
    final lsdevs = await serial.listDevices();
    if (!mounted) return;
    setState(() {
      devices = lsdevs;
      if (devices.isNotEmpty) selectedDevice = devices.first;
    });
  }

  Future<void> connect() async {
    if (selectedDevice == null) return;
    await serial.connect(selectedDevice!, baud: selectedBaud);
    if (mounted) setState(() {});
  }

  Future<void> disconnect() async {
    await serial.disconnect();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final connected = serial.isConnected;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              (initialThemeMode != currThemeMode) ? ' (Relaunch app to view changes)' : '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        DropdownButton<int>(
          isExpanded: true,
          items: ThemeMode.values
              .map((thVal) => DropdownMenuItem<int>(value: thVal.index, child: Text('${thVal.name[0].toUpperCase()}${thVal.name.substring(1)}')))
              .toList(),
          value: currThemeMode,
          onChanged: (int? thVal) async {
            await prefs.setInt('theme_mode', thVal ?? 0);
            setState(() {
              currThemeMode = thVal;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Connection [', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(status, overflow: TextOverflow.ellipsis),
            const Text(']', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButton<UsbDevice>(
                isExpanded: true,
                itemHeight: max(kMinInteractiveDimension, 75),
                value: selectedDevice,
                hint: const Text('Select USB device'),
                items: devices
                    .map((d) => DropdownMenuItem(value: d, child: Text('${d.productName ?? "Unknown"} (VID:${d.vid} PID:${d.pid})')))
                    .toList(),
                onChanged: connected ? null : (d) => setState(() => selectedDevice = d),
              ),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: connected ? null : refreshDevices),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: DropdownButton<int>(
                value: selectedBaud,
                isExpanded: true,
                items: baudOptions.map((b) => DropdownMenuItem(alignment: Alignment.center, value: b, child: Text('$b'))).toList(),
                onChanged: connected
                    ? null
                    : (b) {
                        if (b == null) return;
                        setState(() {
                          selectedBaud = b;
                          prefs.setInt('baudrate', b);
                        });
                        serial.baudRate = b;
                      },
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: !connected ? (devices.isNotEmpty ? connect : null) : disconnect,
              child: !connected ? const Text('Connect') : const Text('Disconnect'),
            ),
          ],
        ),
      ],
    );
  }
}
