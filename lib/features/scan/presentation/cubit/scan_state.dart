import 'package:flutter/material.dart';
import '../../domain/entities/business_card_info.dart';
import '../../domain/entities/card_ocr_result.dart';

export '../../domain/entities/ocr_language_mode.dart';

enum CardSide { front, back }

/// 4 góc mặc định của khung crop (chuẩn hoá 0..1, thứ tự TL, TR, BR, BL)
const List<Offset> kDefaultCropCorners = [
  Offset(0.05, 0.08), // Top-Left
  Offset(0.95, 0.08), // Top-Right
  Offset(0.95, 0.92), // Bottom-Right
  Offset(0.05, 0.92), // Bottom-Left
];

/// Thông số căn chỉnh (4 góc + góc xoay + kích thước ảnh) của một mặt thẻ.
class SideCrop {
  final List<Offset> cornerPoints;
  final int rotationAngle;
  final int? imageWidth;
  final int? imageHeight;

  const SideCrop({
    this.cornerPoints = kDefaultCropCorners,
    this.rotationAngle = 0,
    this.imageWidth,
    this.imageHeight,
  });
}

class ScanState {
  final CardSide currentSide;
  final String? frontImagePath;
  final String? backImagePath;
  final String? currentImagePath; // Ảnh hiện tại đang hiển thị trên màn 2b để căn chỉnh
  final int? imageWidth; // Chiều rộng ảnh gốc
  final int? imageHeight; // Chiều cao ảnh gốc

  /// Căn chỉnh của MẶT HIỆN TẠI (màn crop thao tác trực tiếp trên 2 trường này)
  final int rotationAngle; // 0, 90, 180, 270
  final List<Offset> cornerPoints; // 4 góc chuẩn hóa [0.0 -> 1.0] (TL, TR, BR, BL)

  /// Căn chỉnh đã lưu của từng mặt (được ghi lại khi chuyển mặt)
  final SideCrop? frontCrop;
  final SideCrop? backCrop;

  final bool isProcessing;
  final String? errorMessage;
  final bool isFlashOn;

  // OCR state
  final CardOcrResult? frontOcrResult;
  final CardOcrResult? backOcrResult;

  /// Ảnh đã crop + tiền xử lý dùng cho OCR của từng mặt
  final String? frontProcessedImagePath;
  final String? backProcessedImagePath;

  final BusinessCardInfo? currentCardInfo; // Thông tin danh thiếp đã bóc tách (đã gộp 2 mặt)
  final bool isOcrLoading;
  final String? ocrErrorMessage;

  /// Tiến độ OCR nhiều mặt: mặt đang xử lý, thứ tự (1-based) và tổng số mặt
  final CardSide? ocrSideInProgress;
  final int ocrSideIndex;
  final int ocrSidesTotal;

  /// Các mặt OCR thất bại ở lần nhận dạng gần nhất (các mặt còn lại vẫn thành công)
  final List<CardSide> ocrFailedSides;

  const ScanState({
    this.currentSide = CardSide.front,
    this.frontImagePath,
    this.backImagePath,
    this.currentImagePath,
    this.imageWidth,
    this.imageHeight,
    this.rotationAngle = 0,
    this.cornerPoints = kDefaultCropCorners,
    this.frontCrop,
    this.backCrop,
    this.isProcessing = false,
    this.errorMessage,
    this.isFlashOn = false,
    this.frontOcrResult,
    this.backOcrResult,
    this.frontProcessedImagePath,
    this.backProcessedImagePath,
    this.currentCardInfo,
    this.isOcrLoading = false,
    this.ocrErrorMessage,
    this.ocrSideInProgress,
    this.ocrSideIndex = 0,
    this.ocrSidesTotal = 0,
    this.ocrFailedSides = const [],
  });

  bool get hasBothSides => frontImagePath != null && backImagePath != null;
  bool get hasFrontImage => frontImagePath != null;
  bool get hasBackImage => backImagePath != null;

  CardOcrResult? get currentOcrResult => ocrResultFor(currentSide);

  CardOcrResult? ocrResultFor(CardSide side) =>
      side == CardSide.front ? frontOcrResult : backOcrResult;

