import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_band/features/contacts/data/datasources/phone_contacts_service.dart';

void main() {
  group('PhoneContactsService Tests', () {
    late DefaultPhoneContactsService service;

    setUp(() {
      service = DefaultPhoneContactsService();
    });

    test('getDeviceContacts returns all available device address book contacts', () async {
      final contacts = await service.getDeviceContacts();
      expect(contacts.isNotEmpty, true);
      expect(contacts.length, greaterThanOrEqualTo(8));
      expect(contacts.any((c) => c.displayName.contains('Mom')), true);
      expect(contacts.any((c) => c.displayName.contains('Dad')), true);
    });

    test('getDeviceContacts filters contacts accurately by name query', () async {
      final filtered = await service.getDeviceContacts(query: 'Sharma');
      expect(filtered.isNotEmpty, true);
      for (final c in filtered) {
        expect(c.displayName.toLowerCase().contains('sharma'), true);
      }
    });

    test('getDeviceContacts filters contacts accurately by phone number', () async {
      final filtered = await service.getDeviceContacts(query: '112');
      expect(filtered.length, 1);
      expect(filtered.first.displayName, contains('Police'));
    });

    test('hasPermission returns true', () async {
      final hasPerm = await service.hasPermission();
      expect(hasPerm, true);
    });
  });
}
