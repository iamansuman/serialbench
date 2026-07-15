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
  static const List<int> baudOptions = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600];
  late final SharedPreferences prefs;

  final serial = SerialService.instance;
  late int selectedBaud = serial.baudRate;

  List<UsbDevice> devices = [];
  UsbDevice? selectedDevice;
  String status = 'Not connected';
  StreamSubscription<String>? statusSub;

  @override
  void initState() {
    super.initState();
    initPrefs();
    refreshDevices();
    statusSub = serial.status.listen((s) {
      if (!mounted) return;
      setState(() => status = s);
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
            const Text('Connection [', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(status, overflow: TextOverflow.ellipsis),
            const Text(']', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: !connected ? connect : null, child: const Text('Connect')),
            ElevatedButton(onPressed: connected ? disconnect : null, child: const Text('Disconnect')),
          ],
        ),
        const Divider(height: 32),
        const Text('Baud Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          connected ? 'Disconnect before changing baud rate.' : 'Applies the next time you connect.',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 12),
        DropdownButton<int>(
          value: selectedBaud,
          isExpanded: true,
          items: baudOptions.map((b) => DropdownMenuItem(value: b, child: Text('$b'))).toList(),
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
      ],
    );
  }
}
