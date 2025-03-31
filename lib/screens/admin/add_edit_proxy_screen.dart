import 'package:flutter/material.dart';
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
  final _countryCodeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.proxy != null;
    _initializeNotifications();

    if (_isEditing) {
      _populateFormWithExistingData();
    } else if (widget.countryName != null) {
      _locationController.text = widget.countryName!;
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
    _countryCodeController.text = proxy.countryCode;
    _usernameController.text = proxy.username;
    _passwordController.text = proxy.password;
    _isActive = proxy.isActive;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _locationController.dispose();
    _countryCodeController.dispose();
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
      final proxy = Proxy(
        id: _isEditing ? widget.proxy!.id : '',
        ip: _ipController.text.trim(),
        port: _portController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        countryCode: _countryCodeController.text.trim(),
        location: _locationController.text.trim(),
        isActive: _isActive,
        // createdAt and updatedAt will be set by default constructor
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
        Navigator.of(context).pop();
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
                keyboardType: TextInputType.text,
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

              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter country name',
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

              // Country Code field
              TextFormField(
                controller: _countryCodeController,
                decoration: const InputDecoration(
                  labelText: 'Country Code',
                  hintText: 'Enter 2-letter country code (e.g. US)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country code';
                  }

                  // Check if it's a 2-letter code
                  if (value.length != 2) {
                    return 'Country code should be 2 letters';
                  }

                  return null;
                },
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
              ),

              const SizedBox(height: 8),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Active status switch
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Enable or disable this proxy'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
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
