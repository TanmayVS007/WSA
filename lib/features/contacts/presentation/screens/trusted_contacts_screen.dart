import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../emergency/domain/entities/trusted_contact.dart';
import '../../domain/entities/phone_contact.dart';
import '../widgets/device_contact_picker_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_bottom_nav.dart';
import '../../../../core/widgets/aegis_top_bar.dart';

// State Provider for Trusted Contacts
final trustedContactsProvider =
    NotifierProvider<TrustedContactsNotifier, List<TrustedContact>>(
        TrustedContactsNotifier.new);

class TrustedContactsNotifier extends Notifier<List<TrustedContact>> {
  @override
  List<TrustedContact> build() {
    return [
      // TrustedContact(
      //   contactId: 'tc_01',
      //   ownerId: 'usr_owner_demo',
      //   name: 'Sunita Sharma',
      //   phone: '+91 98230 XXXXX',
      //   relationship: 'Mother',
      //   alertsEnabled: true,
      //   createdAt: DateTime(2026, 8, 1),
      // ),
      // TrustedContact(
      //   contactId: 'tc_02',
      //   ownerId: 'usr_owner_demo',
      //   name: 'Rajesh Sharma',
      //   phone: '+91 98221 XXXXX',
      //   relationship: 'Father',
      //   alertsEnabled: true,
      //   createdAt: DateTime(2026, 8, 1),
      // ),
      // TrustedContact(
      //   contactId: 'tc_03',
      //   ownerId: 'usr_owner_demo',
      //   name: 'Priya Patel',
      //   phone: '+91 98212 XXXXX',
      //   relationship: 'Sister',
      //   alertsEnabled: true,
      //   createdAt: DateTime(2026, 8, 10),
      // ),
    ];
  }

  void toggleAlerts(String contactId) {
    state = state.map((c) {
      if (c.contactId == contactId) {
        return c.copyWith(alertsEnabled: !c.alertsEnabled);
      }
      return c;
    }).toList();
  }

  void addContact(String name, String phone, String relationship) {
    final newContact = TrustedContact(
      contactId: 'tc_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: 'usr_owner_demo',
      name: name,
      phone: phone,
      relationship: relationship,
      alertsEnabled: true,
      createdAt: DateTime.now(),
    );
    state = [...state, newContact];
  }

  void deleteContact(String contactId) {
    state = state.where((c) => c.contactId != contactId).toList();
  }
}

class TrustedContactsScreen extends ConsumerWidget {
  const TrustedContactsScreen({super.key});

