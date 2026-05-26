import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TetrisApp());
    expect(find.text('TETRIS'), findsAny);
  });
}
