import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openLocalDatabase() async {
  final directory = await getApplicationSupportDirectory();
  final databasePath = path.join(directory.path, 'my_library_cache.db');
  return databaseFactoryIo.openDatabase(databasePath);
}
