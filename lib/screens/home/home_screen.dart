import 'package:flutter/material.dart';
import '../../models/country.dart';
import '../../services/database_service.dart';
import '../admin/admin_login_screen.dart';
import '../proxy_list/proxy_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final countries = await _databaseService.getCountriesWithProxies();

      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  }

  // Updated method to pass both country code and name
  void _navigateToProxyList(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProxyListScreen(country: country.name)),
    ).then((_) {
      // Refresh country list when returning from proxy list
      _loadCountries();
    });
  }

  // Convert country code to flag emoji
  String countryCodeToEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeProxy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: _navigateToAdminLogin,
            tooltip: 'Admin Login',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCountries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCountries,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _countries.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No proxies available'),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _countries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          countryCodeToEmoji(country.code),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        country.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${country.proxyCount} ${country.proxyCount == 1 ? 'proxy' : 'proxies'} available',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      onTap: () => _navigateToProxyList(country),
                    ),
                  );
                },
              ),
    );
  }
}
