# Thiết lập iOS (làm trên máy Mac)

Thư mục `ios/` được tạo và cấu hình sẵn từ Windows, **chưa build / chạy thử lần nào**.
Các bước dưới đây cần Mac + Xcode + CocoaPods.

## OCR tiếng Nhật trên iOS: dùng `google_mlkit_text_recognition` 0.17.1

| Bản | Tiếng Nhật trên iOS | Cài iOS bằng |
|---|---|---|
| **0.17.1 (đang dùng)** | ✅ qua pod `GoogleMLKit/TextRecognitionJapanese` (đã thêm trong `Podfile`) | CocoaPods |
| 1.0.x | ❌ chỉ chữ Latin (README plugin: Japanese tự rơi về Latin) | Swift Package Manager |

Code Dart + code native Android của 0.17.1 và 1.0.1 **giống hệt nhau** (đã so `diff`), chỉ khác phần iOS
→ hạ xuống 0.17.1 không đổi hành vi Android. **Không nâng lên 1.x** cho tới khi plugin có gói Japanese cho iOS.

## Đã cấu hình sẵn

| Hạng mục | Ở đâu |
|---|---|
| iOS tối thiểu **15.5** (ML Kit yêu cầu) | `Podfile`, `Runner.xcodeproj` (`IPHONEOS_DEPLOYMENT_TARGET`) |
| Pod nhận dạng tiếng Nhật `GoogleMLKit/TextRecognitionJapanese ~> 9.0.0` | `Podfile` |
| permission_handler: chỉ bật `PERMISSION_CAMERA`, `PERMISSION_PHOTOS` | `Podfile` → `post_install` |
| Câu giải thích quyền: camera, đọc / lưu ảnh, danh bạ | `Runner/Info.plist` |
| Chỉ màn dọc (iPhone + iPad), iPad toàn màn hình | `Runner/Info.plist` |
| `LSApplicationQueriesSchemes`: tel, mailto, https, http | `Runner/Info.plist` |
| `CFBundleLocalizations`: ja, vi, en; `ITSAppUsesNonExemptEncryption = NO` | `Runner/Info.plist` |
| Privacy manifest | `Runner/PrivacyInfo.xcprivacy` (**chưa gắn vào target**, xem bước 3) |
| Menu chia sẻ có điểm neo (iPad bắt buộc, thiếu là crash) | `CardShareService.shareOrigin()` |

## Các bước trên Mac

1. **Dùng CocoaPods, KHÔNG bật Swift Package Manager** cho project này
   (nếu đã bật: `flutter config --no-enable-swift-package-manager`).
2. Cài pod:
   ```bash
   flutter pub get
   cd ios && pod install --repo-update && cd ..
   ```
   Kiểm tra `ios/Podfile.lock` có `GoogleMLKit/TextRecognitionJapanese`.
3. **Kéo `Runner/PrivacyInfo.xcprivacy` vào target Runner** (tick *Copy items if needed* + target Runner).
4. **Bundle ID + ký app:** mở `ios/Runner.xcworkspace` (không mở `.xcodeproj`) → Runner → Signing & Capabilities
   → chọn Team, đặt Bundle Identifier (dùng **giống package Android** khi công ty chốt tên; hiện tạm là
   `com.example.appScannerCard`).
5. **Dịch câu giải thích quyền** (đang là tiếng Anh): File → New → *Strings File* tên `InfoPlist.strings`,
   Localize cho ja / vi / en, thêm `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
   `NSPhotoLibraryAddUsageDescription`, `NSContactsUsageDescription`, `CFBundleDisplayName`.
6. Chạy trên **iPhone thật** (ML Kit qua CocoaPods không chạy trên Simulator Apple Silicon arm64):
   ```bash
   flutter run --release
   ```

## Checklist test trên iPhone

- [ ] **OCR thẻ tiếng Nhật** (Kanji / Kana) — mục tiêu chính của việc hạ ML Kit về 0.17.1
- [ ] OCR thẻ tiếng Việt / tiếng Anh, thẻ 2 mặt
- [ ] Camera: lần đầu hỏi quyền → Cho phép / Từ chối → nút *Cấp quyền* / *Mở Cài đặt* → bật quyền → quay lại app, camera tự chạy
- [ ] Chọn ảnh từ Thư viện, cắt ảnh
- [ ] Lưu ảnh thẻ vào Ảnh
- [ ] *Lưu vào Danh bạ* mở màn tạo liên hệ của iOS
- [ ] Chia sẻ vCard / xuất CSV / sao lưu .zip (thử cả trên **iPad**: menu chia sẻ không crash)
- [ ] Khôi phục .zip chọn từ app Tệp
- [ ] Gọi / Email / Website / Bản đồ từ màn chi tiết
- [ ] Xoay máy: app giữ màn dọc
- [ ] Đổi ngôn ngữ máy ja / vi / en
