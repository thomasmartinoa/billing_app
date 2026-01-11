import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';

class ThermalPrinterService {
  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  /// Get list of bonded Bluetooth devices
  static Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      throw Exception('Failed to get bonded devices: $e');
    }
  }

  /// Check if a printer is connected
  static Future<bool> isConnected() async {
    try {
      return await _bluetooth.isConnected ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Connect to a Bluetooth printer
  static Future<void> connect(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
    } catch (e) {
      throw Exception('Failed to connect to printer: $e');
    }
  }

  /// Disconnect from the printer
  static Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }

  /// Print thermal receipt (58mm format)
  static Future<void> printThermalReceipt(
    InvoiceModel invoice,
    ShopSettings? shopSettings,
  ) async {
    try {
      final isConnected = await ThermalPrinterService.isConnected();
      if (!isConnected) {
        throw Exception('Printer not connected');
      }

      final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

      // Start printing
      _bluetooth.printNewLine();

      // Shop Name (Bold & Centered)
      _bluetooth.printCustom(
        shopSettings?.shopName ?? 'My Shop',
        Size.bold.val,
        Align.center.val,
      );

      // Tagline
      if (shopSettings?.tagline != null && shopSettings!.tagline.isNotEmpty) {
        _bluetooth.printCustom(
          shopSettings.tagline,
          Size.medium.val,
          Align.center.val,
        );
      }

      // Address
      if (shopSettings?.address != null && shopSettings!.address.isNotEmpty) {
        _bluetooth.printCustom(
          shopSettings.address,
          Size.medium.val,
          Align.center.val,
        );
      }

      // Phone
      if (shopSettings?.phone != null && shopSettings!.phone.isNotEmpty) {
        _bluetooth.printCustom(
          'Tel: ${shopSettings.phone}',
          Size.medium.val,
          Align.center.val,
        );
      }

      // GST Number
      if (shopSettings?.gstNumber != null &&
          shopSettings!.gstNumber.isNotEmpty) {
        _bluetooth.printCustom(
          'GSTIN: ${shopSettings.gstNumber}',
          Size.medium.val,
          Align.center.val,
        );
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom(
          '--------------------------------', 0, Align.center.val);
      _bluetooth.printNewLine();

      // Invoice Number & Date
      _bluetooth.printCustom(
        'INVOICE #${invoice.invoiceNumber}',
        Size.bold.val,
        Align.center.val,
      );
      _bluetooth.printCustom(
        dateFormat.format(invoice.createdAt),
        Size.medium.val,
        Align.center.val,
      );

      // Customer Name
      if (invoice.customerName != null) {
        _bluetooth.printNewLine();
        _bluetooth.printCustom(
          'Customer: ${invoice.customerName}',
          Size.medium.val,
          Align.center.val,
        );
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom(
          '--------------------------------', 0, Align.center.val);
      _bluetooth.printNewLine();

      // Items
      for (var item in invoice.items) {
        // Product name (centered)
        _bluetooth.printCustom(
          item.productName,
          Size.medium.val,
          Align.center.val,
        );

        // Quantity x Price = Total (left-right aligned)
        final itemLine =
            '${item.quantity} ${item.unit} x Rs.${item.price.toStringAsFixed(2)}';
        final totalLine = 'Rs.${item.total.toStringAsFixed(2)}';

        _bluetooth.printLeftRight(
          itemLine,
          totalLine,
          Size.medium.val,
        );
        _bluetooth.printNewLine();
      }

      _bluetooth.printCustom(
          '--------------------------------', 0, Align.center.val);
      _bluetooth.printNewLine();

      // Subtotal
      _bluetooth.printLeftRight(
        'Subtotal:',
        'Rs.${invoice.subtotal.toStringAsFixed(2)}',
        Size.medium.val,
      );

      // Discount
      if (invoice.discount > 0) {
        _bluetooth.printLeftRight(
          'Discount:',
          '-Rs.${invoice.discount.toStringAsFixed(2)}',
          Size.medium.val,
        );
      }

      // Tax
      _bluetooth.printLeftRight(
        'Tax (${invoice.taxRate.toStringAsFixed(1)}%):',
        'Rs.${invoice.taxAmount.toStringAsFixed(2)}',
        Size.medium.val,
      );

      _bluetooth.printNewLine();

      // Total (Bold)
      _bluetooth.printLeftRight(
        'TOTAL:',
        'Rs.${invoice.total.toStringAsFixed(2)}',
        Size.bold.val,
      );

      _bluetooth.printNewLine();
      _bluetooth.printCustom(
          '--------------------------------', 0, Align.center.val);
      _bluetooth.printNewLine();

      // Payment Method
      _bluetooth.printCustom(
        'Payment: ${_getPaymentMethodName(invoice.paymentMethod)}',
        Size.medium.val,
        Align.center.val,
      );

      // Status
      _bluetooth.printCustom(
        invoice.status == InvoiceStatus.paid
            ? 'Status: PAID'
            : 'Status: PENDING',
        Size.bold.val,
        Align.center.val,
      );

      // Notes
      if (invoice.notes != null && invoice.notes!.isNotEmpty) {
        _bluetooth.printNewLine();
        _bluetooth.printCustom(
            '--------------------------------', 0, Align.center.val);
        _bluetooth.printNewLine();
        _bluetooth.printCustom(
          'Note: ${invoice.notes}',
          Size.medium.val,
          Align.center.val,
        );
      }

      // Thank You Note
      if (shopSettings?.thankYouNote != null &&
          shopSettings!.thankYouNote!.isNotEmpty) {
        _bluetooth.printNewLine();
        _bluetooth.printCustom(
          shopSettings.thankYouNote!,
          Size.medium.val,
          Align.center.val,
        );
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom(
        invoice.status == InvoiceStatus.paid
            ? '*** PAID ***'
            : '*** PENDING ***',
        Size.bold.val,
        Align.center.val,
      );

      _bluetooth.printNewLine();
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();

      // Cut paper (if supported)
      _bluetooth.paperCut();
    } catch (e) {
      throw Exception('Failed to print: $e');
    }
  }

  /// Get payment method name
  static String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.credit:
        return 'Credit';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  /// Print test receipt
  static Future<void> printTestReceipt() async {
    try {
      final isConnected = await ThermalPrinterService.isConnected();
      if (!isConnected) {
        throw Exception('Printer not connected');
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom('TEST PRINT', Size.bold.val, Align.center.val);
      _bluetooth.printNewLine();
      _bluetooth.printCustom(
        'Thermal Printer Connected',
        Size.medium.val,
        Align.center.val,
      );
      _bluetooth.printNewLine();
      _bluetooth.printCustom(
        DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
        Size.medium.val,
        Align.center.val,
      );
      _bluetooth.printNewLine();
      _bluetooth.printCustom(
          '--------------------------------', 0, Align.center.val);
      _bluetooth.printNewLine();
      _bluetooth.printCustom(
          'Test Successful!', Size.medium.val, Align.center.val);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();
      _bluetooth.paperCut();
    } catch (e) {
      throw Exception('Test print failed: $e');
    }
  }
}

// Enums for printer formatting
enum Size { medium, bold, boldMedium, boldLarge, extraLarge }

enum Align { left, center, right }

// Extension for enum values
extension SizeExtension on Size {
  int get val {
    switch (this) {
      case Size.medium:
        return 0;
      case Size.bold:
        return 1;
      case Size.boldMedium:
        return 2;
      case Size.boldLarge:
        return 3;
      case Size.extraLarge:
        return 4;
    }
  }
}

extension AlignExtension on Align {
  int get val {
    switch (this) {
      case Align.left:
        return 0;
      case Align.center:
        return 1;
      case Align.right:
        return 2;
    }
  }
}
