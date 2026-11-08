import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_studio/app.dart';

void main() {
  testWidgets('File Studio app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FileStudioApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(FileStudioApp), findsOneWidget);
  });
}
