import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/app_settings_storage.dart';
import 'capture_fab_geometry.dart';

@immutable
class CaptureFabState {
  final bool visible;
  final FabAnchor anchor;

  const CaptureFabState({this.visible = true, this.anchor = FabAnchor.initial});

  CaptureFabState copyWith({bool? visible, FabAnchor? anchor}) =>
      CaptureFabState(visible: visible ?? this.visible, anchor: anchor ?? this.anchor);

  @override
  bool operator ==(Object other) =>
      other is CaptureFabState && other.visible == visible && other.anchor == anchor;

  @override
  int get hashCode => Object.hash(visible, anchor);
}

/// Bật/tắt và vị trí của nút chụp nổi; lưu lại sau khi tắt app.
class CaptureFabCubit extends Cubit<CaptureFabState> {
  final AppSettingsStorage? _storage;

  CaptureFabCubit({AppSettingsStorage? storage})
      : _storage = storage,
        super(CaptureFabState(
          visible: storage?.captureFabVisible ?? true,
          anchor: storage == null
              ? FabAnchor.initial
              : FabAnchor(onRight: storage.captureFabOnRight, y: storage.captureFabY),
        ));

  Future<void> setVisible(bool visible) async {
    emit(state.copyWith(visible: visible));
    await _guard(() => _storage?.setCaptureFabVisible(visible));
  }

  Future<void> setAnchor(FabAnchor anchor) async {
    if (anchor == state.anchor) return;
    emit(state.copyWith(anchor: anchor));
    await _guard(() => _storage?.setCaptureFabPosition(onRight: anchor.onRight, y: anchor.y));
  }

  Future<void> resetPosition() async {
    emit(state.copyWith(anchor: FabAnchor.initial));
    await _guard(() => _storage?.resetCaptureFabPosition());
  }

  Future<void> _guard(Future<void>? Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('CaptureFabCubit: cannot save: $e');
    }
  }
}
