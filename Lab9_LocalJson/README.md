# Lab 9 Local JSON

Starter data được đọc từ `assets/data/notes.json` khi chưa có dữ liệu thiết bị. Các thay đổi được ghi tự động vào `notes.json` trong application documents directory bằng `path_provider`; hỗ trợ thêm, sửa, xóa và tìm kiếm.

Project này dùng `dart:io` và `path_provider`, nên chạy với Android/iOS (emulator hoặc thiết bị), không chạy persistence trên Chrome.

```powershell
flutter pub get
flutter run
```

Lưu ý: file asset gốc chỉ dùng để khởi tạo lần đầu; dữ liệu đã sửa nằm trong vùng lưu trữ riêng của ứng dụng.
