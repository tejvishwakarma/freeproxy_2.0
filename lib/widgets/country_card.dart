import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/country.dart';

class CountryCard extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;

  const CountryCard({Key? key, required this.country, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Country flag
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 40,
                  child: _getCountryFlag(country.code),
                ),
              ),
              const SizedBox(height: 12),
              // Country name
              Text(
                country.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Proxy count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${country.proxyCount} ${country.proxyCount == 1 ? 'Proxy' : 'Proxies'}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCountryFlag(String countryCode) {
    try {
      // Try to load country flag from assets
      return SvgPicture.asset(
        'assets/flags/${countryCode.toLowerCase()}.svg',
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => _buildFlagFallback(countryCode),
      );
    } catch (e) {
      return _buildFlagFallback(countryCode);
    }
  }

  Widget _buildFlagFallback(String countryCode) {
    // Generate a color based on country code for placeholder
    final int hashCode = countryCode.hashCode;
    final Color flagColor = Color(0xFF000000 | (hashCode & 0xFFFFFF));

    return Container(
      color: flagColor,
      child: Center(
        child: Text(
          countryCode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
