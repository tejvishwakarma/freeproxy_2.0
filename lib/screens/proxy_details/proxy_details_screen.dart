import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/proxy.dart';

class ProxyDetailsScreen extends StatefulWidget {
  final Proxy proxy;
  final bool isAlive;

  const ProxyDetailsScreen({
    Key? key,
    required this.proxy,
    required this.isAlive,
  }) : super(key: key);

  @override
  _ProxyDetailsScreenState createState() => _ProxyDetailsScreenState();
}

class _ProxyDetailsScreenState extends State<ProxyDetailsScreen> {
  Map<String, bool> _copiedFields = {};
  final DateTime _currentDateTime = DateTime.now().toUtc();

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      setState(() {
        _copiedFields[fieldName] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName copied to clipboard'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Reset the copied state after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _copiedFields[fieldName] = false;
          });
        }
      });
    });
  }

  void _shareProxyDetails() {
    final proxy = widget.proxy;
    final plainFormat = '${proxy.ip}:${proxy.port}';
    final formattedDateTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentDateTime);

    final fullDetails = '''
Proxy Details:
IP: ${proxy.ip}
Port: ${proxy.port}
${proxy.username.isNotEmpty ? 'Username: ${proxy.username}\n' : ''}${proxy.password.isNotEmpty ? 'Password: ${proxy.password}\n' : ''}
Location: ${proxy.location}
Status: ${widget.isAlive ? 'Online' : 'Offline'}

Plain format: $plainFormat
${proxy.username.isNotEmpty && proxy.password.isNotEmpty ? 'Auth format: ${proxy.username}:${proxy.password}@${proxy.ip}:${proxy.port}' : ''}

Generated on: $formattedDateTime UTC
Shared from FreeProxy App
''';

    Share.share(fullDetails, subject: 'Proxy Details');
  }

  @override
  Widget build(BuildContext context) {
    final proxy = widget.proxy;
    final plainFormat = '${proxy.ip}:${proxy.port}';
    final formattedDateTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(_currentDateTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Proxy Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Current Date & Time (UTC): $formattedDateTime',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Status indicator
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isAlive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isAlive ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isAlive
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // All details in a single card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IP Address
                    const Text(
                      'IP Address',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            proxy.ip,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _copiedFields['IP'] == true
                                ? Icons.check
                                : Icons.copy,
                            color:
                                _copiedFields['IP'] == true
                                    ? Colors.green
                                    : Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _copyToClipboard(proxy.ip, 'IP'),
                          tooltip: 'Copy IP Address',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Port
                    const Text(
                      'Port',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            proxy.port,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _copiedFields['Port'] == true
                                ? Icons.check
                                : Icons.copy,
                            color:
                                _copiedFields['Port'] == true
                                    ? Colors.green
                                    : Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _copyToClipboard(proxy.port, 'Port'),
                          tooltip: 'Copy Port',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),

                    if (proxy.username.isNotEmpty) ...[
                      const Divider(height: 24),

                      // Username
                      const Text(
                        'Username',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              proxy.username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _copiedFields['Username'] == true
                                  ? Icons.check
                                  : Icons.copy,
                              color:
                                  _copiedFields['Username'] == true
                                      ? Colors.green
                                      : Colors.blue,
                              size: 20,
                            ),
                            onPressed:
                                () => _copyToClipboard(
                                  proxy.username,
                                  'Username',
                                ),
                            tooltip: 'Copy Username',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (proxy.password.isNotEmpty) ...[
                      const Divider(height: 24),

                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              proxy.password,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _copiedFields['Password'] == true
                                  ? Icons.check
                                  : Icons.copy,
                              color:
                                  _copiedFields['Password'] == true
                                      ? Colors.green
                                      : Colors.blue,
                              size: 20,
                            ),
                            onPressed:
                                () => _copyToClipboard(
                                  proxy.password,
                                  'Password',
                                ),
                            tooltip: 'Copy Password',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: 24),

                    // Location
                    const Text(
                      'Location',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            proxy.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _copiedFields['Location'] == true
                                ? Icons.check
                                : Icons.copy,
                            color:
                                _copiedFields['Location'] == true
                                    ? Colors.green
                                    : Colors.blue,
                            size: 20,
                          ),
                          onPressed:
                              () =>
                                  _copyToClipboard(proxy.location, 'Location'),
                          tooltip: 'Copy Location',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Copy IP:Port button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _copyToClipboard(plainFormat, 'IP:Port'),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy IP:Port'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Share button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareProxyDetails,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Proxy Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Last checked date
            const SizedBox(height: 16),
            Text(
              'Last status check: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_currentDateTime)} UTC',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
