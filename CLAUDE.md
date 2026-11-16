# CLAUDE.md

Hướng dẫn cho người và AI làm việc trong dự án này.

## Quy tắc layout (bắt buộc với mọi widget có chữ)

Người dùng thật (nhất là ở Nhật) thường để **cỡ chữ hệ thống lớn**, và chuỗi tiếng Việt / tiếng Anh dài hơn tiếng Nhật rất nhiều. Lỗi "BOTTOM/RIGHT OVERFLOWED" của app đều đến từ một gốc: **khung kích thước cố định chứa chữ phóng to theo hệ thống**.

1. **Không cố định chiều cao / chiều rộng bằng con số cho khung chứa chữ.**
   Dùng `ConstrainedBox(minHeight: …)` thay cho `SizedBox(height: …)` / `Container(height: …)`.
2. **Trong `Row`, mọi `Text` có thể dài phải nằm trong `Expanded` / `Flexible`** và có
   `maxLines` + `overflow: TextOverflow.ellipsis`. Không dùng `maxWidth` cố định (vd. 200) cho chữ.
3. **Nhiều mảnh (tên + nhãn + ngày, nhãn + tag…) trên một hàng hẹp** → dùng `Wrap`, hoặc tách mảnh phụ xuống dòng riêng.
4. **Khung bắt buộc cố định** (header 56px, nút nổi, ô của nút gạt, nút tròn…) → bọc chữ trong
   `FittedBox(fit: BoxFit.scaleDown)` để chữ tự thu nhỏ cho vừa, không tràn.
5. **Cột dọc gồm nhiều phần cố định** (bảng trượt, hộp thoại, khối nút dưới ảnh) → phải cuộn được
   (`SingleChildScrollView`, hoặc `Flexible` + `SingleChildScrollView` cho phần phụ).
6. **Header**: dùng `NavyHeaderBar` / `NavyHeaderTextButton` có sẵn (đã xử lý chữ dài, chữ to), không tự dựng `Row` mới.
7. **Hình minh hoạ mô phỏng vật thật** (thẻ danh thiếp dựng lại, tỉ lệ 91:55) được phép bỏ phóng to chữ
   bằng `MediaQuery.withNoTextScaling` — **chỉ** cho trường hợp này, không dùng để né lỗi ở chỗ khác.

## Test layout bắt buộc

- `test/layout/screens_layout_test.dart` dựng **mọi màn chính qua router thật** (có menu dưới + nút chụp nổi)
  ở mọi tổ hợp: cỡ chữ `1.0 / 1.3 / 2.0` × ngôn ngữ `ja / vi / en` × màn `320×568 / 412×915`
  (cấu hình trong `test/helpers/layout_guard.dart`).
- Fail → thông báo liệt kê từng tổ hợp lỗi kèm `lib/…dart:dòng` của widget bị tràn → sửa theo quy tắc trên.
- **Thêm màn / bảng trượt / hộp thoại mới → thêm vào test này** (màn: thêm 1 dòng vào map `screens`;
  bảng trượt / hộp thoại: dùng `host(...)` như `CardShareSheet`).
- Màn cần dữ liệu: dùng `MemoryCardRepository` (`test/helpers/`) — widget test không chạy được I/O file thật.
- Không dùng `pumpAndSettle` trong test layout (spinner / animation lặp vô hạn làm test treo).

Chạy nhanh: `flutter test test/layout`

## Khác

- Chuỗi hiển thị: luôn qua l10n (`lib/l10n/app_{vi,en,ja}.arb`, rồi `flutter gen-l10n`), có fallback tiếng Việt trong code.
- Bảng trượt / menu popup mở bằng root navigator (`useRootNavigator: true`) để nằm trên menu dưới và nút chụp nổi.
