import 'package:flutter/material.dart';

enum CardSide { front, back }

class ScanState {
  final CardSide currentSide;
  final String? frontImagePath;
  final String? backImagePath;
  final String? currentImagePath; // Ảnh hiện tại đang hiển thị trên màn 2b để căn chỉnh
  final int rotationAngle; // 0, 90, 180, 270
  final List<Offset> cornerPoints; // 4 góc chuẩn hóa [0.0 -> 1.0] (TL, TR, BR, BL)
  final bool isProcessing;
  final String? errorMessage;
  final bool isFlashOn;

  const ScanState({
    this.currentSide = CardSide.front,
    this.frontImagePath,
    this.backImagePath,
    this.currentImagePath,
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
  });

  bool get hasBothSides => frontImagePath != null && backImagePath != null;
  bool get hasFrontImage => frontImagePath != null;
  bool get hasBackImage => backImagePath != null;

  ScanState copyWith({
    CardSide? currentSide,
    String? frontImagePath,
    String? backImagePath,
    String? currentImagePath,
    int? rotationAngle,
    List<Offset>? cornerPoints,
    bool? isProcessing,
    String? errorMessage,
    bool? isFlashOn,
  }) {
    return ScanState(
      currentSide: currentSide ?? this.currentSide,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      currentImagePath: currentImagePath ?? this.currentImagePath,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      cornerPoints: cornerPoints ?? this.cornerPoints,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
    );
  }
}
