import 'dart:convert';
import 'dart:io';

/// A small, dependency-free import graph for focused project inspection.
void main(List<String> arguments) {
  if (arguments.length == 2 && arguments.first == 'query') {
    _query(arguments.last);
    return;
  }
  if (arguments.length == 1 && arguments.first == '--update') {
    _update();
    return;
  }
  stderr.writeln('Usage: dart run tool/graphify.dart --update | query <term>');
  exitCode = 64;
}

void _update() {
  final roots = ['lib', 'test'];
  final files = <String>[];
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    files.addAll(
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => _path(file.path))
          .where((path) => path.endsWith('.dart')),
    );
  }
  files.sort();
  final fileSet = files.toSet();
  final imports = <String, List<String>>{};
  final consumers = <String, List<String>>{};
  final directive = RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''');
  for (final file in files) {
    final source = File(file).readAsStringSync();
    final dependencies = <String>{};
    for (final match in directive.allMatches(source)) {
      final target = _resolve(file, match.group(1)!);
      if (target != null && fileSet.contains(target)) dependencies.add(target);
    }
    imports[file] = dependencies.toList()..sort();
    for (final dependency in dependencies) {
      consumers.putIfAbsent(dependency, () => []).add(file);
    }
  }
  for (final list in consumers.values) {
    list.sort();
  }

  final output = Directory('graphify-out')..createSync(recursive: true);
  File('${output.path}/graph.json').writeAsStringSync(
    const JsonEncoder.withIndent(
      '  ',
    ).convert({'files': files, 'imports': imports, 'consumers': consumers}),
  );
  File('${output.path}/report.md').writeAsStringSync(
    '# Graphify report\n\n'
    '${files.length} Dart files, '
    '${imports.values.fold<int>(0, (sum, list) => sum + list.length)} local dependencies.\n\n'
    'Use `dart run tool/graphify.dart query "<term>"` to find files, '
    'their direct dependencies, and consumers.\n',
  );
  final ids = <String, String>{
    for (var index = 0; index < files.length; index++) files[index]: 'n$index',
  };
  final diagram = StringBuffer('graph LR\n');
  for (final file in files) {
    diagram.writeln('  ${ids[file]}["${file.replaceAll('"', '')}"]');
  }
  for (final entry in imports.entries) {
    for (final dependency in entry.value) {
      diagram.writeln('  ${ids[entry.key]} --> ${ids[dependency]}');
    }
  }
  File('${output.path}/graph.mmd').writeAsStringSync(diagram.toString());
  stdout.writeln('Updated graphify-out graph, report, and Mermaid diagram.');
}

void _query(String term) {
  final graph = File('graphify-out/graph.json');
  if (!graph.existsSync()) {
    stderr.writeln('Graph missing. Run --update first.');
    exitCode = 66;
    return;
  }
  final data = jsonDecode(graph.readAsStringSync()) as Map<String, dynamic>;
  final files = (data['files'] as List).cast<String>();
  final imports = (data['imports'] as Map).cast<String, dynamic>();
  final consumers = (data['consumers'] as Map).cast<String, dynamic>();
  final matches = files.where(
    (file) => file.toLowerCase().contains(term.toLowerCase()),
  );
  for (final file in matches) {
    stdout.writeln(file);
    stdout.writeln('  imports: ${(imports[file] as List?)?.join(', ') ?? ''}');
    stdout.writeln(
      '  consumers: ${(consumers[file] as List?)?.join(', ') ?? ''}',
    );
  }
}

String _path(String path) => path.replaceAll('\\', '/');

String? _resolve(String from, String uri) {
  if (uri.startsWith('dart:') ||
      uri.startsWith('package:') &&
          !uri.startsWith('package:my_library_app/')) {
    return null;
  }
  if (uri.startsWith('package:my_library_app/')) {
    return 'lib/${uri.substring('package:my_library_app/'.length)}';
  }
  if (uri.contains(':')) return null;
  final pieces = '${from.substring(0, from.lastIndexOf('/'))}/$uri'.split('/');
  final normalized = <String>[];
  for (final piece in pieces) {
    if (piece == '.') continue;
    if (piece == '..') {
      if (normalized.isNotEmpty) normalized.removeLast();
    } else {
      normalized.add(piece);
    }
  }
  return normalized.join('/');
}
