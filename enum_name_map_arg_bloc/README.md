<!-- <code style="font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;"> -->
                SSSSSSSSSSSSSSS                                              tttt          
              SS:::::::::::::::S                                          ttt:::t          
             S:::::SSSSSS::::::S                                          t:::::t          
             S:::::S     SSSSSSS                                          t:::::t          
             S:::::S              aaaaaaaaaaaaa   uuuuuu    uuuuuu  ttttttt:::::ttttttt    
             S:::::S              a::::::::::::a  u::::u    u::::u  t:::::::::::::::::t    
              S::::SSSS           aaaaaaaaa:::::a u::::u    u::::u  t:::::::::::::::::t    
               SS::::::SSSSS               a::::a u::::u    u::::u  tttttt:::::::tttttt    
                 SSS::::::::SS      aaaaaaa:::::a u::::u    u::::u        t:::::t          
                    SSSSSS::::S   aa::::::::::::a u::::u    u::::u        t:::::t          
                         S:::::S a::::aaaa::::::a u::::u    u::::u        t:::::t          
                         S:::::Sa::::a    a:::::a u:::::uuuu:::::u        t:::::t    tttttt
             SSSSSSS     S:::::Sa::::a    a:::::a u:::::::::::::::uu      t::::::tttt:::::t
             S::::::SSSSSS:::::Sa:::::aaaa::::::a  u:::::::::::::::u      tt::::::::::::::t
             S:::::::::::::::SS  a::::::::::aa:::a  uu::::::::uu:::u        tt:::::::::::tt
              SSSSSSSSSSSSSSS     aaaaaaaaaa  aaaa    uuuuuuuu  uuuu          ttttttttttt  

<!--
<p align="center">
  <span>Tiếng Việt</span> |
  <a href="./lang/english">English</a> |
</p>
-->

