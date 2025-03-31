class ProxyStatus {
  final bool isAlive;
  final int responseTimeMs;
  final DateTime checkedAt;

  ProxyStatus({
    required this.isAlive,
    required this.responseTimeMs,
    required this.checkedAt,
  });
}
