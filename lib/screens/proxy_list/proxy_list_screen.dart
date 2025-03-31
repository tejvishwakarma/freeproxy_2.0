import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeproxy/models/proxy.dart';
import 'package:freeproxy/models/proxy_status.dart';
import 'package:freeproxy/screens/proxy_details/proxy_details_screen.dart';
import 'package:freeproxy/services/database_service.dart';
import 'package:freeproxy/services/proxy_checker_service.dart';
import 'package:freeproxy/services/notification_service.dart';
import 'package:freeproxy/widgets/app_scaffold.dart';
import 'package:freeproxy/screens/admin/add_edit_proxy_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProxyListScreen extends StatefulWidget {
  final String country;

  const ProxyListScreen({Key? key, required this.country}) : super(key: key);

  @override
  State<ProxyListScreen> createState() => _ProxyListScreenState();
}

class _ProxyListScreenState extends State<ProxyListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ProxyCheckerService _proxyCheckerService = ProxyCheckerService();
  final NotificationService _notificationService = NotificationService();

  List<Proxy> _proxies = [];
  final Map<String, ProxyStatus> _proxyStatuses = <String, ProxyStatus>{};
  bool _isLoading = true;
  String? _errorMessage;
  bool _checkingStatus = false;
  bool _isAdmin = false;

  // Map country names to country codes
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

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadProxies();
    _checkIfAdmin();
    print('ProxyListScreen initialized for country: ${widget.country}');
  }

  // Check if user is admin directly from SharedPreferences
  Future<void> _checkIfAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedAdminData = prefs.getString('admin_data');
      setState(() {
        _isAdmin = storedAdminData != null;
      });
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  Future<void> _loadProxies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the country code from the country name
      final countryCode = _countryNameToCode[widget.country] ?? widget.country;
      print(
        'Loading proxies for location: ${widget.country} (code: $countryCode)',
      );

      final proxies = await _databaseService.getProxiesByCountry(countryCode);

      if (mounted) {
        setState(() {
          _proxies = proxies;
          _isLoading = false;
        });

        print('Loaded ${proxies.length} proxies for ${widget.country}');
      }
    } catch (e) {
      print('Error loading proxies: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load proxies: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _checkProxyStatus({Proxy? singleProxy}) async {
    if (_checkingStatus) return;

    setState(() {
      _checkingStatus = true;
    });

    try {
      final proxiesToCheck = singleProxy != null ? [singleProxy] : _proxies;

      for (final proxy in proxiesToCheck) {
        setState(() {
          _proxyStatuses[proxy.id] = ProxyStatus(
            isAlive: false,
            responseTimeMs: 0,
            checkedAt: DateTime.now(),
          );
        });

        final status = await _proxyCheckerService.checkProxy(proxy);

        if (mounted) {
          setState(() {
            _proxyStatuses[proxy.id] = status;
          });
        }
      }
    } catch (e) {
      print('Error checking proxy status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
        });
      }
    }
  }

  void _navigateToProxyDetails(Proxy proxy) {
    bool isAlive = _proxyStatuses[proxy.id]?.isAlive ?? false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProxyDetailsScreen(proxy: proxy, isAlive: isAlive),
      ),
    );
  }

  void _navigateToAddProxy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProxyScreen(countryName: widget.country),
      ),
    ).then((_) => _loadProxies());
  }

  // Helper method to mask IP address - showing only first octet
  String _maskIpAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length == 4) {
      return "${parts[0]}.***.***";
    }
    return ip; // Return original if not in expected format
  }

  Widget _buildProxyStatus(String proxyId) {
    if (!_proxyStatuses.containsKey(proxyId)) {
      return const SizedBox.shrink();
    }

    final status = _proxyStatuses[proxyId]!;

    if (_checkingStatus) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (status.isAlive) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 16);
    } else {
      return const Icon(Icons.error, color: Colors.red, size: 16);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProxies, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_proxies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dns_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No proxies available for ${widget.country}'),
            const SizedBox(height: 16),
            if (_isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Proxy'),
                onPressed: _navigateToAddProxy,
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProxies,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _proxies.length,
        itemBuilder: (context, index) {
          final proxy = _proxies[index];
          // Mask the IP address for security
          final maskedIp = _maskIpAddress(proxy.ip);
          final displayText = '$maskedIp:${proxy.port}';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () => _navigateToProxyDetails(proxy),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Location: ${proxy.location}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProxyStatus(proxy.id),
                    // Removed copy button as requested
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Check proxy',
                      onPressed:
                          _checkingStatus
                              ? null
                              : () => _checkProxyStatus(singleProxy: proxy),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '${widget.country} Proxies',
      actions: [
        if (_proxies.isNotEmpty && !_checkingStatus)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _checkProxyStatus(),
            tooltip: 'Check all proxies',
          ),
      ],
      body: _buildBody(),
      // Only show FAB if user is admin
      floatingActionButton:
          _isAdmin
              ? FloatingActionButton(
                onPressed: _navigateToAddProxy,
                tooltip: 'Add new proxy',
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationIndex: 0,
    );
  }
}
