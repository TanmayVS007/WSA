class PhoneContact {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String? email;
  final String label;

  const PhoneContact({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    this.email,
    this.label = 'Mobile',
  });
}
