import 'package:flutter/material.dart';
import '../../domain/entities/business_card_info.dart';
import '../../domain/entities/card_ocr_result.dart';
import '../../domain/entities/ocr_language_mode.dart';

export '../../domain/entities/ocr_language_mode.dart';

enum CardSide { front, back }

class ScanState {
  final CardSide currentSide;
  final OcrLanguageMode ocrLanguageMode; // Chế độ ngôn ngữ OCR (Auto / VN / JP)
  final String? frontImagePath;
  final String? backImagePath;
  final String? currentImagePath; // Ảnh hiện tại đang hiển thị trên màn 2b để căn chỉnh
  final String? lastProcessedImagePath; // Ảnh sau khi xoay & crop dùng cho OCR
  final int? imageWidth; // Chiều rộng ảnh gốc
  final int? imageHeight; // Chiều cao ảnh gốc
  final int rotationAngle; // 0, 90, 180, 270
  final List<Offset> cornerPoints; // 4 góc chuẩn hóa [0.0 -> 1.0] (TL, TR, BR, BL)
  final bool isProcessing;
  final String? errorMessage;
  final bool isFlashOn;

  // OCR state
  final CardOcrResult? frontOcrResult;
  final CardOcrResult? backOcrResult;
  final BusinessCardInfo? currentCardInfo; // Thông tin danh thiếp đã bóc tách tự động
  final bool isOcrLoading;
  final String? ocrErrorMessage;

  const ScanState({
    this.currentSide = CardSide.front,
    this.ocrLanguageMode = OcrLanguageMode.auto,
    this.frontImagePath,
    this.backImagePath,
    this.currentImagePath,
    this.lastProcessedImagePath,
    this.imageWidth,
    this.imageHeight,
    this.rotationAngle = 0,
    this.cornerPoints = const [
      Offset(0.05, 0.08), // Top-Left
      Offset(0.95, 0.08), // Top-Right
      Offset(0.95, 0.92), // Bottom-Right
      Offset(0.05, 0.92), // Bottom-Left
    ],
    this.isProcessing = false,
    this.errorMessage,
    this.isFlashOn = false,
    this.frontOcrResult,
    this.backOcrResult,
    this.currentCardInfo,
    this.isOcrLoading = false,
    this.ocrErrorMessage,
  });

  bool get hasBothSides => frontImagePath != null && backImagePath != null;
  bool get hasFrontImage => frontImagePath != null;
  bool get hasBackImage => backImagePath != null;

  CardOcrResult? get currentOcrResult =>
      currentSide == CardSide.front ? frontOcrResult : backOcrResult;

  ScanState copyWith({
    CardSide? currentSide,
    OcrLanguageMode? ocrLanguageMode,
    String? frontImagePath,
    String? backImagePath,
    String? currentImagePath,
    String? lastProcessedImagePath,
    int? imageWidth,
    int? imageHeight,
    int? rotationAngle,
    List<Offset>? cornerPoints,
    bool? isProcessing,
    String? errorMessage,
    bool? isFlashOn,
    CardOcrResult? frontOcrResult,
    CardOcrResult? backOcrResult,
    BusinessCardInfo? currentCardInfo,
    bool? isOcrLoading,
    String? ocrErrorMessage,
  }) {
    return ScanState(
      currentSide: currentSide ?? this.currentSide,
      ocrLanguageMode: ocrLanguageMode ?? this.ocrLanguageMode,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      currentImagePath: currentImagePath ?? this.currentImagePath,
      lastProcessedImagePath: lastProcessedImagePath ?? this.lastProcessedImagePath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      cornerPoints: cornerPoints ?? this.cornerPoints,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      frontOcrResult: frontOcrResult ?? this.frontOcrResult,
      backOcrResult: backOcrResult ?? this.backOcrResult,
      currentCardInfo: currentCardInfo ?? this.currentCardInfo,
      isOcrLoading: isOcrLoading ?? this.isOcrLoading,
      ocrErrorMessage: ocrErrorMessage,
    );
  }
}
