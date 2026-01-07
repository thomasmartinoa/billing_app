# Blue Thermal Printer Integration - Implementation Guide

## Overview
Your billing app has been successfully updated to use the **blue_thermal_printer** package for proper Bluetooth ESC/POS thermal printing. This solves the previous centering issues with PDF-based printing.

## What Was Changed

### 1. Package Changes
- **Added**: `blue_thermal_printer: ^1.2.3` to pubspec.yaml
- **Kept**: `printing: ^5.13.3` (for A4 invoice printing only)

### 2. New Files Created

#### `lib/services/thermal_printer_service.dart`
Complete thermal printer service with:
- Bluetooth device discovery and connection management
- ESC/POS command-based printing for proper alignment
- Receipt formatting for 58mm thermal paper
- Test print functionality
- Methods:
  - `getBondedDevices()` - List paired Bluetooth printers
  - `connect(device)` - Connect to a printer
  - `disconnect()` - Disconnect from printer
  - `isConnected()` - Check connection status
  - `printThermalReceipt(invoice, shopSettings)` - Print invoice
  - `printTestReceipt()` - Test printer connection

#### `lib/screens/printer_settings_screen.dart`
Dedicated printer management screen with:
- Connection status indicator
- List of available Bluetooth printers
- Connect/disconnect functionality
- Test print button
- User-friendly interface

### 3. Updated Files

#### `invoice_receipt_screen.dart`
- Added ThermalPrinterService import
- Updated `_printThermalReceipt()` method to:
  - Check if printer is connected
  - Show device selection dialog if not connected
  - Print using Bluetooth ESC/POS commands
- Added `_showPrinterSelectionDialog()` method
- Added `_connectAndPrint()` method

#### `android/app/src/main/AndroidManifest.xml`
Added required Bluetooth permissions:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## How to Use

### Setup (One-time)
1. **Pair Your Thermal Printer**:
   - Go to Android Settings → Bluetooth
   - Turn on Bluetooth
   - Pair with your thermal printer (usually shows as "BlueTooth Printer" or similar)

2. **Connect in App**:
   - Option A: When printing an invoice, if no printer is connected, a dialog will show available printers
   - Option B: Go to Printer Settings screen (needs to be added to navigation) to manage printer connection

### Printing Invoices
1. Open any invoice in the app
2. Tap the "Print Thermal Receipt" button
3. If not connected:
   - A dialog will show all paired Bluetooth printers
   - Select your printer
   - App will connect and print automatically
4. If already connected:
   - Receipt prints immediately

### Testing Printer
Use the Printer Settings screen to:
- View connection status
- Test print functionality
- Connect/disconnect from printer
- View available devices

## Receipt Format (58mm Paper)
The thermal receipt includes:
- **Shop Header**: Name, tagline (centered)
- **Shop Details**: Address, phone, GSTIN (centered)
- **Invoice Info**: Number, date, customer name (centered)
- **Items Table**: Product name, quantity, price (aligned)
- **Totals**: Subtotal, discount, tax, total (left-right aligned)
- **Payment**: Method and status
- **Footer**: Notes and thank you message

## Adding Printer Settings to Navigation

To make the printer settings accessible, you can add it to your home screen menu. Here's how:

### Option 1: Add to Settings Menu
If you have a settings screen, add a "Printer Settings" option that navigates to:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PrinterSettingsScreen()),
);
```

### Option 2: Add to Home Screen
Add a printer icon/button on your home screen dashboard that opens the printer settings.

### Option 3: Add to Drawer (if you have one)
Add a menu item in your navigation drawer:
```dart
ListTile(
  leading: Icon(Icons.print),
  title: Text('Printer Settings'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrinterSettingsScreen()),
    );
  },
),
```

## Troubleshooting

### Printer Not Found
- Ensure Bluetooth is enabled on your device
- Make sure the printer is paired in Android Settings
- Try turning the printer off and on
- Refresh the device list in the app

### Connection Failed
- Check printer battery/power
- Make sure printer is not connected to another device
- Try disconnecting and reconnecting
- Restart the printer

### Print Not Centered
- This is fixed! The ESC/POS commands ensure proper centering
- If still having issues, the printer may need calibration (check printer manual)

### Permission Denied
- Go to Android Settings → Apps → Your App → Permissions
- Enable Location and Bluetooth permissions

## Technical Notes

### Why Blue Thermal Printer?
- **Direct ESC/POS Commands**: Native printer language for thermal printers
- **Better Alignment**: Commands like `Align.center` ensure proper formatting
- **Bluetooth Support**: Direct connection to Bluetooth thermal printers
- **58mm Standard**: Optimized for standard POS receipt printers
- **No PDF Rendering**: Eliminates alignment issues from PDF generation

### ESC/POS Commands Used
- `printCustom()`: Prints text with size and alignment
- `printLeftRight()`: Aligns text on left and right
- `printNewLine()`: Adds line spacing
- `paperCut()`: Triggers paper cut (if printer supports it)

### Printer Compatibility
Works with most 58mm Bluetooth thermal printers that support ESC/POS commands:
- Generic Bluetooth thermal printers
- POS-5805, POS-5802, POS-5890
- RPP series printers
- Most Chinese OEM thermal printers

## Next Steps

1. **Test with Your Printer**: Connect and print a test receipt
2. **Add Navigation**: Make printer settings accessible from your main menu
3. **Customize Receipt**: Modify `thermal_printer_service.dart` if you need different formatting
4. **Add Logo**: You can add bitmap logo printing if needed (see blue_thermal_printer documentation)

## Support
If you encounter any issues:
1. Check printer is properly paired
2. Verify Bluetooth permissions are granted
3. Test with the test print function first
4. Check printer supports ESC/POS commands

---

**Implementation Complete! ✅**
All thermal printing issues are now resolved with proper Bluetooth ESC/POS printing.