![Saut version](https://img.shields.io/badge/Saut-v0.15.0-brightgreen.svg)
[![License](https://img.shields.io/badge/License-BSD-blue.svg)](https://docs.oracle.com/cloud/latest/big-data-discovery-cloud/BDDLG/cl_bsd_license.htm)

`Saut` cung cấp các tiện ích (utilities) hỗ trợ việc điều hướng cơ bản trong ứng dụng sử dụng `flutter_bloc` làm state management.

------

## 📦 Dependency

* dart sdk từ phiên bản 3.0.0 trở lên

* flutter sdk từ phiên bản 3.10.0 trở lên

* flutter_bloc bản mới nhất

## 🧩 Các tính năng

* Sử dụng `enum` thay vì `String` (để khai báo và điều hướng)

* [Có thể cấu hình để điều hướng mà không dùng `BuildContext`](#cách-cấu-hình-để-điều-hướng-mà-không-cần-dùng-buildcontext)

* [Tích hợp `RouteObserver`](#subscribing-routeobserver)

* [Truyền `blocs` qua màn hình khác không cần thông qua `arguments`](#truyền-blocs-qua-màn-hình-khác)

* [Thêm nhiều màn hình cùng một lúc](#cách-cấu-hình-để-thiết-lập-sẵn-các-màn-hình-khi-vào-app)

  Ví dụ cụ thể cho trường hợp này là ứng dụng chat Messenger: Khi bạn ấn vào thông báo tin nhắn mới, app sẽ chuyển đến màn hình tin nhắn/phòng chat đó. Sau khi ấn nút quay lại thì bạn sẽ về lại màn hình chứa các cuộc trò chuyện (đã diễn ra).

## ⚠️ Giới hạn

Thư viện này chưa hỗ trợ xử lý một số trường hợp điều hướng, bao gồm:

* Nested navigation

* Deep Links

* Đối với bản Web, việc thay đổi địa chỉ trên trình duyệt không làm thay đổi màn hình hiện tại. Nói theo cách khác là thực hiện điều hướng đến màn hình mới khi địa chỉ thay đổi.

## 🚩 Mục lục

- [📦 Dependency](#-dependency)
- [🧩 Các tính năng](#-các-tính-năng)
- [⚠️ Giới hạn](#️-giới-hạn)
- [🚩 Mục lục](#-mục-lục)
- [:rocket: Getting started](#rocket-getting-started)
- [:feet: Cách sử dụng](#feet-cách-sử-dụng)
  - [Chuyển màn hình](#chuyển-màn-hình)
  - [Quay lại màn hình cũ](#quay-lại-màn-hình-cũ)
  - [Lấy dữ liệu trả về từ màn hình trước](#lấy-dữ-liệu-trả-về-từ-màn-hình-trước)
  - [Truyền dữ liệu qua màn hình khác](#truyền-dữ-liệu-qua-màn-hình-khác)
  - [Nhận dữ liệu được truyền qua màn hình mới](#nhận-dữ-liệu-được-truyền-qua-màn-hình-mới)
  - [Thay thế màn hình hiện tại bằng màn hình khác](#thay-thế-màn-hình-hiện-tại-bằng-màn-hình-khác)
  - [Loại bỏ nhiều màn hình và thay bằng một màn hình khác](#loại-bỏ-nhiều-màn-hình-và-thay-bằng-một-màn-hình-khác)
  - [Route Logging](#route-logging)
  - [Thay đổi tên của tuyến đường được in ra trong console](#thay-đổi-tên-của-tuyến-đường-được-in-ra-trong-console)
  - [Cách cấu hình để điều hướng mà không cần dùng `BuildContext`](#cách-cấu-hình-để-điều-hướng-mà-không-cần-dùng-buildcontext)
  - [Subscribing `RouteObserver`](#subscribing-routeobserver)
  - [Listening `RouteObserver`](#listening-routeobserver)
  - [Truyền `blocs` qua màn hình khác](#truyền-blocs-qua-màn-hình-khác)
  - [Cách cấu hình để thiết lập sẵn CÁC màn hình khi vào app](#cách-cấu-hình-để-thiết-lập-sẵn-các-màn-hình-khi-vào-app)
  - [Sử dụng `showDialog` (các modal dialog) với `RouterDelegate`](#sử-dụng-showdialog-các-modal-dialog-với-routerdelegate)
  - [Thiết lập lại tất cả các cấu hình đã đặt (Reset)](#thiết-lập-lại-tất-cả-các-cấu-hình-đã-đặt-reset)
- [:mailbox: Báo cáo sự cố](#mailbox-báo-cáo-sự-cố)
- [:question: Q\&A](#question-qa)
- [:scroll: Giấy phép](#scroll-giấy-phép)

------

## :rocket: Getting started

1. Để sử dụng thư viện này, copy đoạn mã dưới đây vào file `pubspec.yaml`:

```yaml
dependencies:

  # other dependencies...

  saut_enma_bloc:
      git:
        url: https://github.com/thanhle1547/flutter_simple_app_router
        ref: flutter_bloc_latest
        path: enum_name_map_arg_bloc
```

2. Chạy `flutter pub get`.

`Saut` cung cấp 2 ví dụ demo tương ứng với 2 cách thực hiện điều hướng:

* Dùng `context` (Xem [example_w_context](./example_w_context/))

* Không dùng `context` (Xem [example_wo_context](./example_wo_context/))

<a href="#qa-problem-when-run-flutter-pub-get">➭ Bạn chạy `flutter pub get` nhưng không cập nhật được version mới?</a>

## :feet: Cách sử dụng

Để `Saut` có thể  hoạt động, việc đầu tiên cần phải làm là thiết lập các tuyến đường.

1. Khai báo tên của các tuyến đường bằng kiểu dữ liệu enum.

Ví dụ:

```dart
enum AppPages {
  Initial,
  Post_Published,
  Post_EditedDraft,

  // etc.
}
```

Ở ví dụ trên, các giá trị của `AppPages` không được đặt tên theo kiểu `lowerCamelCase`, hay `SCREAMING_SNAKE_CASE, CONSTANT_CASE`. Thoạt nhìn, bạn có thể nghĩ rằng nó là một sự hỗn hợp của các kiểu đặt tên khác nhau (như PascalCase, UpperCamelCase, Pascal_Snake_Case, ...). Tuy nhiên, đây là quy ước đặt tên mà tôi sẽ trình bày bên dưới đây:

> **Lưu ý:**
>
> Quy ước này không phải là bắt buộc, mà chỉ là một **đề xuất**.

<p align="center" id="naming-enum">
    &lt;&lt;First group/Module's name&gt;&gt;
    <b>_</b>
    &lt;&lt;Second group/Module's name&gt;&gt;
    <b>_&ctdot;_</b>
    &lt;&lt;Page/Screen's name&gt;&gt;
</p>

(**Chú ý** vào các dấu gạch dưới.)

Lý do cho sự ra đời của quy ước này là do cá nhân tôi muốn thay đổi tên tuyến đường được in ra trong console. Cụ thể về vấn đề này sẽ được trình bày trong phần [Thay đổi tên của tuyến đường được in ra trong console](#thay-đổi-tên-của-tuyến-đường-được-in-ra-trong-console).

Do yêu cầu tên của tuyến đường phải được khai báo bằng kiểu dữ liệu enum, nên ngoài đề xuất trên, bạn cũng có thể khai báo như ví dụ dưới đây:

```dart
enum PostPages {
  Published,
  Favorites,
  ...
}

enum VideoPages {
  ...
}

// etc.
```

2. Sau khi khai báo tên các tuyến đường, bước tiếp theo bạn cần phải làm là: Thiết lập cấu hình và liên kết các tuyến đường với cấu hình đó. Có 2 cách để thực hiện việc này:

**Cách 1:** Sử dụng phương thức tĩnh `Saut.setDefaultConfig()`

Ví dụ:

```dart
  final routes = {
    AppPages.Initial: RouteConfig(
      // some code ...
    ),
    AppPages.Post: RouteConfig(
      // some code ...
    ),

    // etc.
  };

  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routes: routes,
  );
```

**Cách 2:** Gọi phương thức tĩnh `Saut.define()` để thiết lập cấu hình cho từng tuyến đường

Ví dụ:

```dart
  Saut.define(
    page: AppPages.Initial,
    pageBuilder: (arguments) {
      // return your page/screen
    }
  );

  Saut.define(
    page: AppPages.Post,
    pageBuilder: (arguments) {
      // return your page/screen
    }
  );

  // etc.
```

Cụ thể, trong cách 1, trước khi truyền `routes` vào trong `Saut.setDefaultConfig()`, bạn phải thiết lập cấu hình của từng tuyến đường:

```dart
final RouteConfig _postPublished = RouteConfig(
  pageBuilder: (arguments) => const PostPublishedScreen(),
);

// etc.
```

rồi sau đó, liên kết tên tuyến đường với cấu hình tương ứng đã khai báo ở trên:

```dart
final Map<Enum, RouteConfig> routes = {
  AppPages.Post_Published: _postPublished,

  // etc.
};
```

Bảng dưới đây mô tả các tham số của `RouteConfig`:

<table>
  <thead>
    <tr>
      <th>Tham số</th>
      <th>Kiểu dữ liệu</th>
      <th>Giá trị mặc định</th>
      <th>Mô tả</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>debugRequiredArguments</td>
      <td>Map\<String, Object\>?</td>
      <td>null</td>
      <td>Nếu giá trị được truyền vào <code>khác null</code> thì trong chế độ debug, <code>Saut</code> sẽ kiểm tra các tham số (là yêu cầu bắt buộc) được truyền qua có khớp (về kiểu dữ liệu)hoặc bị thiếu so với các tham số được khai báo ở đây không và tung lỗi nếu cần.</td>
    </tr>
    <tr>
      <td>pageBuilder</td>
      <td>Widget Function(Map<String, dynamic>? arguments)</td>
      <td></td>
      <td>Dùng để xây dựng màn hình</td>
    </tr>
    <tr>
      <td>transition</td>
      <td>RouteTransition?</td>
      <td>null</td>
      <td>Hiệu ứng khi chuyển màn hình (có sẵn)</td>
    </tr>
    <tr>
      <td>customTransitionBuilderDelegate</td>
      <td>TransitionBuilderDelegate?</td>
      <td>null</td>
      <td>Hiệu ứng chuyển màn (của riêng bạn)</td>
    </tr>
    <tr>
      <td>transitionDuration</td>
      <td>Duration?</td>
      <td>null</td>
      <td>Thời gian chạy hiệu ứng</td>
    </tr>
    <tr>
      <td>curve</td>
      <td>Curve?</td>
      <td>null</td>
      <td>Hàm số biến đổi hiệu ứng chuyển màn</td>
    </tr>
    <tr>
      <td>opaque</td>
      <td>bool</td>
      <td>true</td>
      <td>Sau khi hiệu ứng chuyển màn hoàn thành thì màn hình/tuyến đường mới có che khuất màn hình/tuyến đường trước đó không. Nếu giá trị này là <code>true</code> thì các màn hình/tuyến đường trước đó sẽ không được xây dựng (build) lại để tiết kiệm tài nguyên. (Từ tài liệu của flutter)</td>
    </tr>
    <tr>
      <td>fullscreenDialog</td>
      <td>bool</td>
      <td>false</td>
      <td>Liệu tuyến đường này có phải là một dialog (hộp thoại) toàn màn hình hay không. Trong Material và Cupertino, toàn màn hình có tác dụng làm cho các thanh app bars có nút đóng thay vì nút quay lại. Trên iOS, dialog không thể đóng được bằng cử chỉ. (Từ tài liệu của flutter)</td>
    </tr>
    <tr>
      <td>debugPreventDuplicates</td>
      <td>bool?</td>
      <td>null</td>
      <td>Nếu giá trị được đặt là <code>true</code> thì trong chế độ debug, <code>Saut</code> sẽ tung lỗi khi hàm <code>toPage()</code> được gọi để chuyển sang cùng 1 màn hình đó.</td>
    </tr>
  </tbody>
</table>

### Chuyển màn hình

Để chuyển sang một màn hình khác, sử dụng phương thức `Saut.toPage()`. Phương thức này thực chất gọi hàm `Navigator.push()`.

```dart
    onPressed: () => Saut.toPage(context, AppPages.Example2),
```

> **Lưu ý:**
>
> Nên sử dụng một cách gọi phương thức điều hướng để giữ sự nhất quán.

### Quay lại màn hình cũ

Sử dụng phương thức `Saut.back()`. Phương thức này thực chất gọi hàm `Navigator.pop()`.

```dart
    onPressed: () => Saut.back(context),
```

Bạn cũng có thể trả về một kết quả sau khi thoát màn hình/dialog/...

```dart
void _handleAcceptButtonPressed() => Saut.back(context, result: true);
```

### Lấy dữ liệu trả về từ màn hình trước

Tương tự như `Navigator`, các phuơng thức điều hướng đều trả về một `Future` với kiểu dữ liệu có thể null, do đó ta có thể dùng 1 trong 2 cách dưới đây để lấy dữ liệu

Dùng từ khóa async/await

```dart
    onPressed: () async {
        bool? result = await Saut.toPage(context, AppPages.Example2);
    }
```

Dùng hàm `.then()`

```dart
    onPressed: () => Saut.toPage(context, AppPages.Example2)
        .then((value) => result = value ?? false);
```

### Truyền dữ liệu qua màn hình khác

Để truyền dữ liệu, ta sử dụng tham số `arguments`, dưới đây là 1 ví dụ:

```dart
    onPressed: () => Saut.toPage(
      context, 
      AppPages.Example2,
      arguments: {
        'name': 'Nguyễn Văn A',
      },
    ),
```

### Nhận dữ liệu được truyền qua màn hình mới

**Cách 1:** Lấy argument và truyền vào hàm khởi tạo (constructor) của màn hình mới

```dart
late final RouteConfig _postDetail = RouteConfig(
  pageBuilder: (arguments) => PostDetailScreen(
    name: arguments!['name'] as String,
  ),
);
```

**Cách 2:** Truy cập thông qua phương thức `Saut.extractArguments()`, hàm này thực chất gọi đến `ModalRoute.of(context)?.settings.arguments`, ví dụ:

```dart
  @override
  Widget build(BuildContext context) {
    final arguments = Saut.extractArguments(context);

    // some code
  }
```

### Thay thế màn hình hiện tại bằng màn hình khác

Để thay thế màn hình hiện tại bằng một màn hình khác, sử dụng phương thức `Saut.replaceWithPage()`. Phương thức này thực chất gọi hàm `Navigator.pushReplacement()`.

```dart
    onPressed: () => Saut.replaceWithPage(context, AppPages.Example2),
```

### Loại bỏ nhiều màn hình và thay bằng một màn hình khác

Để loại bỏ nhiều màn hình (không thỏa mãn một điều kiện cụ thể), hoặc đơn giản hơn là loại bỏ tất cả màn hình hiện tại để thay bằng một màn hình khác. Sử dụng phương thức `Saut.replaceAllWithPage()`. Phương thức này thực chất gọi hàm `Navigator.pushAndRemoveUntil()`.

Trong đó, tham số `predicate` là một hàm kiểm tra tuyến đường có nên được loại bỏ không dựa trên tên của nó. Nếu tham số này để là `null` (mặc định) thì phương thức `Saut.replaceAllWithPage()` sẽ loại bỏ tất cả màn hình hiện tại để thay bằng một màn hình khác.

Dưới đây là một vài ví dụ:

```dart
    onPressed: () => Saut.replaceAllWithPage(context, AppPages.Example2),
```

```dart
    onPressed: () => Saut.replaceAllWithPage(
      context, 
      AppPages.Example2,
      predicate: Saut.getModalRoutePredicate(AppPages.Example1),
    ),
```

```dart
    onPressed: () => Saut.replaceAllWithPage(
      context, 
      AppPages.Example2,
      predicate: ModelRoute.withName(/example_1),
    ),
```

<!--
<details>

<summary>
  <b>Trong ví dụ trên, có thể thay giá trị truyền vào <code>ModelRoute.withName</code> bằng enum được không?</b>
</summary>

Trước tiên bạn cần đọc phần [Thay đổi tên của tuyến đường được in ra trong console](#Thay-đổi-tên-của-tuyến-đường-được-in-ra-trong-console).

Nếu bạn không thực hiện cấu hình thì bạn chỉ cần gọi thêm hàm `.toString()`:

```dart
    onPressed: () => Saut.replaceAllWithPage(
      context, 
      AppPages.Example2,
      predicate: ModelRoute.withName(AppPages.Example1.toString()),
    ),
```

Ngược lại, bạn cần gọi hàm đã được dùng để truyền vào tham số `routeNameBuilder` như ví dụ dưới đây:

```dart
    onPressed: () => Saut.replaceAllWithPage(
      context, 
      AppPages.Example2,
      predicate: ModelRoute.withName(
        yourCustomRouteNameBuilder(AppPages.Example1)
      ),
    ),
```

</details>
-->

<!--
```dart
    onPressed: () => Saut.replaceAllWithPage(
      context, 
      AppPages.Example2,
      predicate: (Route<dynamic> route) {
        if (route is PageRoute)
          return route.settings.name == name;

        return false;
      },
    ),
```
-->

### Route Logging

Trong quá trình phát triển, việc in ra tên của tuyến đường và dữ liệu được truyền qua đó sẽ hỗ trợ một phần nào thời gian, công sức để sửa lỗi. Vì vậy mà `Saut` cung cấp cho bạn một `RouteObserver` tên là: `SautRouteLoggingObserver` - để theo dõi sự thay đổi của các tuyến đường.

<details>

<summary>
  <b>Vậy <code>SautRouteLoggingObserver</code> sẽ in ra (những) cái gì, trông nó như thế nào?</b>
</summary>

Ví dụ, khi chuyển sang một màn hình mới, `debug console` sẽ in ra thông báo có dạng:

```console
[SAUT] GOING TO: <<route.settings.name>>?argument1=value1&argument2=value2...
```

trong đó: route.settings.name là tên của tuyến đường hiện tại

</details>

Trong file chứa widget MaterialApp, đăng ký `SautRouteLoggingObserver` như một navigation observer.

```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        if (kDebugMode)
          SautRouteLoggingObserver(),
      ],
    );
  }
```

### Thay đổi tên của tuyến đường được in ra trong console

Mặc định `Saut` sẽ gọi hàm `toString()` để in ra tên của tuyến đường. Để thay đổi cách nó được in ra, bạn phải thiết lập thông qua tham số `routeNameBuilder` trong hàm `Saut.setDefaultConfig()`. Tham số này nhận vào một hàm có kiểu như sau: `String Function(Enum page)?`.

```dart
  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routeNameBuilder: yourCustomRouteNameBuilder,
  );
```

<p>
Nếu như bạn đặt tên theo như cách mà tôi đã đề xuất <a href="#naming-enum">ở trên</a>, thì bạn có thể truyền vào <code>routeNameBuilder</code> hàm <code>mixedCaseWithUnderscoresEnumRouteNameBuilder</code>.
</p>

```dart
  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routeNameBuilder: mixedCaseWithUnderscoresEnumRouteNameBuilder,
  );
```

<!--
**Nhắc lại quy ước**:

<center>
    &lt;&lt;First group/Module's name&gt;&gt;
    <b>_</b>
    &lt;&lt;Second group/Module's name&gt;&gt;
    <b>_&ctdot;_</b>
    &lt;&lt;Page/Screen's name&gt;&gt;
</center>
-->

Dưới đây là một vài ví dụ kết quả biến đổi của hàm `mixedCaseWithUnderscoresEnumRouteNameBuilder`:

* AppPages.Initial ⇒ /initial 

* AppPages.Post_Published ⇒ /post/published

* AppPages.Post_EditedDraft ⇒ /post/edit_draft

Bỏ qua phần `AppPages.`, có thể thấy, dấu `_` đã được chuyển thành dấu `/`, chữ cái in hoa ở đầu mỗi từ được chuyển thành chữ thường và thêm dấu `_` nếu nằm liền kề nhau (như `EditedDraft` ⇒ edit_draft).

Kết hợp với việc sử dụng `SautRouteLoggingObserver` đã được trình bày trong phần [Route Logging](#route-logging) (ở trên) thì tên tuyến đường được in ra sẽ có dạng (path-like structure) như ví dụ dưới đây:

```console
[SAUT] GOING TO: /post/edit_draft?argument1=value1&argument2=value2
```

### Cách cấu hình để điều hướng mà không cần dùng `BuildContext`

> [example_wo_context](./examples/example_wo_context/) là một ví dụ cụ thể.

Trong file chứa widget MaterialApp, tạo `navigatorKey` bằng phương thức tĩnh `Saut.createNavigatorKeyIfNotExisted()`.

```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Saut.createNavigatorKeyIfNotExisted(),
    );
  }
```

Để gọi các hàm `toPage()`, `back()`, ... mà không cần dùng `BuildContext`, hãy sử dụng `Saut.navigator.toPage()`, `Saut.navigator.back()`, ...

### Subscribing `RouteObserver`

Nếu bạn muốn dùng `RouteObserver` để lắng nghe thay đổi, `Saut` cung cấp cho bạn 2 phương thức tĩnh `subscribe` và `unsubscribe` để đăng ký và hủy đăng ký `RouteAware`. Các bước thực hiện như sau:

<p id="step-1-subscribing-route-observer"><p>
Bước 1: Trong file chứa widget MaterialApp, đăng ký `SautRouteObserver` như một navigation observer.

```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        SautRouteObserver(),
      ],
    );
  }
```

Bước 2: Trong file chứa `StatefulWidget`,

 - triển khai (implement) `SautRouteSubscriptionStateMixin` trong class State. mixin này sẽ tự động thực hiện đăng ký và hủy đăng ký, bạn chỉ cần ghi đè 2 phương thức: `didPushNext` và `didPopNext`.


```dart
class ExampleWidget extends StatefulWidget {
  // some code ...
}

class ExampleWidgetState extends State<ExampleWidget> with SautRouteSubscriptionStateMixin {

  // some code ...

  /// Called when a new route has been pushed,
  /// and the current route is no longer visible.
  @override
  void didPushNext() {
    // some code ...
  }

  /// Called when the top route has been popped off,
  /// and the current route shows up.
  @override
  void didPopNext() {
    // some code ...
  }
```

 - Hoặc bạn có thể thực hiện thủ công 2 bước đã được thực hiện tự động ở mixin trên bằng cách triển khai `RouteAware` trong class State và đăng ký nó với `SautRouteObserver`.

```dart
class ExampleWidget extends StatefulWidget {
  // some code ...
}

class ExampleWidgetState extends State<ExampleWidget> with RouteAware {

  // some code ...

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Saut.subscribe(this, context);
  }

  @override
  void dispose() {
    Saut.unsubscribe(this);
    super.dispose();
  }

  /// Called when a new route has been pushed,
  /// and the current route is no longer visible.
  @override
  void didPushNext() {
    // some code ...
  }

  /// Called when the top route has been popped off,
  /// and the current route shows up.
  @override
  void didPopNext() {
    // some code ...
  }
```

### Listening `RouteObserver`

Nếu bạn đã từng dùng `RouteObserver` để đăng ký nhận thay đổi, thì có thể bạn đã gặp phải trường hợp cần phải lắng nghe tất cả thay đổi của tuyến đường để có thể xử lý logic. Vậy nên, để giải quyết vấn đề này, `Saut` cung cấp một giải pháp (để bạn cân nhắc sử dụng).

<a href="#step-1-subscribing-route-observer">Bước 1</a> (cấu hình): tương tự như như phần [Subscribing `RouteObserver`](#subscribing-routeobserver). 

Điểm khác biệt so với phần trên nằm ở bước 2. Tại bước này, bạn cần triển khai `SautRouteListerningStateMixin` hoặc `RouteAware` trong class State. Với `RouteAware`, thay vì gọi phương thức `Saut.subscribe()` để đăng ký, thì bạn sẽ gọi phương thức `Saut.addListener()`. Để hủy lắng nghe, thay `Saut.unsubscribe()` bằng phương thức `Saut.removeListener()`.


```dart
class ExampleWidget extends StatefulWidget {
  // some code ...
}

class ExampleWidgetState extends State<ExampleWidget> with RouteAware {

  // some code ...

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Saut.addListener(this); // ⇐ Notice the changed and the number of arguments
  }

  @override
  void dispose() {
    Saut.removeListener(this); // ⇐ Notice the changed
    super.dispose();
  }

  /// Called when a new route has been pushed,
  /// and the current route is no longer visible.
  @override
  void didPushNext() {
    // some code ...
  }

  /// Called when the top route has been popped off,
  /// and the current route shows up.
  @override
  void didPopNext() {
    // some code ...
  }
```

### Truyền `blocs` qua màn hình khác

Để có thể truyền `blocs/cubits` qua màn hình khác, có thể bạn đã nghĩ đến việc truyền nó thông qua tham số `arguments`. Ngoài cách này ra, còn có một cách khác đó là truyền qua 1 trong 2 tham số: `blocValue` hoặc `blocProviders`. Dưới đây là ví dụ về cách sử dụng 2 tham số này:

* Ví dụ truyền qua tham số `blocValue`:

```dart
    onPressed: () => Saut.toPage(
        context, 
        AppPages.Example2,
        arguments: {
            'name': 'Nguyễn Văn A',
        }
        blocValue: context.read<YourCubit>(),
    ),
```

* Ví dụ truyền qua 1 tham số `blocProviders`:

```dart
    onPressed: () => Saut.toPage(
        context, 
        AppPages.Example2,
        arguments: {
            'name': 'Nguyễn Văn A',
        }
        blocProviders: [
          BlocProvider.value(
            value: context.read<YourFirstCubit>(),
          ),
          BlocProvider.value(
            value: context.read<YourSecondCubit>(),
          ),

          // etc.
        ],
    ),
```

### Cách cấu hình để thiết lập sẵn CÁC màn hình khi vào app

> [example_router_delegate](./examples/example_router_delegate/) là một ví dụ cụ thể.

1. Khai báo tên của các thiết lập. Các cái tên này có kiểu dữ liệu khác null, ví dụ như String, enum, ...

Theo ví dụ trên, trong file [routes/stacked_pages.dart](examples/example_router_delegate/lib/routes/stacked_pages.dart), tên của các thiết lập này được khai báo bằng kiểu enum.

```dart
enum AppPageStack {
  tredingPost,
  detailTredingPost,
}
```

2. Chỉ định các màn hình cho mỗi thiết lập.

Ví dụ:

```dart
  final Map<AppPageStack, List<Enum>> stackedPages = {
    AppPageStack.tredingPost: [
      AppPages.Post_Published,
      AppPages.Post_Trending,
    ],

    // etc.
  };

  Saut.setDefaultConfig(
    stackedPages: stackedPages,
  );
```

Trong trường hợp bạn cần thêm 1 dialog vào trong thiết lập này, `RouteConfig` có một tham số là `routeBuilder` (ví dụ trong file [routes/routes.dart](examples/example_router_delegate/lib/routes/routes.dart)). Đây là một hàm thực hiện tạo route và nhận vào các tham số sau:

  - BuildContext context

  - RouteConfig resolvedConfig: Đây chính là config bạn đã thiết lập. Trong trường hợp bạn sử dụng các phương thức điều hướng (`Saut.toPage`, ...), thì đây chính là config đã được ghi đè bởi các phương thức điều hướng trên.

  - RouteSettings settings: Đây là settings mà bạn phải truyền vào route do bạn tạo ra.

  - Widget page: Đây chính là Widget được tạo ra bởi tham số `pageBuilder`.

3. Sử dụng hàm khởi tạo `MaterialApp.router` (hoặc `CupertinoApp.router` tương ứng) thay cho hàm khởi tạo mặc định `MaterialApp`/`CupertinoApp`. Trong đó, hai tham số bắt buộc phải truyền vào là `routeInformationParser` và `routerDelegate` (được tạo qua phương thức tĩnh `Saut.createRouterDelegateIfNotExisted`). Mặc định, nếu tham số ___`initialPageStackName` khác `null`___ thì:

   - Tham số `arguments` là một `Map` rỗng (kiểu `Map<String, dynamic>`) và tất cả các màn trong thiết lập đó sẽ cùng nhận được cùng một `arguments`. Ví dụ với thiết lập `AppPageStack.tredingPost` ở trên, cả 2 màn `AppPages.Post_Published` và `AppPages.Post_Trending` đều cùng nhận một `arguments`.

   - RouterDelegate sẽ ưu tiên sử dụng `initialPageStackName` thay vì `initialPage`.

```dart
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const SautRouteInformationParser(),
      routerDelegate: Saut.createRouterDelegateIfNotExisted(
        navigatorObservers: [SautRouteLoggingObserver()], // optional
        initialPage: yourInitialPage,                     // optional
        initialPageStackName: yourInitialPageStackName,   // optional
        arguments: yourArguments,                         // optional
      ),
    );
  }
```

### Sử dụng `showDialog` (các modal dialog) với `RouterDelegate`

Không thể sử dụng các Imperative apis của Flutter, bao gồm cả `showDialog`, `showModalBottomSheet`, ... khi dùng `RouterDelegate`.

<!--
Bằng cách tạo `RouteSettings` thông qua phương thức `Saut.createRouteSettings`, bạn vẫn có thể sử dụng `showDialog`, `showGeneralDialog`, ... Nếu bạn không tạo `RouteSettings` thông qua phương thức trên, sau khi hiển thị dialog, bạn tiếp tục chuyển qua màn hình khác, Flutter sẽ tung ra một lỗi trong quá trình assert, ảnh hưởng đến việc điều hướng.

> Bạn vẫn nên cấu hình bằng `routeBuilder` của `RouteConfig` và sử dụng `Saut.toPage` như đã đề cập ở phần bên trên.

Lý do là Flutter vẫn sẽ tung ngoại lệ trong quá trình assert với nội dung: "A page-based route should not be added using the imperative api. Provide a new list with the corresponding Page to Navigator.pages instead". Ngoại lệ này __không__ ảnh hưởng đến việc điều hướng nhưng sẽ luôn xuất hiện trên console mỗi khi sử dụng các api này.
-->

### Thiết lập lại tất cả các cấu hình đã đặt (Reset)

Sử dụng phương thức tĩnh `Saut.reset`.

## :mailbox: Báo cáo sự cố

Nếu bạn gặp bất kỳ vấn đề nào, hãy sử dụng [Github Issues forum](https://github.com/thanhle1547/flutter_simple_app_router/issues) để tạo một sự cố.

<!-- 
## ✍️ Contributing

Nếu bạn cảm thấy hứng thú và muốn đóng góp vào thư viện này, vui lòng xem qua [Contributing Guide](./wiki/Contribution-Guide) để biết các thông tin liên quan.

Bạn có thể để lại một ngôi sao (GitHub Star) nếu thấy thư viện này tuyệt vời hoặc để mình có thêm động lực phát triển thư viện.
-->

## :question: Q&A

<details>

<summary>
  <b>Có cách nào lấy được tên của tuyến đường hiện tại không?</b>
</summary>

Có. Bạn cần gọi phương thức tĩnh `Saut.getCurrentRouteName()` để có thể lấy tên của tuyến đường hiện tại. Tên của tuyến đường này kiểu String, không phải kiểu enum - cái mà bạn dùng để cấu hình.

Ngoài ra, bạn cũng có thể lấy được tuyến đường hiện tại thông qua phương thức tĩnh `Saut.getCurrentRoute()`.

</details>

<details id="qa-problem-when-run-flutter-pub-get">

<summary>
  <b>Sau khi chạy `flutter pub get` nhưng không thấy tính năng/bổ sung/thay đổi mới?</b>
</summary>

1. Copy SHA của commit mới nhất.

[![GitHub last commit (branch)](https://img.shields.io/github/last-commit/thanhle1547/flutter_simple_app_router/flutter_bloc_latest)](https://github.com/thanhle1547/flutter_simple_app_router/commits/flutter_bloc_latest)

2. Tìm tên thư viện (`saut_enma_bloc`) trong file `pubspec.lock`.

3. Thay thế giá trị trong `resolved-ref` bằng SHA vừa copy (bỏ qua version).

Preview:

```lock
  saut_enma_bloc:
    dependency: "direct main"
    description:
      path: enum_name_map_arg_bloc
      ref: "flutter_bloc_latest"
      resolved-ref: "69fd9e8a4142fcb732ecf6c23ec4e66a61f07f2e"
      url: "https://github.com/thanhle1547/flutter_simple_app_router"
    source: git
    version: "0.1.1"
```

4. Nhớ lưu file.

5. (Có thể bỏ qua) Để chắc chắn là bạn có thể lấy được code mới nhất về, hãy xóa thư viện đã được tải về ở trong `.pub-cache` rồi hẵng xem bước 6.

* Windows: %LOCALAPPDATA%\Pub\Cache\git

* macOS và Linux (trong thư mục home): `/.pub-cache/git`

  - Trên Linux:
 
    Nếu bạn cài flutter bằng snap thì có thể xem trong: `~/snap/flutter/common/flutter/.pub-cache/`

    Hoặc trong SDK của flutter: `/flutter/.pub-cache/`

6. Chạy `flutter pub get`.

</details>


<details id="qa-need-passing-bloc-without-adding-dependency-or-change-the-code">

<summary>
  <b>Nếu như tôi cần truyền <code>bloc</code> vào 1 màn hình, mà <code>bloc</code> đó được lấy từ màn hình trước đó. Tôi không muốn đặt <code>bloc</code> đó lên phía trên <code>MaterialApp</code>. Có cách nào để xử lý trường hợp này không (không dùng thêm thư viện khác, như <code>get_it</code>, ...)?</b>
</summary>

Có. Bạn có thể tạo 1 Completer và truyền nó đến màn cần bloc đó.

Trong ví dụ đã được nhắc tới bên trên ([example_router_delegate](./examples/example_router_delegate/)) đã có chứa ví dụ xử lý cho tình huống này.

1. Trong file `main.dart`, thêm 1 tham số là `Completer` với kiểu dữ liệu là bloc.

```dart
    arguments = selectedNotificationPayload == null
        ? null
        : {
            ...jsonDecode(selectedNotificationPayload!) as Map<String, dynamic>,
            'postFavoritesCubitCompleter': Completer<PostFavoritesCubit>(), // ⇐ Notice this line
          };
```

2. Trong file `routes/routes.dart`:

Sau khi khởi tạo bloc (ở màn trước đó), gọi hàm complete của completer nếu completer chưa completed.

```dart
        final Completer<PostFavoritesCubit>? completer =
            arguments?['postFavoritesCubitCompleter'];

        if (completer != null && completer.isCompleted == false) {
          completer.complete(context.read<PostFavoritesCubit>());
        }
```

Cũng với completer ấy, truyền nó vào màn hình mà bạn cần bloc để sử dụng:

```dart
      child: PostTrendingDialog(
        postFavoritesCubitCompleter: completer,
      ),
```

</details>

## :scroll: Giấy phép

`Saut` được phân phối dưới giấy phép BSD-3-Clause. Phiên bản đầy đủ của giấy phép này ở trong file LICENSE.
