// import 'package:moor/ffi.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:moor/moor.dart';
// import 'dart:io';
//
// // assuming that your file is called filename.dart. This will give an error at first,
// // but it's needed for moor to know about the generated code
// part 'filename.g.dart';
//
// // this will generate a table called "todos" for us. The rows of that table will
// // be represented by a class called "Todo".
// class Todos extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().withLength(min: 6, max: 32)();
//   TextColumn get content => text().named('body')();
//   IntColumn get category => integer().nullable()();
// }
//
// class Users extends Table {
//   TextColumn get email => text()();
//   TextColumn get name => text()();
//
//   @override
//   Set<Column> get primaryKey => {email};
// }
//
//
// // This will make moor generate a class called "Category" to represent a row in this table.
// // By default, "Categorie" would have been used because it only strips away the trailing "s"
// // in the table name.
// @DataClassName("Category")
// class Categories extends Table {
//
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get description => text()();
// }
//
// LazyDatabase _openConnection() {
//   // the LazyDatabase util lets us find the right location for the file async.
//   return LazyDatabase(() async {
//     // put the database file, called db.sqlite here, into the documents folder
//     // for your app.
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'db.sqlite'));
//     return VmDatabase(file);
//   });
// }
//
// @UseMoor(tables: [Todos, Categories, Users])
// class MyDatabase extends _$MyDatabase {
//   // we tell the database where to store the data with this constructor
//   // MyDatabase() : super(_openConnection());
//   MyDatabase(QueryExecutor e) : super(e);
//
//   // you should bump this number whenever you change or add a table definition. Migrations
//   // are covered later in this readme.
//   @override
//   int get schemaVersion => 1;
//
//   // // loads all todo entries
//   Future<List<Todo>> get allTodoEntries => select(todos).get();
//   //
//   // // watches all todo entries in a given category. The stream will automatically
//   // // emit new items whenever the underlying data changes.
//   Stream<List<Todo>> watchEntriesInCategory(Category c) {
//     return (select(todos)
//       ..where((t) => t.category.equals(c.id))).watch();
//   }
//
//   Future<List<Todo>> limitTodos(int limit, {int offset}) {
//     return (select(todos)..limit(limit, offset: offset)).get();
//   }
//
//   Future<List<Todo>> sortEntriesAlphabetically() {
//     return (select(todos)..orderBy([(t) => OrderingTerm(expression: t.title)])).get();
//   }
//
//   Stream<Todo> entryById(int id) {
//     return (select(todos)..where((t) => t.id.equals(id))).watchSingle();
//   }
//
//   Stream<List<String>> contentWithLongTitles() {
//     final query = select(todos)
//       ..where((t) => t.title.length.isBiggerOrEqualValue(16));
//
//     return query
//         .map((row) => row.content)
//         .watch();
//   }
//
//   // returns the generated id
//   Future<int> addTodo(TodosCompanion entry) {
//     return into(todos).insert(entry);
//   }
//
//   Future moveImportantTasksIntoCategory(Category target) {
//     // for updates, we use the "companion" version of a generated class. This wraps the
//     // fields in a "Value" type which can be set to be absent using "Value.absent()". This
//     // allows us to separate between "SET category = NULL" (`category: Value(null)`) and not
//     // updating the category at all: `category: Value.absent()`.
//     return (update(todos)
//       ..where((t) => t.title.like('%Important%'))
//     ).write(TodosCompanion(
//       category: Value(target.id),
//     ),
//     );
//   }
//
//   Future updateT(Todo entry) {
//     // using replace will update all fields from the entry that are not marked as a primary key.
//     // it will also make sure that only the entry with the same primary key will be updated.
//     // Here, this means that the row that has the same id as entry will be updated to reflect
//     // the entry's title, content and category. As its where clause is set automatically, it
//     // cannot be used together with where.
//     return update(todos).replace(entry);
//   }
//
//   Future feelingLazy() {
//     // delete the oldest nine tasks
//     return (delete(todos)..where((t) => t.id.isSmallerThanValue(10))).go();
//   }
//
//   Future<void> insertMultipleEntries() async{
//     await batch((batch) {
//       // functions in a batch don't have to be awaited - just
//       // await the whole batch afterwards.
//       batch.insertAll(todos, [
//         TodosCompanion.insert(
//           title: 'First entry',
//           content: 'My content',
//         ),
//         TodosCompanion.insert(
//           title: 'Another entry',
//           content: 'More content',
//           // columns that aren't required for inserts are still wrapped in a Value:
//           category: Value(3),
//         ),
//         // ...
//       ]);
//     });
//   }
//
//   Future<void> createOrUpdateUser(User user) {
//     return into(users).insertOnConflictUpdate(user);
//   }
//
//   Future<int> createUser(String name) {
//     return into(users).insert(UsersCompanion.insert(name: name));
//   }
//
//   /// Changes the name of a user with the [id] to the [newName].
//   Future<void> updateName(int id, String newName) {
//     return update(users).replace(User(id: id, name: newName));
//   }
//
//   Stream<User> watchUserWithId(int id) {
//     return (select(users)..where((u) => u.id.equals(id))).watchSingle();
//   }
//
// }

import 'package:moor/moor.dart';

part 'filename.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@UseMoor(tables: [Users])
class MyDatabase extends _$MyDatabase {
  MyDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  /// Creates a user and returns their id
  Future<int> createUser(String name) {
    return into(users).insert(UsersCompanion.insert(name: name));
  }

  /// Changes the name of a user with the [id] to the [newName].
  Future<void> updateName(int id, String newName) {
    return update(users).replace(User(id: id, name: newName));
  }

  Stream<User> watchUserWithId(int id) {
    return (select(users)..where((u) => u.id.equals(id))).watchSingle();
  }
}