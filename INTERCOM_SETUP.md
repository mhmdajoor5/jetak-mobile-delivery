# إعداد Intercom في تطبيق Flutter

## نظرة عامة
تم إعداد Intercom بنجاح في تطبيق Flutter الخاص بك. Intercom هو منصة للدعم المباشر والمساعدة تتيح للمستخدمين التواصل مع فريق الدعم مباشرة من التطبيق.

## المفاتيح المستخدمة
- **App ID**: `j3he2pue`
- **iOS API Key**: `ios_sdk-9dd934131d451492917c16a61a9ec34824400eee`
- **Android API Key**: `android_sdk-d8df6307ae07677807b288a2d5138821b8bfe4f9`

## الملفات المضافة/المعدلة

### 1. pubspec.yaml
```yaml
dependencies:
  intercom_flutter: ^9.4.3
```

### 2. iOS Configuration (ios/Runner/Info.plist)
```xml
<key>IntercomAppId</key>
<string>j3he2pue</string>
<key>IntercomApiKey</key>
<string>ios_sdk-9dd934131d451492917c16a61a9ec34824400eee</string>
```

### 3. Android Configuration
#### android/app/build.gradle.kts
```kotlin
defaultConfig {
    // Intercom configuration
    manifestPlaceholders["intercom_app_id"] = "j3he2pue"
    manifestPlaceholders["intercom_api_key"] = "android_sdk-d8df6307ae07677807b288a2d5138821b8bfe4f9"
}
```

#### android/app/src/main/AndroidManifest.xml
```xml
<!-- Intercom configuration -->
<meta-data
    android:name="io.intercom.android.sdk.APP_ID"
    android:value="${intercom_app_id}" />
<meta-data
    android:name="io.intercom.android.sdk.API_KEY"
    android:value="${intercom_api_key}" />
```

### 4. ملفات Flutter المضافة

#### lib/src/helpers/intercom_helper.dart
- ملف helper لإدارة جميع وظائف Intercom
- يتضمن تهيئة، تسجيل دخول/خروج، عرض المساعد، إرسال رسائل، إلخ

#### lib/src/elements/IntercomButtonWidget.dart
- Widgets جاهزة لاستخدام Intercom:
  - `IntercomButtonWidget`: زر مع إشعارات للرسائل غير المقروءة
  - `IntercomFloatingButton`: زر عائم
  - `IntercomHelpButton`: زر للمساعدة

### 5. التكامل مع التطبيق

#### lib/main.dart
```dart
void main() async {
  // Initialize Intercom
  await IntercomHelper.initialize();
  // ... باقي الكود
}
```

#### lib/src/controllers/user_controller.dart
- تسجيل المستخدم في Intercom عند تسجيل الدخول
- إرسال بيانات المستخدم (ID، email، name، attributes)

#### lib/src/controllers/settings_controller.dart
- دالة تسجيل الخروج من Intercom

#### lib/src/pages/settings.dart
- إضافة زر "Live Chat Support" في قسم المساعدة
- إضافة زر "Logout from Intercom"

#### lib/src/pages/profile.dart
- إضافة زر Intercom عائم في صفحة الملف الشخصي

## الترجمات المضافة

### الإنجليزية
```json
{
  "live_chat_support": "Live Chat Support",
  "contact_support_intercom": "Contact Support",
  "logout_from_intercom": "Logout from Intercom",
  "intercom_help": "Help"
}
```

### العربية
```json
{
  "live_chat_support": "الدردشة المباشرة للدعم",
  "contact_support_intercom": "اتصل بالدعم",
  "logout_from_intercom": "تسجيل الخروج من الدعم",
  "intercom_help": "المساعدة"
}
```

### العبرية
```json
{
  "live_chat_support": "תמיכה בצ'אט חי",
  "contact_support_intercom": "צור קשר עם התמיכה",
  "logout_from_intercom": "התנתק מהתמיכה",
  "intercom_help": "עזרה"
}
```

## الميزات المتاحة

### 1. تهيئة Intercom
```dart
await IntercomHelper.initialize();
```

### 2. تسجيل المستخدم
```dart
await IntercomHelper.loginUser(
  userId: "123",
  email: "user@example.com",
  name: "John Doe",
  attributes: {
    'phone': '+1234567890',
    'user_type': 'driver',
  },
);
```

### 3. عرض المساعد
```dart
// عرض المساعد الرئيسي
await IntercomHelper.displayMessenger();

// عرض مساعد مع رسالة مخصصة
await IntercomHelper.displayMessageComposer(message: "Hello!");

// عرض مركز المساعدة
await IntercomHelper.displayHelpCenter();
```

### 4. إرسال رسائل
```dart
await IntercomHelper.sendMessage(message: "I need help");
```

### 5. تحديث بيانات المستخدم
```dart
await IntercomHelper.updateUser(
  name: "New Name",
  email: "newemail@example.com",
  customAttributes: {'status': 'active'},
);
```

### 6. تسجيل أحداث مخصصة
```dart
await IntercomHelper.logEvent(
  eventName: "order_delivered",
  metadata: {'order_id': '123', 'amount': 50.0},
);
```

### 7. التحقق من الرسائل غير المقروءة
```dart
bool hasUnread = await IntercomHelper.hasUnreadConversations();
```

### 8. تسجيل الخروج
```dart
await IntercomHelper.logout();
```

## كيفية الاستخدام

### للمطورين
1. استخدم `IntercomHelper` للوظائف الأساسية
2. استخدم Widgets الجاهزة في الواجهات
3. أضف تسجيل المستخدم في Intercom عند تسجيل الدخول
4. أضف تسجيل الخروج عند تسجيل الخروج من التطبيق

### للمستخدمين
1. **الدردشة المباشرة**: اضغط على زر "Live Chat Support" في الإعدادات
2. **المساعدة**: اضغط على زر Intercom في صفحة الملف الشخصي
3. **مركز المساعدة**: استخدم زر "Help" لعرض المقالات والمساعدة

## استكشاف الأخطاء

### مشاكل شائعة
1. **Intercom لا يظهر**: تأكد من تهيئة Intercom في main.dart
2. **المستخدم غير مسجل**: تأكد من استدعاء `loginUser` بعد تسجيل الدخول
3. **مفاتيح API خاطئة**: تحقق من صحة المفاتيح في ملفات التكوين

### رسائل التصحيح
- ✅ Intercom initialized successfully
- ✅ User logged in to Intercom
- ✅ Intercom messenger displayed
- ❌ Error initializing Intercom: [error message]

## الأمان
- المفاتيح محفوظة في ملفات التكوين المحلية
- لا يتم إرسال معلومات حساسة إلى Intercom
- يمكن للمستخدم تسجيل الخروج من Intercom في أي وقت

## الدعم
للمساعدة في إعداد Intercom أو حل المشاكل، راجع:
- [Intercom Flutter Documentation](https://developers.intercom.com/installing-intercom/docs/flutter-installation)
- [Intercom API Reference](https://developers.intercom.com/installing-intercom/reference)
