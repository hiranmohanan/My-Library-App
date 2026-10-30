import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/data/datasources/media_local_data_source.dart';
import 'package:my_library_app/app/data/datasources/profile_local_data_source.dart';
import 'package:my_library_app/app/data/services/sembast_local_storage_service.dart';
import 'package:my_library_app/app/theme_controller.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';

void main() {
  test('local cache persists and keeps users separate', () async {
    final directory = await Directory.systemTemp.createTemp(
      'my_library_cache_',
    );
    final databasePath = path.join(directory.path, 'test.db');
    var storage = SembastLocalStorageService(
      await databaseFactoryIo.openDatabase(databasePath),
    );

    try {
      var media = MediaLocalDataSource(storage);
      var profiles = ProfileLocalDataSource(storage);

      await media.save('user-a', 'movie-1', {'title': 'First'});
      await media.save('user-b', 'movie-1', {'title': 'Private'});
      await media.update('user-a', 'movie-1', {'status': 'watched'});
      expect(await media.read('user-a', 'movie-1'), {
        'title': 'First',
        'status': 'watched',
      });
      expect((await media.readAll('user-b')).keys, ['movie-1']);

      await media.replaceAll('user-a', {
        'book-1': {'title': 'New'},
      });
      expect(await media.read('user-a', 'movie-1'), isNull);
      expect(await media.read('user-b', 'movie-1'), {'title': 'Private'});

      await profiles.save('user-a', {'name': 'Alex'});
      await profiles.update('user-a', {'name': 'Alexis'});
      expect(await profiles.read('user-a'), {'name': 'Alexis'});
      expect(await profiles.read('user-b'), isNull);

      final controller = ThemeController(
        persistMode: (mode) =>
            storage.save('preferences', 'theme', {'mode': mode.name}),
      );
      await controller.setMode(ThemeMode.dark);
      await controller.close();
      await storage.close();

      storage = SembastLocalStorageService(
        await databaseFactoryIo.openDatabase(databasePath),
      );
      media = MediaLocalDataSource(storage);
      profiles = ProfileLocalDataSource(storage);
      expect(await media.read('user-a', 'book-1'), {'title': 'New'});
      expect(await profiles.read('user-a'), {'name': 'Alexis'});
      expect(await storage.read('preferences', 'theme'), {'mode': 'dark'});

      await media.delete('user-a', 'book-1');
      await media.clear('user-b');
      await profiles.delete('user-a');
      expect(await media.readAll('user-a'), isEmpty);
      expect(await media.readAll('user-b'), isEmpty);
      expect(await profiles.read('user-a'), isNull);
    } finally {
      await storage.close();
      for (final entry in directory.listSync()) {
        if (entry is File) await entry.delete();
      }
      await directory.delete();
    }
  });
}
