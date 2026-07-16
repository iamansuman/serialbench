import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serialbench/core/serial_service.dart';

class SerialMonitor extends StatefulWidget {
  const SerialMonitor({super.key});

  @override
  State<SerialMonitor> createState() => _SerialMonitorState();
}

class _SerialMonitorState extends State<SerialMonitor> {
  final lines = <String>[];
  final scrollController = ScrollController();
  StreamSubscription<String>? lineSub;
  static const int maxLines = 50;

  void onLine(String line) {
    setState(() {
      lines.add(line);
      if (lines.length > maxLines) lines.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    lineSub = SerialService.instance.lines.listen(onLine);
  }

  @override
  void dispose() {
    lineSub?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white70),
              ),
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                controller: scrollController,
                itemCount: lines.length,
                itemBuilder: (context, index) => Text(
                  lines[index],
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // TextButton.icon(onPressed: () => setState(() => _lines.clear()), icon: const Icon(Icons.clear_all), label: const Text('Clear')),
              IconButton(onPressed: () => setState(() => lines.clear()), icon: const Icon(Icons.delete_rounded)),
              const SizedBox(width: 2),
              Expanded(
                child: TextField(
                  textInputAction: TextInputAction.send,
                  onSubmitted: (String str) {
                    if (SerialService.instance.isConnected) {
                      SerialService.instance.writeString(str).then((val) => lines.add(">>> $str"));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
