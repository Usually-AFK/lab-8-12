# Lab 10.4 Firebase Google Sign-In

Màn hình đăng nhập Google bằng Firebase Auth và hiển thị ảnh/tên/email của tài khoản. Project Flutter này chạy được trước khi cấu hình; đăng nhập thật yêu cầu Firebase credentials riêng:

1. Tạo Firebase project và bật Google provider trong Authentication.
2. Cài FlutterFire CLI và chạy `flutterfire configure` từ thư mục này.
3. Với Android, đăng ký SHA-1/SHA-256, tải/cài cấu hình Firebase theo hướng dẫn FlutterFire. Với Web, thêm domain và cấu hình OAuth client.
4. Chạy lại `flutter pub get` và `flutter run`.

Không commit file cấu hình hoặc credentials riêng tư vào source công khai. Khi chưa cấu hình, app sẽ hiện lỗi hướng dẫn thay vì crash.
