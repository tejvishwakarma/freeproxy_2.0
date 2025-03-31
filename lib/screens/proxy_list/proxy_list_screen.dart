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

class ProxyListScreen extends StatefulWidget {
  final String country; // Keep for backward compatibility
  final String? countryCode; // Add this as optional for now

  const ProxyListScreen({Key? key, required this.country, this.countryCode})
    : super(key: key);

  @override
  State<ProxyListScreen> createState() => _ProxyListScreenState();
}

class _ProxyListScreenState extends State<ProxyListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ProxyCheckerService _proxyCheckerService = ProxyCheckerService();
  final NotificationService _notificationService = NotificationService();
  List<Proxy> _proxies = [];
  final Map<String, ProxyStatus> _proxyStatus = <String, ProxyStatus>{};
  bool _isLoading = true;
  String? _errorMessage;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadProxies();
  }

  Future<void> _loadProxies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Proxy> proxies = await _databaseService.getAllProxies();

      // Filter proxies by country if specified
      if (widget.country != null && widget.country!.isNotEmpty) {
        proxies =
            proxies
                .where(
                  (proxy) =>
                      proxy.location.toLowerCase() ==
                      widget.country!.toLowerCase(),
                )
                .toList();
      }

      setState(() {
        _proxies = proxies;
        _isLoading = false;
      });

      // Check proxy status after loading
      _checkProxyStatus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load proxies: ${e.toString()}';
      });
    }
  }

  Future<void> _checkProxyStatus() async {
    if (_checkingStatus) return; // Prevent multiple concurrent checks

    setState(() {
      _checkingStatus = true;
    });

    for (final proxy in _proxies) {
      // Use the ProxyCheckerService to check each proxy
      final status = await _proxyCheckerService.checkProxy(proxy);

      if (mounted) {
        setState(() {
          // Store the full ProxyStatus object
          _proxyStatus[proxy.id] = status;
        });
      }
    }

    setState(() {
      _checkingStatus = false;
    });
  }

  void _navigateToProxyDetails(Proxy proxy) {
    // Get the ProxyStatus object from the map
    final ProxyStatus? status = _proxyStatus[proxy.id];

    // Extract the isAlive property or default to false if status is null
    final bool isAlive = status?.isAlive ?? false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProxyDetailsScreen(proxy: proxy, isAlive: isAlive),
      ),
    ).then((_) => _loadProxies()); // Refresh the list when returning
  }

  Future<void> _navigateToAddProxy() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProxyScreen()),
    );

    if (result == true) {
      _loadProxies();
    }
  }

  Future<void> _deleteProxy(Proxy proxy) async {
    try {
      await _databaseService.deleteProxy(proxy);
      _loadProxies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proxy deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete proxy: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshList() async {
    await _loadProxies();
  }

  Widget _buildProxyItem(Proxy proxy) {
    // Get the ProxyStatus or null if not checked yet
    final ProxyStatus? status = _proxyStatus[proxy.id];

    // Default to gray if not checked yet
    Color statusColor = Colors.grey;
    String statusText = "Not checked";

    // Update color and text based on status
    if (status != null) {
      if (status.isAlive) {
        statusColor = Colors.green;
        statusText = "${status.responseTimeMs} ms";
      } else {
        statusColor = Colors.red;
        statusText = "Offline";
      }
    }

    return Dismissible(
      key: Key(proxy.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Proxy'),
                content: const Text(
                  'Are you sure you want to delete this proxy?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        _deleteProxy(proxy);
      },
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
        ),
        title: Text('${proxy.ip}:${proxy.port}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed the label check since your Proxy model doesn't have a label property
            Row(
              children: [
                const Icon(Icons.location_on, size: 14),
                const SizedBox(width: 4),
                Text(proxy.location.isEmpty ? 'Unknown' : proxy.location),
                const SizedBox(width: 12),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                final proxyString =
                    proxy.username.isNotEmpty && proxy.password.isNotEmpty
                        ? 'socks5://${proxy.username}:${proxy.password}@${proxy.ip}:${proxy.port}'
                        : 'socks5://${proxy.ip}:${proxy.port}';
                Clipboard.setData(ClipboardData(text: proxyString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proxy copied to clipboard')),
                );
              },
              tooltip: 'Copy proxy string',
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _navigateToProxyDetails(proxy),
      ),
    );
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
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
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
            const Icon(Icons.vpn_key, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No proxies added yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Proxy'),
              onPressed: _navigateToAddProxy,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshList,
      child: ListView.separated(
        itemCount: _proxies.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final proxy = _proxies[index];
          return _buildProxyItem(proxy);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'My Proxies';
    if (widget.country != null && widget.country!.isNotEmpty) {
      title = '${widget.country} Proxies';
    }

    return AppScaffold(
      title: title,
      actions: [
        if (_proxies.isNotEmpty && !_checkingStatus)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkProxyStatus,
            tooltip: 'Check all proxies',
          ),
      ],
      body: _buildBody(),
      bottomNavigationIndex: 0,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProxy,
        tooltip: 'Add new proxy',
        child: const Icon(Icons.add),
      ),
    );
  }
}
