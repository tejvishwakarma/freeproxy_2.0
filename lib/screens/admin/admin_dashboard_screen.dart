import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/proxy.dart';
import 'add_edit_proxy_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Proxy> _allProxies = [];
  bool _isLoading = true;
  String? _selectedCountry;
  List<String> _availableCountries = [];

  @override
  void initState() {
    super.initState();
    _loadProxies();
  }

  Future<void> _loadProxies() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all proxies
      final proxies = await _databaseService.getAllProxies();

      // Extract unique country codes
      final countries =
          proxies.map((proxy) => proxy.countryCode).toSet().toList();

      countries.sort();

      setState(() {
        _allProxies = proxies;
        _availableCountries = countries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading proxies: ${e.toString()}')),
      );
    }
  }

  // Filtered proxies based on selected country
  List<Proxy> get _filteredProxies {
    if (_selectedCountry == null) {
      return _allProxies;
    }
    return _allProxies
        .where((proxy) => proxy.countryCode == _selectedCountry)
        .toList();
  }

  void _navigateToAddProxy() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProxyScreen()),
    );

    if (result == true) {
      _loadProxies();
    }
  }

  void _navigateToEditProxy(Proxy proxy) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProxyScreen(proxy: proxy)),
    );

    if (result == true) {
      _loadProxies();
    }
  }

  void _logout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Admin info card
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings),
                const SizedBox(width: 8),
                Text(
                  'Welcome, ${authService.currentAdminUsername ?? "Admin"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Country',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: _selectedCountry,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Countries'),
                      ),
                      ..._availableCountries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _loadProxies,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),

          // Proxy list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProxies.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.dns_outlined,
                            size: 72,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCountry == null
                                ? 'No proxies available'
                                : 'No proxies for $_selectedCountry',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredProxies.length,
                      itemBuilder: (context, index) {
                        final proxy = _filteredProxies[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              proxy.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: proxy.isActive ? Colors.green : Colors.red,
                            ),
                            title: Text('${proxy.ip}:${proxy.port}'),
                            subtitle: Text(
                              '${proxy.countryCode} - ${proxy.location}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToEditProxy(proxy),
                            ),
                            onTap: () => _navigateToEditProxy(proxy),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProxy,
        child: const Icon(Icons.add),
        tooltip: 'Add Proxy',
      ),
    );
  }
}
