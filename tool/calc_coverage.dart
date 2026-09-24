// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found');
    return;
  }
  final lines = file.readAsLinesSync();
  int lf = 0;
  int lh = 0;
  for (final line in lines) {
    if (line.startsWith('LF:')) {
      lf += int.parse(line.substring(3).trim());
    } else if (line.startsWith('LH:')) {
      lh += int.parse(line.substring(3).trim());
    }
  }
  final pct = lf > 0 ? (lh / lf * 100) : 0.0;
  print('=== COVERAGE REPORT ===');
  print('Lines Found (LF): $lf');
  print('Lines Hit   (LH): $lh');
  print('Line Coverage: ${pct.toStringAsFixed(2)}%');
}
