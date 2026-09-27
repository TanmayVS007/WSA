import 'package:flutter/material.dart';
import '../../domain/entities/phone_contact.dart';
import '../../data/datasources/phone_contacts_service.dart';
import '../../../../core/theme/app_colors.dart';

class DeviceContactPickerSheet extends StatefulWidget {
  final ValueChanged<PhoneContact> onContactSelected;

  const DeviceContactPickerSheet({
    super.key,
    required this.onContactSelected,
  });

  static Future<PhoneContact?> show(BuildContext context) async {
    PhoneContact? selected;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DeviceContactPickerSheet(
        onContactSelected: (contact) {
          selected = contact;
          Navigator.of(ctx).pop();
        },
      ),
    );
    return selected;
  }

  @override
  State<DeviceContactPickerSheet> createState() =>
      _DeviceContactPickerSheetState();
}

class _DeviceContactPickerSheetState extends State<DeviceContactPickerSheet> {
  final PhoneContactsService _contactsService = DefaultPhoneContactsService();
  final TextEditingController _searchController = TextEditingController();
  List<PhoneContact> _allContacts = [];
  List<PhoneContact> _filteredContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _contactsService.getDeviceContacts();
    if (mounted) {
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((c) {
          return c.displayName.toLowerCase().contains(query) ||
              c.phoneNumber.replaceAll(' ', '').contains(query.replaceAll(' ', ''));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: EdgeInsets.only(
        top: 16,
        bottom: bottomInset + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(90),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.contacts_rounded,
                    color: AppColors.primaryPurple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select from Phone Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Import emergency guardian from your device address book',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone number...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DEVICE ADDRESS BOOK (${_filteredContacts.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                if (!_isLoading)
                  const Text(
                    'Tap to select',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contact List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_search_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No contacts found matching "${_searchController.text}"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredContacts.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final initial = contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryPurpleLight,
                              foregroundColor: AppColors.primaryPurple,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  contact.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceDarkElevated
                                        : AppColors.unknownGreyLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    contact.label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primaryPurple,
                            ),
                            onTap: () => widget.onContactSelected(contact),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
