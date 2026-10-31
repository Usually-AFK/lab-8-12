# Lab 12 Taskly Performance

TaskTile tách riêng, danh sách dùng `Selector`, các task có `ValueKey`, app precache một asset PNG 128×128 và giữ dependencies/assets gọn.

```powershell
flutter pub get
flutter run --profile
flutter build apk --analyze-size
flutter build apk --release
```

Hoặc tạo App Bundle bằng `flutter build appbundle --release`. APK/App Bundle được sinh bởi Flutter trên máy có Android SDK; profile, size report và ảnh chụp cần ghi nhận trên thiết bị/emulator tương ứng.

## Release build trên Android arm64

APK release đã được tạo tại `build/app/outputs/flutter-apk/app-release.apk` (16.1 MB). Báo cáo phân tích của Flutter nằm ở `reports/apk-code-size-analysis.json`.

- Thành phần lớn nhất: thư viện runtime `lib/arm64-v8a`, khoảng 16 MB.
- Tiếp theo: `classes.dex`, khoảng 232 KB; Flutter assets, khoảng 218 KB.
- Kích thước chủ yếu đến từ Flutter runtime/AOT; app chỉ đóng gói một icon 128×128 và dùng `provider`. Có thể giữ dependency tối thiểu và nén/loại asset không dùng khi bổ sung tính năng.

Lệnh phân tích cần chỉ rõ một ABI trên Flutter hiện tại:

```powershell
flutter build apk --analyze-size --release --target-platform=android-arm64
```
