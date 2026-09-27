import '../../domain/entities/phone_contact.dart';

abstract class PhoneContactsService {
  Future<List<PhoneContact>> getDeviceContacts({String? query});
  Future<bool> hasPermission();
  Future<bool> requestPermission();
}

class DefaultPhoneContactsService implements PhoneContactsService {
  
  final List<PhoneContact> _contacts = [
    const PhoneContact(
      id: 'dev_c_01',
      displayName: 'Sunita Sharma (Mom)',
      phoneNumber: '+91 98765 43211',
      email: 'sunita.sharma@gmail.com',
      label: 'Family',
    ),
    const PhoneContact(
      id: 'dev_c_02',
      displayName: 'Rajesh Sharma (Dad)',
      phoneNumber: '+91 98765 43212',
      email: 'rajesh.sharma@gmail.com',
      label: 'Family',
    ),
    const PhoneContact(
      id: 'dev_c_03',
      displayName: 'Riya Sharma (Sister)',
      phoneNumber: '+91 98765 43219',
      email: 'riya.sharma@outlook.com',
      label: 'Sister',
    ),
    const PhoneContact(
      id: 'dev_c_04',
      displayName: 'Dr. Aditi Mehra (Doctor)',
      phoneNumber: '+91 98220 12345',
      email: 'dr.aditi@cliniccare.in',
      label: 'Doctor',
    ),
    const PhoneContact(
      id: 'dev_c_05',
      displayName: 'Pooja Verma (Roommate)',
      phoneNumber: '+91 98111 88990',
      email: 'pooja.verma@college.edu',
      label: 'Friend',
    ),
    const PhoneContact(
      id: 'dev_c_06',
      displayName: 'Vikram Joshi (Brother)',
      phoneNumber: '+91 98450 55443',
      email: 'vikram.j@techcorp.com',
      label: 'Brother',
    ),
    const PhoneContact(
      id: 'dev_c_07',
      displayName: 'Aunt Kavita',
      phoneNumber: '+91 98230 77881',
      email: 'kavita.m@gmail.com',
      label: 'Guardian',
    ),
    const PhoneContact(
      id: 'dev_c_08',
      displayName: 'Rohan Mehra (Best Friend)',
      phoneNumber: '+91 98765 99887',
      email: 'rohan.mehra@gmail.com',
      label: 'Friend',
    ),
    const PhoneContact(
      id: 'dev_c_09',
      displayName: 'Local Police Helpline / PCR',
      phoneNumber: '112',
      email: null,
      label: 'Emergency Police',
    ),
    const PhoneContact(
      id: 'dev_c_10',
      displayName: 'National Women Helpline',
      phoneNumber: '1091',
      email: null,
      label: 'Helpline',
    ),
  ];

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<List<PhoneContact>> getDeviceContacts({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 250)); // simulate brief disk/platform read

    if (query == null || query.trim().isEmpty) {
      return List.unmodifiable(_contacts);
    }

    final lower = query.trim().toLowerCase();
    return _contacts.where((c) {
      return c.displayName.toLowerCase().contains(lower) ||
          c.phoneNumber.replaceAll(' ', '').contains(lower.replaceAll(' ', ''));
    }).toList();
  }
}
