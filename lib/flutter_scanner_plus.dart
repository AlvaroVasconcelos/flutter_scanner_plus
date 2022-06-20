import 'dart:async';

import 'package:flutter/services.dart';

/// Scan mode which is either QR code or BARCODE
enum ScanMode { qrcode, barcode, all }

/// Provides access to the barcode scanner.
///
/// This class is an interface between the native Android and iOS classes and a
/// Flutter project.
class FlutterScannerPlus {
  static const MethodChannel _channel =
      MethodChannel('flutter_barcode_scanner');

  static const EventChannel _eventChannel =
      EventChannel('flutter_barcode_scanner_receiver');

  static Stream<String>? _onBarcodeReceiver;

  /// Scan with the camera until a barcode is identified, then return.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string.
  static Future<String> scan({
    String lineColor = '#ff6666',
    String cancelButtonText = 'Cancel',
    bool isShowFlashIcon = false,
    ScanMode scanMode = ScanMode.all,
  }) async {
    // Pass params to the plugin
    final params = <String, dynamic>{
      'lineColor': lineColor,
      'cancelButtonText': cancelButtonText,
      'isShowFlashIcon': isShowFlashIcon,
      'isContinuousScan': false,
      'scanMode': scanMode.index
    };

    /// Get barcode scan result
    final barcodeResult = await _channel.invokeMethod<String>(
      'scanBarcode',
      params,
    );
    return barcodeResult ?? '';
  }

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string. Returns a stream of
  /// detected barcode strings.
  static Stream<String>? scanStreamReceiver({
    String lineColor = '#ff6666',
    String cancelButtonText = 'Cancel',
    bool isShowFlashIcon = false,
    ScanMode scanMode = ScanMode.all,
  }) {
    // Pass params to the plugin
    final params = <String, dynamic>{
      'lineColor': lineColor,
      'cancelButtonText': cancelButtonText,
      'isShowFlashIcon': isShowFlashIcon,
      'isContinuousScan': true,
      'scanMode': scanMode.index
    };

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    _channel.invokeMethod('scanBarcode', params);
    _onBarcodeReceiver ??= _eventChannel.receiveBroadcastStream().cast();
    return _onBarcodeReceiver;
  }
}
