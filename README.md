# Flutter lab applications

Mỗi thư mục bên dưới là một project Flutter độc lập. Cài Flutter stable, mở terminal tại thư mục project, sau đó chạy:

```powershell
flutter pub get
flutter run
```

Chạy các app bằng Android emulator/thiết bị. Labs 8, 8B, 10.1, 10.2, 10.3, 11 và 12 cũng hỗ trợ web bằng `flutter run -d chrome`. Lab 9 (file JSON) và Lab 10.5 (system notification) cần thiết bị Android/iOS; Firebase Google Sign-In trong 10.4/Full cần cấu hình project Firebase riêng.

| Lab | Thư mục | Nội dung |
|---|---|---|
| 8 | [Lab8_ApiList](Lab8_ApiList) | GET JSONPlaceholder, model, service, FutureBuilder, loading/error/retry |
| 8B | [Lab8B_WeatherCompanion](Lab8B_WeatherCompanion) | Tra cứu thời tiết theo thành phố bằng Open-Meteo và lời khuyên hoạt động |
| 9 | [Lab9_LocalJson](Lab9_LocalJson) | Đọc JSON asset, lưu file local, CRUD + tìm kiếm |
| 10.1 | [Lab10_1_MockLogin](Lab10_1_MockLogin) | Đăng nhập giả lập và validation |
| 10.2 | [Lab10_2_RealApiLogin](Lab10_2_RealApiLogin) | REST API DummyJSON |
| 10.3 | [Lab10_3_AutoLogin_Logout](Lab10_3_AutoLogin_Logout) | REST API + SharedPreferences + tự khôi phục phiên |
| 10.4 | [Lab10_4_FirebaseGoogleSignIn](Lab10_4_FirebaseGoogleSignIn) | Firebase Authentication + Google Sign-In; cần cấu hình Firebase |
| 10.5 | [Lab10_5_Notification](Lab10_5_Notification) | Xin quyền và gửi local notification |
| 10 Full | [Lab10_Full](Lab10_Full) | API login + session + Google Sign-In + notification |
| 11 | [Lab11_Taskly](Lab11_Taskly) | Taskly cùng unit/widget/navigation/integration test |
| 12 | [Lab12_Taskly](Lab12_Taskly) | Taskly với TaskTile, Selector, keys và precache asset |

Firebase chưa thể đăng nhập thật cho tới khi thiết lập project riêng. Xem README trong Lab10.4 và Lab10_Full. Các API công khai cần internet.
