# دليل إعداد فيديو Splash Screen

## ✅ ما تم إنجازه:

1. **إضافة حزمة video_player**: تم إضافة `video_player: ^2.8.2` إلى `pubspec.yaml`
2. **إنشاء مجلد الفيديوهات**: تم إنشاء `assets/videos/` في المشروع
3. **تحديث pubspec.yaml**: تم إضافة مجلد الفيديوهات إلى assets
4. **تعديل Splash Screen**: تم تحديث الكود ليدعم الفيديو
5. **تثبيت الحزم**: تم تشغيل `flutter pub get` بنجاح

## 📁 بنية الملفات المحدثة:

```
assets/
├── videos/          # مجلد جديد للفيديوهات
│   └── splash.mp4   # ضع الفيديو هنا
├── img/
├── cfg/
└── ...
```

## 🎬 الميزات المضافة:

### 1. فيديو خلفية
- يعرض الفيديو كخلفية للـ splash screen
- يتكيف مع جميع أحجام الشاشات
- يملأ الشاشة بالكامل

### 2. شعار التطبيق فوق الفيديو
- يظهر شعار التطبيق في المنتصف
- طبقة شفافة سوداء لتحسين الرؤية
- تأثير Hero animation للانتقال السلس

### 3. مؤشر التحميل
- مؤشر دائري أبيض للرؤية الواضحة
- يظهر أثناء تحميل البيانات

### 4. النسخ الاحتياطي
- إذا فشل تحميل الفيديو، يظهر splash screen عادي
- يستخدم الصورة والـ gradient كبديل

## 📱 الخطوات المتبقية:

### 1. إضافة الفيديو
ضع ملف الفيديو `splash.mp4` في:
```
assets/videos/splash.mp4
```

### 2. تشغيل التطبيق
```bash
flutter run
```

## 🔧 إعدادات الأمان:

### Android ✅
- الأذونات موجودة بالفعل في `AndroidManifest.xml`
- `android.permission.INTERNET` مضاف

### iOS ✅
- إعدادات `NSAppTransportSecurity` موجودة في `Info.plist`
- `NSAllowsArbitraryLoads` مفعل

## 🎯 كيفية عمل الكود:

### 1. تهيئة الفيديو
```dart
void _initializeVideo() async {
  try {
    _videoController = VideoPlayerController.asset('assets/videos/splash.mp4');
    await _videoController!.initialize();
    await _videoController!.setLooping(true);
    await _videoController!.play();
  } catch (e) {
    // Fallback to image splash
  }
}
```

### 2. عرض الفيديو
```dart
Widget _buildVideoSplash() {
  return Stack(
    children: [
      // Video Background
      VideoPlayer(_videoController!),
      // Logo and Progress Overlay
      Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(child: /* Logo and Progress */),
      ),
    ],
  );
}
```

## 🚨 استكشاف الأخطاء:

### إذا لم يظهر الفيديو:
1. **تأكد من وجود الملف**: `assets/videos/splash.mp4`
2. **تحقق من Console**: ابحث عن أخطاء في التهيئة
3. **تأكد من صيغة الفيديو**: MP4 متوافق
4. **حجم الفيديو**: تأكد من أن الحجم معقول

### رسائل الخطأ الشائعة:
- `File not found`: تأكد من المسار الصحيح
- `Video format not supported`: تأكد من صيغة MP4
- `Permission denied`: الأذونات موجودة بالفعل

## 📊 تحسينات الأداء:

1. **ضغط الفيديو**: استخدم فيديو مضغوط لتقليل الحجم
2. **مدة الفيديو**: يفضل أن تكون قصيرة (3-5 ثواني)
3. **دقة الفيديو**: استخدم دقة مناسبة للهواتف

## 🎨 تخصيص إضافي:

يمكنك تخصيص:
- شفافية الطبقة السوداء: `Colors.black.withOpacity(0.3)`
- حجم الشعار: `width: 180, height: 180`
- لون مؤشر التحميل: `Colors.white`
- موضع العناصر: `MainAxisAlignment.center`

## ✅ اختبار التطبيق:

1. شغل التطبيق: `flutter run`
2. تأكد من ظهور الفيديو
3. تحقق من الانتقال السلس للشاشة التالية
4. اختبر على أجهزة مختلفة

---

**ملاحظة**: إذا لم يكن لديك فيديو `splash.mp4`، سيظهر splash screen عادي بالصورة كبديل.
