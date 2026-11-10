# A51 – Scan Danh Thiếp (Business Card Scanner)

Ứng dụng quét danh thiếp thông minh **100% On-device / Offline First** cho thị trường Nhật Bản và Việt Nam.

## 📱 Điểm nổi bật & USP
- **100% Offline**: Không tải dữ liệu lên cloud, bảo mật dữ liệu khách hàng tuyệt đối.
- **OCR Đa ngôn ngữ**: Hỗ trợ nhận diện chữ Nhật Bản (Kanji, Hiragana, Katakana) và Latin (Tiếng Việt, Tiếng Anh).
- **Trích xuất thông tin tự động**: Tự động nhận diện Tên, Chức vụ, Công ty, Số điện thoại, Email, Địa chỉ, Mã bưu điện.
- **Tương tác trực quan**: Chạm trực tiếp vào bounding box trên ảnh danh thiếp để gán vào form.
- **Xuất dữ liệu**: Xuất vào danh bạ máy, file `.vcf` (vCard), và file `.csv` (UTF-8 BOM).

---

## 🚀 Cấu trúc dự án Base

```text
lib/
├── main.dart                                # Khởi chạy app & cấu hình Theme
├── core/
│   ├── constants/
│   │   └── app_colors.dart                  # Bảng màu chuẩn theo thiết kế
│   └── theme/
│       └── app_theme.dart                   # Material 3 Theme
├── data/
│   └── models/
│       └── recent_card.dart                 # Model danh thiếp hiển thị gần đây
└── presentation/
    └── screens/
        └── home/
            ├── home_screen.dart             # Màn hình Trang chủ (Trang chủ 2 lựa chọn)
            └── widgets/
                ├── action_cards.dart        # Thẻ "Chụp ảnh" (Xanh) & "Chọn từ thư viện" (Xanh lá)
                └── recent_card_tile.dart    # Thẻ danh thiếp đã lưu gần đây
```

---

## 🛠 Hướng dẫn Chạy ứng dụng

Sau khi cài đặt Flutter SDK và cấu hình PATH:

```bash
# 1. Cài đặt packages
flutter pub get

# 2. Chạy ứng dụng trên thiết bị hoặc máy ảo
flutter run
```
