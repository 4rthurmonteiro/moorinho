import 'package:flutter_test/flutter_test.dart';
import 'package:moor/ffi.dart';
import 'package:moor_getting_started/filename.dart';
// the file defined above, you can test any moor database of course

void main() {
  MyDatabase database;

  setUp(() {
    database = MyDatabase(VmDatabase.memory(logStatements: true));
  });
  tearDown(() async {
    await database.close();
  });

  test('users can be created', () async {
    final id = await database.createUser('some user');
    final user = await database.watchUserWithId(id).first;

    expect(user.name, 'some user');
  });

  test('stream emits a new user when the name updates', () async {
    final id = await database.createUser('first name');

    final expectation = expectLater(
      database.watchUserWithId(id).map((user) => user.name),
      emitsInOrder(['first name', 'changed name']),
    );

    await database.updateName(id, 'changed name');
    await expectation;
  });
}