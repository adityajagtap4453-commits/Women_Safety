import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:women_safety_app/models/contact_model.dart';

class DatabaseHelper {
  String contactTable = 'contact_table';
  String colId = 'id';
  String colContactName = 'name';
  String colContactNumber = 'number';

  // named private constructor..(used to create an instance of a singleton class)
  // it will be used to create an instance of the DatabaseHelper class
  DatabaseHelper._createInstance();

  //Now lets create an instance of the database
  static DatabaseHelper? _databaseHelper; // this _databaseHelper will
  //be referenced using 'this' keyword. It helps to access getters and
  //setters of the class. for example: _database getter is used when we
  //want to initialize the db.
  factory DatabaseHelper() {
    //factory keyword allows the constructor to return some value
    //create an instance of _DatabaseHelper iff there is no instance created before
    //because of that null check this line above runs once only
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  // lets initialize the database
  static Database? _database;
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Database contactDatabase = await openDatabase(
      join(await getDatabasesPath(), "ContactDb.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $contactTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colContactName TEXT, $colContactNumber TEXT)',
        );
      },
    );
    return contactDatabase;
  }

  // Fetch Operation: get contact object from db
  Future<List<Map<String, dynamic>>> getContactMapList() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM $contactTable order by $colId ASC',
    );

    // or
    // var result = await db.query(contactTable, orderBy: '$colId ASC');
    return result;
  }

  //Insert a contact object
  Future<int> insertContact(ContactModel contact) async {
    Database db = await database;
    var result = await db.insert(contactTable, contact.toMap());
    // print(await db.query(contactTable));
    return result;
  }

  // update a contact object
  Future<int> updateContact(ContactModel contact) async {
    Database db = await database;
    var result = await db.update(
      contactTable,
      contact.toMap(),
      where: '$colId = ?',
      whereArgs: [contact.id],
    );
    return result;
  }

  //delete a contact object
  Future<int> deleteContact(int id) async {
    Database db = await database;
    int result = await db.rawDelete(
      'DELETE FROM $contactTable WHERE $colId = $id',
    );
    // print(await db.query(contactTable));
    return result;
  }

  //get number of contact objects
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery(
      'SELECT COUNT (*) from $contactTable',
    );
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Contact List' [ List<Contact> ]
  Future<List<ContactModel>> getContactModelList() async {
    var contactMapList =
        await getContactMapList(); // Get 'Map List' from database
    int count =
        contactMapList.length; // Count the number of map entries in db table

    List<ContactModel> contactList = <ContactModel>[];
    // For loop to create a 'Contact List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      contactList.add(ContactModel.fromMapObject(contactMapList[i]));
    }

    return contactList;
  }
}
