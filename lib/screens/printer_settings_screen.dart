import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/services/thermal_printer_service.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _getDevices();
  }

  Future<void> _checkConnection() async {
    try {
      final connected = await ThermalPrinterService.isConnected();
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    } catch (e) {
      debugPrint('Error checking connection: $e');
    }
  }

  Future<void> _getDevices() async {
    setState(() => _isLoading = true);
    try {
      final devices = await ThermalPrinterService.getBondedDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting devices: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _isLoading = true);
    try {
      await ThermalPrinterService.connect(device);
      if (mounted) {
        setState(() {
          _connectedDevice = device;
          _isConnected = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.name}'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isLoading = true);
    try {
      await ThermalPrinterService.disconnect();
      if (mounted) {
        setState(() {
          _connectedDevice = null;
          _isConnected = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Disconnected from printer'),
            backgroundColor: context.warningColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnect failed: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _printTest() async {
    setState(() => _isLoading = true);
    try {
      if (!_isConnected) {
        throw Exception('Printer not connected');
      }

      await ThermalPrinterService.printTestReceipt();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Test print sent successfully'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test print failed: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'Thermal Printer Settings',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _getDevices,
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.accent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status Card
                  _buildConnectionStatusCard(),
                  const SizedBox(height: 20),

                  // Connected Printer Card
                  if (_isConnected && _connectedDevice != null)
                    _buildConnectedPrinterCard(),

                  if (_isConnected && _connectedDevice != null)
                    const SizedBox(height: 20),

                  // Available Devices
                  _buildDevicesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _isConnected ? Icons.check_circle : Icons.cancel,
              color: _isConnected ? context.successColor : context.errorColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isConnected ? 'Connected' : 'Not Connected',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isConnected
                        ? 'Printer is ready to print'
                        : 'No printer connected',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedPrinterCard() {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected Printer',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.print, color: context.accent, size: 32),
              title: Text(
                _connectedDevice?.name ?? 'Unknown Device',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _connectedDevice?.address ?? '',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printTest,
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: context.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.errorColor,
                      foregroundColor: context.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Bluetooth Printers',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a paired Bluetooth printer to connect',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        if (_devices.isEmpty)
          Card(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bluetooth_disabled,
                        color: context.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No paired printers found',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please pair a Bluetooth printer in your device settings',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ..._devices.map((device) => Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.print, color: context.accent),
                  title: Text(
                    device.name ?? 'Unknown Device',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    device.address ?? '',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  trailing: _connectedDevice?.address == device.address
                      ? Icon(Icons.check_circle, color: context.successColor)
                      : Icon(Icons.chevron_right, color: context.textSecondary),
                  onTap: _connectedDevice?.address == device.address
                      ? null
                      : () => _connectToDevice(device),
                ),
              )),
      ],
    );
  }
}
