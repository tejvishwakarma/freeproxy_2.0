import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/country.dart';
import '../models/proxy.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _countriesCollection =>
      _firestore.collection('countries');

  CollectionReference get _proxiesCollection =>
      _firestore.collection('proxies');

  // Get list of countries that have proxies
  Future<List<Country>> getCountriesWithProxies() async {
    try {
      // Get countries from Firestore
      QuerySnapshot countrySnapshot =
          await _countriesCollection
              .where('proxyCount', isGreaterThan: 0)
              .orderBy('proxyCount', descending: true)
              .get();

      return countrySnapshot.docs
          .map(
            (doc) => Country.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting countries: $e');
      throw e;
    }
  }

  // Get proxies for a specific country
  Future<List<Proxy>> getProxiesByCountry(String countryCode) async {
    try {
      // Get proxies from Firestore
      QuerySnapshot proxySnapshot =
          await _firestore
              .collection('proxies')
              .where('countryCode', isEqualTo: countryCode)
              .where('isActive', isEqualTo: true)
              .get();

      return proxySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Proxy(
          id: doc.id,
          ip: data['ip'] ?? '',
          port: data['port'] ?? '',
          username: data['username'] ?? '',
          password: data['password'] ?? '',
          countryCode: data['countryCode'] ?? '',
          location: data['location'] ?? '',
          isActive: data['isActive'] ?? true,
          createdAt:
              data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error getting proxies: $e');
      throw e;
    }
  }

  // Get all proxies (for admin dashboard)
  Future<List<Proxy>> getAllProxies() async {
    try {
      QuerySnapshot proxySnapshot =
          await _proxiesCollection
              .orderBy('countryCode')
              .orderBy('createdAt', descending: true)
              .get();

      return proxySnapshot.docs
          .map(
            (doc) =>
                Proxy.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error getting all proxies: $e');
      throw e;
    }
  }

  // Add or update a proxy (for admin)
  Future<void> saveProxy(Proxy proxy) async {
    try {
      final data = proxy.toFirestore();

      if (proxy.id.isEmpty) {
        // New proxy - add it
        await _proxiesCollection.add({
          ...data,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Update country proxy count
        await _updateCountryProxyCount(proxy.countryCode);
      } else {
        // Existing proxy - update it
        await _proxiesCollection.doc(proxy.id).update({
          ...data,
          'updatedAt': Timestamp.now(),
        });

        // If country code changed, update counts for both old and new country
        final docSnapshot = await _proxiesCollection.doc(proxy.id).get();
        final oldData = docSnapshot.data() as Map<String, dynamic>;
        final oldCountryCode = oldData['countryCode'];

        if (oldCountryCode != proxy.countryCode) {
          await _updateCountryProxyCount(oldCountryCode);
          await _updateCountryProxyCount(proxy.countryCode);
        } else if (proxy.isActive != oldData['isActive']) {
          // If active status changed, update country count
          await _updateCountryProxyCount(proxy.countryCode);
        }
      }
    } catch (e) {
      print('Error saving proxy: $e');
      throw e;
    }
  }

  // Delete a proxy (for admin)
  Future<void> deleteProxy(Proxy proxy) async {
    try {
      await _proxiesCollection.doc(proxy.id).delete();

      // Update country proxy count
      await _updateCountryProxyCount(proxy.countryCode);
    } catch (e) {
      print('Error deleting proxy: $e');
      throw e;
    }
  }

  // Batch delete multiple proxies (for admin)
  Future<void> batchDeleteProxies(List<Proxy> proxies) async {
    try {
      // Create a set of affected country codes
      final Set<String> affectedCountries = {};

      // Use a batch to delete multiple documents at once
      final batch = _firestore.batch();
      for (final proxy in proxies) {
        batch.delete(_proxiesCollection.doc(proxy.id));
        affectedCountries.add(proxy.countryCode);
      }

      // Commit the batch delete
      await batch.commit();

      // Update proxy counts for all affected countries
      for (final countryCode in affectedCountries) {
        await _updateCountryProxyCount(countryCode);
      }
    } catch (e) {
      print('Error batch deleting proxies: $e');
      throw e;
    }
  }

  // Update country proxy count
  Future<void> _updateCountryProxyCount(String countryCode) async {
    try {
      // Get count of active proxies for this country
      QuerySnapshot proxySnapshot =
          await _proxiesCollection
              .where('countryCode', isEqualTo: countryCode)
              .where('isActive', isEqualTo: true)
              .get();

      int proxyCount = proxySnapshot.docs.length;

      // Find country document
      QuerySnapshot countrySnapshot =
          await _countriesCollection
              .where('code', isEqualTo: countryCode)
              .limit(1)
              .get();

      if (countrySnapshot.docs.isNotEmpty) {
        // Update existing country
        await _countriesCollection.doc(countrySnapshot.docs.first.id).update({
          'proxyCount': proxyCount,
          'updatedAt': Timestamp.now(),
        });
      } else if (proxyCount > 0) {
        // Country doesn't exist but we have proxies - create it
        await _countriesCollection.add({
          'code': countryCode,
          'name': _getCountryName(countryCode),
          'proxyCount': proxyCount,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }
      // If country doesn't exist and proxyCount is 0, no need to create it
    } catch (e) {
      print('Error updating country proxy count: $e');
      throw e;
    }
  }

  // Create or update a country
  Future<void> saveCountry(Country country) async {
    try {
      final data = country.toFirestore();

      if (country.id.isEmpty) {
        // Check if a country with this code already exists
        QuerySnapshot existingCountry =
            await _countriesCollection
                .where('code', isEqualTo: country.code)
                .limit(1)
                .get();

        if (existingCountry.docs.isNotEmpty) {
          // Update existing country
          await _countriesCollection.doc(existingCountry.docs.first.id).update({
            ...data,
            'updatedAt': Timestamp.now(),
          });
        } else {
          // Create new country
          await _countriesCollection.add({
            ...data,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }
      } else {
        // Update existing country by ID
        await _countriesCollection.doc(country.id).update({
          ...data,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error saving country: $e');
      throw e;
    }
  }

  // Get all countries (for admin)
  Future<List<Country>> getAllCountries() async {
    try {
      QuerySnapshot countrySnapshot =
          await _countriesCollection.orderBy('name').get();

      return countrySnapshot.docs
          .map(
            (doc) => Country.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting all countries: $e');
      throw e;
    }
  }

  // Search proxies by IP, location, or country code
  Future<List<Proxy>> searchProxies(String searchTerm) async {
    try {
      // Convert to lowercase for case-insensitive search
      final term = searchTerm.toLowerCase();

      // Get all proxies (Firestore doesn't support text search directly)
      QuerySnapshot proxySnapshot = await _proxiesCollection.get();

      // Filter in memory
      return proxySnapshot.docs
          .map(
            (doc) =>
                Proxy.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
          )
          .where(
            (proxy) =>
                proxy.ip.toLowerCase().contains(term) ||
                proxy.location.toLowerCase().contains(term) ||
                proxy.countryCode.toLowerCase().contains(term),
          )
          .toList();
    } catch (e) {
      print('Error searching proxies: $e');
      throw e;
    }
  }

  // Helper to get country name from code
  String _getCountryName(String code) {
    Map<String, String> countryCodes = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'JP': 'Japan',
      'CN': 'China',
      'IN': 'India',
      'BR': 'Brazil',
      'RU': 'Russia',
      'MX': 'Mexico',
      'NL': 'Netherlands',
      'SG': 'Singapore',
      'SE': 'Sweden',
      'CH': 'Switzerland',
      'NO': 'Norway',
      'FI': 'Finland',
      'DK': 'Denmark',
      'IE': 'Ireland',
      'NZ': 'New Zealand',
      'ZA': 'South Africa',
      'AE': 'United Arab Emirates',
    };

    return countryCodes[code] ?? 'Unknown Country';
  }

  // Initialize database with sample data (for development)
  Future<void> initializeSampleData() async {
    try {
      // Check if we already have data
      QuerySnapshot existingProxies = await _proxiesCollection.limit(1).get();
      if (existingProxies.docs.isNotEmpty) {
        return; // Data already exists
      }

      // Sample countries and their proxies
      final sampleProxies = [
        {
          'countryCode': 'US',
          'ip': '192.168.1.100',
          'port': '8080',
          'username': 'user_us1',
          'password': 'pass_us1',
          'location': 'New York',
          'isActive': true,
        },
        {
          'countryCode': 'US',
          'ip': '192.168.1.101',
          'port': '8080',
          'username': 'user_us2',
          'password': 'pass_us2',
          'location': 'Los Angeles',
          'isActive': true,
        },
        {
          'countryCode': 'GB',
          'ip': '192.168.2.100',
          'port': '3128',
          'username': 'user_gb1',
          'password': 'pass_gb1',
          'location': 'London',
          'isActive': true,
        },
        {
          'countryCode': 'DE',
          'ip': '192.168.3.100',
          'port': '8080',
          'username': 'user_de1',
          'password': 'pass_de1',
          'location': 'Berlin',
          'isActive': true,
        },
      ];

      // Add sample proxies
      for (final proxyData in sampleProxies) {
        await _proxiesCollection.add({
          ...proxyData,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }

      // Update country counts
      final countryCodesSet =
          sampleProxies.map((proxy) => proxy['countryCode'] as String).toSet();

      for (final code in countryCodesSet) {
        await _updateCountryProxyCount(code);
      }
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }
}