  String? imagePathFor(CardSide side) => side == CardSide.front ? frontImagePath : backImagePath;

  String? processedImagePathFor(CardSide side) =>
      side == CardSide.front ? frontProcessedImagePath : backProcessedImagePath;

  /// Ảnh đã xử lý đại diện (ưu tiên mặt trước)
  String? get lastProcessedImagePath => frontProcessedImagePath ?? backProcessedImagePath;

  /// Căn chỉnh hiệu lực của một mặt: mặt hiện tại dùng giá trị đang chỉnh trên màn crop.
  SideCrop cropFor(CardSide side) {
    if (side == currentSide) {
      return SideCrop(cornerPoints: cornerPoints, rotationAngle: rotationAngle);
    }
    return (side == CardSide.front ? frontCrop : backCrop) ?? const SideCrop();
  }

  /// Các mặt đã có ảnh, theo thứ tự trước → sau
  List<CardSide> get sidesWithImage => [
        if (frontImagePath != null) CardSide.front,
        if (backImagePath != null) CardSide.back,
      ];

  ScanState copyWith({
    CardSide? currentSide,
    String? frontImagePath,
    String? backImagePath,
    String? currentImagePath,
    int? imageWidth,
    int? imageHeight,
    int? rotationAngle,
    List<Offset>? cornerPoints,
    SideCrop? frontCrop,
    SideCrop? backCrop,
    bool? isProcessing,
    String? errorMessage,
    bool? isFlashOn,
    CardOcrResult? frontOcrResult,
    CardOcrResult? backOcrResult,
    String? frontProcessedImagePath,
    String? backProcessedImagePath,
    BusinessCardInfo? currentCardInfo,
    bool? isOcrLoading,
    String? ocrErrorMessage,
    CardSide? ocrSideInProgress,
    int? ocrSideIndex,
    int? ocrSidesTotal,
    List<CardSide>? ocrFailedSides,
  }) {
    return ScanState(
      currentSide: currentSide ?? this.currentSide,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      currentImagePath: currentImagePath ?? this.currentImagePath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      cornerPoints: cornerPoints ?? this.cornerPoints,
      frontCrop: frontCrop ?? this.frontCrop,
      backCrop: backCrop ?? this.backCrop,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      frontOcrResult: frontOcrResult ?? this.frontOcrResult,
      backOcrResult: backOcrResult ?? this.backOcrResult,
      frontProcessedImagePath: frontProcessedImagePath ?? this.frontProcessedImagePath,
      backProcessedImagePath: backProcessedImagePath ?? this.backProcessedImagePath,
      currentCardInfo: currentCardInfo ?? this.currentCardInfo,
      isOcrLoading: isOcrLoading ?? this.isOcrLoading,
      ocrErrorMessage: ocrErrorMessage,
      ocrSideInProgress: ocrSideInProgress,
      ocrSideIndex: ocrSideIndex ?? this.ocrSideIndex,
      ocrSidesTotal: ocrSidesTotal ?? this.ocrSidesTotal,
      ocrFailedSides: ocrFailedSides ?? this.ocrFailedSides,
    );
  }

  /// Ghi kết quả OCR của một lần nhận dạng (thay hẳn kết quả cũ, kể cả về null).
  ScanState withOcrResults({
    required CardOcrResult? frontOcrResult,
    required CardOcrResult? backOcrResult,
    required String? frontProcessedImagePath,
    required String? backProcessedImagePath,
    required BusinessCardInfo? currentCardInfo,
    required List<CardSide> ocrFailedSides,
  }) {
    return ScanState(
      currentSide: currentSide,
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      currentImagePath: currentImagePath,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      rotationAngle: rotationAngle,
      cornerPoints: cornerPoints,
      frontCrop: frontCrop,
      backCrop: backCrop,
      isProcessing: isProcessing,
      isFlashOn: isFlashOn,
      frontOcrResult: frontOcrResult,
      backOcrResult: backOcrResult,
      frontProcessedImagePath: frontProcessedImagePath,
      backProcessedImagePath: backProcessedImagePath,
      currentCardInfo: currentCardInfo,
      isOcrLoading: false,
      ocrFailedSides: ocrFailedSides,
    );
  }
}
