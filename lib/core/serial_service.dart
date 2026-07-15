import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

class SerialService {
  SerialService.internal();
  static final SerialService instance = SerialService.internal();

  UsbPort? port;
  StreamSubscription<String>? lineSub;
  Transaction<String>? lineTransaction;

  final statusController = StreamController<String>.broadcast();
  final lineController = StreamController<String>.broadcast();

  Stream<String> get status => statusController.stream;
  Stream<String> get lines => lineController.stream;

  bool get isConnected => port != null;
  int baudRate = 115200;

  Future<List<UsbDevice>> listDevices() => UsbSerial.listDevices();

  Future<bool> connect(UsbDevice device, {int? baud}) async {
    if (baud != null) baudRate = baud;

    port = await device.create();
    if (port == null) {
      statusController.add('Failed to create port');
      return false;
    }

    final opened = await port!.open();
    if (!opened) {
      statusController.add('Failed to open port (check permissions)');
      port = null;
      return false;
    }

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
    statusController.add('Disconnected');
  }

  void dispose() {
    port?.close();
    lineSub?.cancel();
    statusController.close();
    lineController.close();
  }
}
