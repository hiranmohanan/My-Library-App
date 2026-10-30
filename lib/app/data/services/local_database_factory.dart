import 'package:sembast/sembast.dart';

import 'local_database_factory_io.dart'
    if (dart.library.js_interop) 'local_database_factory_web.dart'
    as platform;

Future<Database> openLocalDatabase() => platform.openLocalDatabase();
