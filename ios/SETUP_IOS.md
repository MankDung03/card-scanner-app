# Thiết lập iOS (làm trên máy Mac)

Thư mục `ios/` được tạo và cấu hình sẵn từ Windows, **chưa build / chạy thử lần nào**.
Các bước dưới đây cần Mac + Xcode.

## Đã cấu hình sẵn

| Hạng mục | Ở đâu |
|---|---|
| iOS tối thiểu **15.0** (ML Kit, image_picker yêu cầu) | `Runner.xcodeproj` → `IPHONEOS_DEPLOYMENT_TARGET` |
| Câu giải thích quyền: camera, đọc / lưu ảnh, danh bạ | `Runner/Info.plist` |
| Chỉ màn dọc (iPhone + iPad), iPad toàn màn hình | `Runner/Info.plist` |
| `LSApplicationQueriesSchemes`: tel, mailto, https, http | `Runner/Info.plist` |
| `CFBundleLocalizations`: ja, vi, en; `ITSAppUsesNonExemptEncryption = NO` | `Runner/Info.plist` |
| Privacy manifest | `Runner/PrivacyInfo.xcprivacy` (**chưa gắn vào target**, xem bước 3) |
| Menu chia sẻ có điểm neo (iPad bắt buộc, thiếu là crash) | `CardShareService.shareOrigin()` |

## Các bước trên Mac

1. **Bật Swift Package Manager cho Flutter.** `google_mlkit_text_recognition` 1.x chỉ hỗ trợ SPM:
   ```bash
   flutter config --enable-swift-package-manager
   ```
2. **ML Kit resource bundle.** Tải `LatinOCRResources.bundle` từ release
   [d-date/google-mlkit-swiftpm 9.0.2](https://github.com/d-date/google-mlkit-swiftpm/releases/tag/9.0.2),
   rồi kéo vào target **Runner** → Build Phases → *Copy Bundle Resources*.
3. **Kéo `Runner/PrivacyInfo.xcprivacy` vào target Runner** (tick *Copy items if needed* + target Runner).
4. **Bundle ID + ký app:** Runner → Signing & Capabilities → chọn Team, đặt Bundle Identifier
   (dùng **giống package Android** khi công ty chốt tên; hiện tạm là `com.example.appScannerCard`).
5. **Dịch câu giải thích quyền** (đang là tiếng Anh): File → New → *Strings File* tên `InfoPlist.strings`,
   Localize cho ja / vi / en, thêm `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
   `NSPhotoLibraryAddUsageDescription`, `NSContactsUsageDescription`, `CFBundleDisplayName`.
6. Chạy: `flutter pub get && flutter run` trên iPhone thật.
   Đổi `Info.plist` mà quyền vẫn bị từ chối → xoá cache: `rm -rf ~/Library/Developer/Xcode/DerivedData`
   (permission_handler qua SPM đọc `NS*UsageDescription` để bật quyền, và có cache).

## ⚠️ Chưa giải quyết: OCR tiếng Nhật trên iOS

`google_mlkit_text_recognition` 1.0.x trên iOS **chỉ nhận chữ Latin**. Yêu cầu Japanese sẽ tự rơi về Latin,
nên Kanji / Kana không đọc được. Tiếng Việt / tiếng Anh vẫn đọc được.
Cần chọn hướng xử lý trước khi phát hành iOS (hạ plugin về 0.15.x dùng CocoaPods, hoặc Apple Vision riêng cho iOS).

## Checklist test trên iPhone

- [ ] Camera: lần đầu hỏi quyền → Cho phép / Từ chối → nút *Cấp quyền* / *Mở Cài đặt* → bật quyền → quay lại app, camera tự chạy
- [ ] Chọn ảnh từ Thư viện, cắt ảnh, OCR thẻ tiếng Việt / tiếng Anh (và tiếng Nhật sau khi xử lý mục ⚠️)
- [ ] Lưu ảnh thẻ vào Ảnh (hỏi quyền "chỉ thêm ảnh")
- [ ] *Lưu vào Danh bạ* mở màn tạo liên hệ của iOS
- [ ] Chia sẻ vCard / xuất CSV / sao lưu .zip (thử cả trên **iPad**: menu chia sẻ không crash)
- [ ] Khôi phục .zip chọn từ app Tệp
- [ ] Gọi / Email / Website / Bản đồ từ màn chi tiết
- [ ] Xoay máy: app giữ màn dọc
- [ ] Đổi ngôn ngữ máy ja / vi / en
