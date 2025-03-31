import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/proxy.dart';
import '../../services/database_service.dart';

class AddEditProxyScreen extends StatefulWidget {
  final Proxy? proxy; // Null if adding new proxy, existing proxy if editing

  const AddEditProxyScreen({Key? key, this.proxy}) : super(key: key);

  @override
  _AddEditProxyScreenState createState() => _AddEditProxyScreenState();
}

class _AddEditProxyScreenState extends State<AddEditProxyScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // Form fields
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _locationController;
  String _selectedCountry = 'US'; // Default country
  bool _isActive = true;

  // List of countries for dropdown
  final List<Map<String, String>> _countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'RU', 'name': 'Russia'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'CN', 'name': 'China'},
    {'code': 'SG', 'name': 'Singapore'},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing proxy data if editing
    _ipController = TextEditingController(text: widget.proxy?.ip ?? '');
    _portController = TextEditingController(text: widget.proxy?.port ?? '');
    _usernameController = TextEditingController(
      text: widget.proxy?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.proxy?.password ?? '',
    );
    _locationController = TextEditingController(
      text: widget.proxy?.location ?? '',
    );

    if (widget.proxy != null) {
      _selectedCountry = widget.proxy!.countryCode;
      _isActive = widget.proxy!.isActive;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Validate IP address format
  bool _isValidIpAddress(String ip) {
    RegExp ipRegex = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

    if (!ipRegex.hasMatch(ip)) return false;

    // Check each octet is between 0-255
    List<String> octets = ip.split('.');
    return octets.every((octet) {
      int value = int.parse(octet);
      return value >= 0 && value <= 255;
    });
  }

  // Save proxy to database
  Future<void> _saveProxy() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Create proxy object from form data
        Proxy proxy = Proxy(
          id: widget.proxy?.id ?? '',
          ip: _ipController.text.trim(),
          port: _portController.text.trim(),
          username: _usernameController.text.trim(), // Now optional
          password: _passwordController.text.trim(), // Now optional
          countryCode: _selectedCountry,
          location: _locationController.text.trim(),
          isActive: _isActive,
          createdAt: widget.proxy?.createdAt,
          updatedAt: DateTime.now(),
        );

        await _databaseService.saveProxy(proxy);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show success message and pop back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Proxy ${widget.proxy == null ? 'added' : 'updated'} successfully',
              ),
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proxy == null ? 'Add New Proxy' : 'Edit Proxy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProxy,
            tooltip: 'Save Proxy',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // IP Address
                      TextFormField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          labelText: 'IP Address',
                          hintText: 'e.g. 192.168.1.1',
                          prefixIcon: Icon(Icons.language),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an IP address';
                          }
                          if (!_isValidIpAddress(value)) {
                            return 'Please enter a valid IP address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Port
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          hintText: 'e.g. 8080',
                          prefixIcon: Icon(Icons.settings_ethernet),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a port number';
                          }

                          int? port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return 'Please enter a valid port number (1-65535)';
                          }

                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Username (Optional)
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username (Optional)',
                          hintText: 'Enter proxy username (optional)',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        // No validator - field is optional
                      ),
                      const SizedBox(height: 16),

                      // Password (Optional)
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password (Optional)',
                          hintText: 'Enter proxy password (optional)',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.content_copy),
                            tooltip: 'Generate Password',
                            onPressed: () {
                              // Generate a random password (in a real app)
                              setState(() {
                                _passwordController.text =
                                    'Password${DateTime.now().millisecondsSinceEpoch % 10000}';
                              });
                            },
                          ),
                        ),
                        // No validator - field is optional
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // Country selection
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          prefixIcon: Icon(Icons.public),
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['code'],
                                child: Text(
                                  '${country['name']} (${country['code']})',
                                ),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g. New York, NY',
                          prefixIcon: Icon(Icons.location_on),
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

                      // Active toggle
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Enable or disable this proxy'),
                        value: _isActive,
                        onChanged: (bool value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProxy,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.proxy == null ? 'Add Proxy' : 'Update Proxy',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      if (widget.proxy != null) ...[
                        const SizedBox(height: 16),
                        // Delete button (only for editing)
                        OutlinedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    // Show confirmation dialog
                                    bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text('Delete Proxy'),
                                            content: const Text(
                                              'Are you sure you want to delete this proxy? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );

                                    // If confirmed, delete the proxy
                                    if (confirm == true) {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await _databaseService.deleteProxy(
                                          widget.proxy!,
                                        );

                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Proxy deleted successfully',
                                              ),
                                            ),
                                          );
                                          Navigator.of(context).pop(
                                            true,
                                          ); // Return true to indicate success
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _isLoading = false;
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error deleting proxy: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Delete Proxy',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],

                      // Created/updated timestamps (only for editing)
                      if (widget.proxy != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${_formatDateTime(widget.proxy!.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Updated: ${_formatDateTime(widget.proxy!.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  // Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
