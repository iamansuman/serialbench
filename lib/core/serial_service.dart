import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

class SerialService {
  SerialService._internal() {
    listenForUsbEvents();
  }
  static final SerialService instance = SerialService._internal();

  UsbPort? port;
  UsbDevice? activeDevice;

  StreamSubscription<UsbEvent>? usbEventSub;
  StreamSubscription<String>? lineSub;
  Transaction<String>? lineTransaction;

  final statusController = StreamController<String>.broadcast();
  final deviceListController = StreamController<void>.broadcast();
  final lineController = StreamController<String>.broadcast();

  Stream<String> get status => statusController.stream;
  Stream<void> get deviceListChanged => deviceListController.stream;
  Stream<String> get lines => lineController.stream;

  final ValueNotifier<bool> connectedNotifier = ValueNotifier(false);
  void syncConnected() => connectedNotifier.value = (port != null);
  bool get isConnected => connectedNotifier.value;
  int baudRate = 115200;

  void listenForUsbEvents() {
    usbEventSub = UsbSerial.usbEventStream?.listen((event) {
      deviceListController.add(null);
      if (event.event == UsbEvent.ACTION_USB_DETACHED && activeDevice != null && event.device?.deviceId == activeDevice?.deviceId) {
        disconnect();
      }
    });
  }

  Future<List<UsbDevice>> listDevices() => UsbSerial.listDevices();

  Future<bool> connect(UsbDevice device, {int? baud}) async {
    if (baud != null) baudRate = baud;

    port = await device.create();
    if (port == null) {
      statusController.add('Failed to create port');
      syncConnected();
      return false;
    }

    final opened = await port!.open();
    if (!opened) {
      statusController.add('Failed to open port (check permissions)');
      port = null;
      syncConnected();
      return false;
    }

    activeDevice = device;
    syncConnected();

    await port!.setDTR(true);
    await port!.setRTS(true);
    await port!.setPortParameters(baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    lineTransaction = Transaction.stringTerminated(
      port!.inputStream!,
      Uint8List.fromList([13, 10]), // \r\n
    );

    lineSub = lineTransaction!.stream.listen((line) {
      lineController.add(line);
    });

    statusController.add('Connected at $baudRate baud');
    return true;
  }

  Future<void> write(Uint8List data) async {
    await port?.write(data);
  }

  Future<void> writeString(String text) async {
    await port?.write(Uint8List.fromList(text.codeUnits));
  }

  Future<void> disconnect() async {
    await port?.close();
    await lineSub?.cancel();
    port = null;
    activeDevice = null;
    statusController.add('Disconnected');
    syncConnected();
  }

  void dispose() {
    port?.close();
    lineSub?.cancel();
    usbEventSub?.cancel();
    statusController.close();
    connectedNotifier.dispose();
    deviceListController.close();
    lineController.close();
  }
}
