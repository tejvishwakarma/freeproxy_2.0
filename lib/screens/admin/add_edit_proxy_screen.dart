import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeproxy/models/proxy.dart';
import 'package:freeproxy/services/database_service.dart';
import 'package:freeproxy/services/notification_service.dart';

class AddEditProxyScreen extends StatefulWidget {
  final Proxy? proxy;
  final String? countryName;

  const AddEditProxyScreen({Key? key, this.proxy, this.countryName})
    : super(key: key);

  @override
  State<AddEditProxyScreen> createState() => _AddEditProxyScreenState();
}

class _AddEditProxyScreenState extends State<AddEditProxyScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _locationController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _selectedCountry;

  // Country name to code mapping
  final Map<String, String> _countryNameToCode = {
    'United States': 'US',
    'United Kingdom': 'GB',
    'Canada': 'CA',
    'Australia': 'AU',
    'Germany': 'DE',
    'France': 'FR',
    'Italy': 'IT',
    'Spain': 'ES',
    'Japan': 'JP',
    'China': 'CN',
    'India': 'IN',
    'Brazil': 'BR',
    'Russia': 'RU',
    'Mexico': 'MX',
    'Netherlands': 'NL',
    'Singapore': 'SG',
    'Sweden': 'SE',
    'Switzerland': 'CH',
    'Norway': 'NO',
    'Finland': 'FI',
    'Denmark': 'DK',
    'Ireland': 'IE',
    'New Zealand': 'NZ',
    'South Africa': 'ZA',
    'United Arab Emirates': 'AE',
  };

  List<String> get _countryNames => _countryNameToCode.keys.toList();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.proxy != null;
    _initializeNotifications();

    if (_isEditing) {
      _populateFormWithExistingData();
    } else if (widget.countryName != null) {
      _locationController.text = widget.countryName!;
      _selectedCountry = widget.countryName;
    }
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _populateFormWithExistingData() {
    final proxy = widget.proxy!;
    _ipController.text = proxy.ip;
    _portController.text = proxy.port;
    _locationController.text = proxy.location;

    // Find the country name from the code
    for (final entry in _countryNameToCode.entries) {
      if (entry.value == proxy.countryCode) {
        _selectedCountry = entry.key;
        break;
      }
    }

    _usernameController.text = proxy.username;
    _passwordController.text = proxy.password;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get country code from selected country name
      final countryCode =
          _selectedCountry != null
              ? _countryNameToCode[_selectedCountry] ?? 'US'
              : 'US';

      final proxy = Proxy(
        id: _isEditing ? widget.proxy!.id : '',
        ip: _ipController.text.trim(),
        port: _portController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        countryCode: countryCode,
        location: _locationController.text.trim(),
        isActive: true, // Always active by default
      );

      if (_isEditing) {
        await _databaseService.saveProxy(proxy);
        if (mounted) {
          _showSuccessMessage('Proxy updated successfully');
        }
      } else {
        await _databaseService.saveProxy(proxy);
        if (mounted) {
          _showSuccessMessage('Proxy added successfully');
          // Show notification
          await _notificationService.showProxyAddedNotification(
            proxy.ip,
            proxy.port,
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Proxy' : 'Add Proxy')),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // IP Address field
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'Enter IP address (e.g. 192.168.1.1)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an IP address';
                  }

                  // Simple IP validation
                  final ipRegex = RegExp(
                    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
                  );
                  if (!ipRegex.hasMatch(value)) {
                    return 'Enter a valid IP address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Port field
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: 'Enter port (e.g. 8080)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a port number';
                  }

                  final port = int.tryParse(value);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Enter a valid port number (1-65535)';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Country dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCountry,
                items:
                    _countryNames.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _locationController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a country';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter specific location (e.g. New York)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Username field - Optional
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Optional)',
                  hintText: 'Enter username if required',
                  border: OutlineInputBorder(),
                ),
                // No validator since it's optional
              ),

              const SizedBox(height: 16),

              // Password field - Optional
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (Optional)',
                  hintText: 'Enter password if required',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                // No validator since it's optional
              ),

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(_isEditing ? 'Update Proxy' : 'Add Proxy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
