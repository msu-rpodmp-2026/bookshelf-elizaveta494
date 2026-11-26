import 'package:path/path.dart' as p;

void main() {
  final dir = 'data';
  final file = 'library.json';
  final fullPath = p.join(dir, file);

  print('=== Демонстрация функций пакета path ===');
  print('');
  print('p.join("$dir", "$file") => "$fullPath"');
  print('p.basename("$fullPath") => "${p.basename(fullPath)}"');
  print('p.extension("$fullPath") => "${p.extension(fullPath)}"');
  print('p.dirname("$fullPath") => "${p.dirname(fullPath)}"');
  print('p.absolute("$fullPath") => "${p.absolute(fullPath)}"');
}
