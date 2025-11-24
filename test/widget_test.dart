import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:idleman/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';

void main() {
  group('IdleManApp', () {
    setUp(() async {
      Directory(kTemporaryPath).createSync(recursive: true);
      Directory(kApplicationSupportPath).createSync(recursive: true);
      Directory(kApplicationDocumentsPath).createSync(recursive: true);
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await Hive.initFlutter();
    });

    testWidgets('builds without crashing', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: IdleManApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(IdleManApp), findsOneWidget);
      });
    });
  });
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return null;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return null;
  }
}