  void _showAddContactDialog(
    BuildContext context,
    WidgetRef ref, {
    PhoneContact? initialContact,
  }) {
    final nameCtrl = TextEditingController(text: initialContact?.displayName ?? '');
    final phoneCtrl = TextEditingController(text: initialContact?.phoneNumber ?? '');
    final relationCtrl = TextEditingController(
      text: (initialContact?.label.isNotEmpty == true && initialContact?.label != 'Mobile')
          ? initialContact!.label
          : 'Family',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Trusted Guardian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Trusted contacts receive immediate SMS and push notifications with live GPS during emergency events.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // Option: Pick from Phone Contacts
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final picked = await DeviceContactPickerSheet.show(context);
                  if (picked != null) {
                    nameCtrl.text = picked.displayName;
                    phoneCtrl.text = picked.phoneNumber;
                    if (picked.label.isNotEmpty && picked.label != 'Mobile') {
                      relationCtrl.text = picked.label;
                    }
                  }
                },
                icon: const Icon(Icons.contacts_rounded, size: 18),
                label: const Text(
                  'Choose from Phone Contacts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR EDIT / ENTER DETAILS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationCtrl,
              decoration: const InputDecoration(
                labelText: 'Relationship (e.g. Mother, Sister)',
                prefixIcon: Icon(Icons.favorite_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                    ref.read(trustedContactsProvider.notifier).addContact(
                          nameCtrl.text.trim(),
                          phoneCtrl.text.trim(),
                          relationCtrl.text.trim(),
                        );
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Save Guardian', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(trustedContactsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AegisTopBar(
        title: 'Trusted Circle',
        showBackButton: true,
      ),
      bottomNavigationBar: const AegisBottomNav(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Protective Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B1C30).withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.security_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Emergency Circle',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiaryFixed.withAlpha(80),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${contacts.length} Active Guardians',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onTertiaryFixedVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, size: 14, color: AppColors.tertiary),
                              SizedBox(width: 4),
                              Text(
                                'Armed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'These contacts immediately receive live location tracking, SMS coordinates, and high-priority call notifications when SOS is pressed or unusual motion is detected.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Priority Contact Roster Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRIORITY CONTACT ROSTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.swap_vert_rounded, size: 15, color: AppColors.primary),
                      SizedBox(width: 2),
                      Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. Contact Cards List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contacts.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final accentColor = index == 0
                      ? AppColors.primary
                      : index == 1
                          ? AppColors.secondarySlate
                          : AppColors.tertiary;

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1C30).withAlpha(8),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left color accent bar
                          Container(
                            width: 5,
                            color: accentColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: accentColor.withAlpha(30),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    contact.name[0],
                                                    style: TextStyle(
                                                      color: accentColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: -2,
                                                right: -2,
                                                child: Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    color: accentColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white, width: 1.5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '#${index + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    contact.name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? AppColors.surfaceDarkElevated
                                                          : AppColors.surfaceContainerLow,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      contact.relationship,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: isDark
                                                            ? AppColors.textSecondaryDark
                                                            : AppColors.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.call_rounded, size: 12, color: AppColors.outline),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    contact.phone,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? AppColors.textSecondaryDark
                                                          : AppColors.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.outline),
                                        onSelected: (val) {
                                          if (val == 'delete') {
                                            ref.read(trustedContactsProvider.notifier).deleteContact(contact.contactId);
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, color: AppColors.emergencyRed, size: 18),
                                                SizedBox(width: 8),
                                                Text('Delete Contact', style: TextStyle(color: AppColors.emergencyRed)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Alert Rule Row with Switch
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.surfaceDarkElevated
                                          : AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              index == 0
                                                  ? Icons.crisis_alert_rounded
                                                  : Icons.notifications_active_rounded,
                                              size: 16,
                                              color: contact.alertsEnabled
                                                  ? AppColors.tertiary
                                                  : AppColors.outline,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  index == 0
                                                      ? 'All SOS + Fall Detection'
                                                      : 'All SOS Signals',
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  index == 0
                                                      ? 'Instant ringtone override active'
                                                      : 'SMS + High Priority Notification',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: contact.alertsEnabled
                                                        ? AppColors.tertiary
                                                        : AppColors.outline,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Switch.adaptive(
                                          value: contact.alertsEnabled,
                                          activeTrackColor: AppColors.primary,
                                          onChanged: (val) {
                                            ref
                                                .read(trustedContactsProvider.notifier)
                                                .toggleAlerts(contact.contactId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Action Buttons: Test Signal & Call Now
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 38,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDark
                                                  ? AppColors.surfaceDarkElevated
                                                  : AppColors.surfaceContainerLow,
                                              foregroundColor: AppColors.primary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Test ping dispatched to ${contact.name} via Bluetooth BLE & SMS relay.'),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.sensors_rounded, size: 15),
                                            label: const Text('Test Signal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SizedBox(
                                          height: 38,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Calling ${contact.name} (${contact.phone})...')),
                                              );
                                            },
                                            icon: const Icon(Icons.phone_forwarded_rounded, size: 15),
                                            label: const Text('Call Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 4. Contact Addition Actions
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final picked =
                              await DeviceContactPickerSheet.show(context);
                          if (picked != null && context.mounted) {
                            _showAddContactDialog(context, ref, initialContact: picked);
                          }
                        },
                        icon: const Icon(Icons.contacts_rounded, size: 18),
                        label: const Text(
                          'From Phone Contacts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _showAddContactDialog(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Manual',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
