import 'package:app_scanner_card/features/scan/domain/entities/card_ocr_result.dart';
import 'package:app_scanner_card/features/scan/domain/repositories/ocr_repository.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:app_scanner_card/features/scan/presentation/cubit/scan_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MockOcrRepository implements OcrRepository {
  bool disposed = false;
  CardOcrResult? mockResult;

  @override
  Future<CardOcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.japanese,
  }) async {
    return mockResult ??
        const CardOcrResult(
          fullText: '山田 太郎\nテスト株式会社',
          imageWidth: 800,
          imageHeight: 500,
          blocks: [],
        );
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanCubit OCR Tests', () {
    test('processOcr without image returns null and sets error', () async {
      final mockRepo = MockOcrRepository();
      final cubit = ScanCubit(ocrRepository: mockRepo);

      final result = await cubit.processOcr();

      expect(result, isNull);
      expect(cubit.state.ocrErrorMessage, isNotNull);
      expect(cubit.state.isOcrLoading, isFalse);

      await cubit.close();
      expect(mockRepo.disposed, isTrue);
    });

    test('setSide changes currentSide and reset restores state', () async {
      final mockRepo = MockOcrRepository();
      final cubit = ScanCubit(ocrRepository: mockRepo);

      cubit.setSide(CardSide.back);
      expect(cubit.state.currentSide, equals(CardSide.back));

      cubit.reset();
      expect(cubit.state.currentSide, equals(CardSide.front));
      expect(cubit.state.frontImagePath, isNull);

      await cubit.close();
    });
  });
}
