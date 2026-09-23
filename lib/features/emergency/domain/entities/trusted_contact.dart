class TrustedContact {
  final String contactId;
  final String ownerId;
  final String name;
  final String phone;
  final String relationship;
  final bool alertsEnabled;
  final DateTime createdAt;

  const TrustedContact({
    required this.contactId,
    required this.ownerId,
    required this.name,
    required this.phone,
    required this.relationship,
    this.alertsEnabled = true,
    required this.createdAt,
  });

  TrustedContact copyWith({
    String? contactId,
    String? ownerId,
    String? name,
    String? phone,
    String? relationship,
    bool? alertsEnabled,
    DateTime? createdAt,
  }) {
    return TrustedContact(
      contactId: contactId ?? this.contactId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
