import 'package:sembast_web/sembast_web.dart';

Future<Database> openLocalDatabase() =>
    databaseFactoryWeb.openDatabase('my_library_cache');
