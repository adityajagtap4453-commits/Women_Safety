import 'package:flutter/material.dart';
import 'package:women_safety_app/controller/db_services.dart';
import 'package:women_safety_app/models/contact_model.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/contacts_page.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:women_safety_app/widgets/primary_button.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  DatabaseHelper databasehelper = DatabaseHelper();
  List<ContactModel>? contactList;
  int count = 0;

  void showList() {
    Future<Database> dbFuture = databasehelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<ContactModel>> contactListFuture = databasehelper
          .getContactModelList();
      contactListFuture.then((value) {
        setState(() {
          contactList = value;
          count = value.length;
        });
      });
    });
  }

  void deleteContact(ContactModel contact) async {
    int result = await databasehelper.deleteContact(contact.id);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("contact removed succesfully")),
      );
      showList();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showList();
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (contactList == null) {contactList = [];}
    //replace this line by below line
    contactList ??= [];
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(contactList![index].name),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                    contactList![index].number,
                                  );
                                },
                                icon: Icon(Icons.call, color: red),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteContact(contactList![index]);
                                },
                                icon: Icon(Icons.delete, color: red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            PrimaryButton(
              title: "Add Trusted Contacts",
              onPressed: () async {
                bool result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactsPage()),
                );
                if (result == true) {
                  showList();
                }
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
