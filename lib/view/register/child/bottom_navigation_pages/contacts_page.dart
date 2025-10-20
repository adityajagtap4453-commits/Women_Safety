import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:women_safety_app/models/contact_model.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/controller/db_services.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchContacts();
    searchController.addListener(filterContact);
  }

  @override
  void dispose() {
    searchController.removeListener(filterContact);
    searchController.dispose();
    super.dispose();
  }

  /// Fetch all contacts with photos
  Future<void> fetchContacts() async {
    setState(() => isLoading = true);
    try {
      final granted = await FlutterContacts.requestPermission();
      debugPrint('Contacts permission granted: $granted');

      if (!granted) {
        setState(() => isLoading = false);
        dialogueBox(context, "Permission denied for contacts");
        return;
      }

      final fetchedContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
        withPhoto: true,
      );

      debugPrint('Fetched ${fetchedContacts.length} contacts');
      for (var i = 0; i < fetchedContacts.length && i < 10; i++) {
        debugPrint('contact[$i] = ${fetchedContacts[i].displayName}');
      }

      setState(() {
        contacts = fetchedContacts;
        contactsFiltered = List<Contact>.from(fetchedContacts);
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching contacts: $e\n$st');
      setState(() => isLoading = false);
      dialogueBox(context, "Failed to load contacts");
    }
  }

  /// Filter contacts by name or phone number (phone numbers are normalized)
  void filterContact() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() => contactsFiltered = List<Contact>.from(contacts));
      return;
    }

    final onlyDigits = query.replaceAll(RegExp(r'\D'), '');
    final hasDigits = onlyDigits.isNotEmpty;

    final temp = contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final nameMatch = name.contains(query);

      bool phoneMatch = false;
      if (hasDigits && contact.phones.isNotEmpty) {
        phoneMatch = contact.phones.any((p) {
          final normalized = p.number.replaceAll(RegExp(r'\D'), '');
          return normalized.contains(onlyDigits);
        });
      }

      return nameMatch || phoneMatch;
    }).toList();

    setState(() => contactsFiltered = temp);
  }

  /// Add contact to local database
  void _addContact(ContactModel newContact) async {
    int result = await databaseHelper.insertContact(newContact);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact added successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add contact")));
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        title: const Text("Contacts", style: TextStyle(color: white)),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search Contact",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: contactsFiltered.isNotEmpty
                        ? ListView.builder(
                            itemCount: contactsFiltered.length,
                            itemBuilder: (context, index) {
                              final contact = contactsFiltered[index];
                              final avatarText = contact.displayName.isNotEmpty
                                  ? contact.displayName[0].toUpperCase()
                                  : '?';
                              return ListTile(
                                leading:
                                    (contact.photo != null &&
                                        contact.photo!.isNotEmpty)
                                    ? CircleAvatar(
                                        backgroundImage: MemoryImage(
                                          contact.photo!,
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: primaryColor,
                                        child: Text(
                                          avatarText,
                                          style: const TextStyle(color: white),
                                        ),
                                      ),
                                title: Text(contact.displayName),
                                subtitle: contact.phones.isNotEmpty
                                    ? Text(contact.phones.first.number)
                                    : const Text('No phone number'),
                                onTap: () {
                                  if (contact.phones.isNotEmpty) {
                                    final String phoneNum =
                                        contact.phones.first.number;
                                    final String name = contact.displayName;
                                    _addContact(ContactModel(phoneNum, name));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "This contact has no phone number",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "No contacts found.\nMake sure your device/emulator has contacts and you've granted permission.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
