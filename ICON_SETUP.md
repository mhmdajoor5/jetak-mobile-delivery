# إعداد أيقونة التطبيق

## الوضع الحالي
تم إعداد `flutter_launcher_icons` بنجاح وإنشاء الأيقونات المؤقتة لكل من iOS و Android.

## الملفات المطلوبة لاستبدال الأيقونة

### الأيقونة الأساسية
- **المسار**: `assets/img/new_logo.png`
- **الحجم المطلوب**: 1024x1024 بكسل
- **التنسيق**: PNG مع دعم الشفافية

## كيفية استبدال الأيقونة

### الخطوة 1: استبدال الأيقونة الأساسية
1. استبدل ملف `assets/img/new_logo.png` بأيقونة التطبيق النهائية
2. تأكد من أن الأيقونة بحجم 1024x1024 بكسل
3. استخدم تنسيق PNG مع خلفية شفافة

### الخطوة 2: إعادة توليد الأيقونات
```bash
flutter pub run flutter_launcher_icons
```

## المجلدات المُنشأة

### iOS
- **المسار**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **المحتويات**: جميع أحجام الأيقونات المطلوبة لـ iOS
- **الملف الرئيسي**: `Contents.json` (يحتوي على إعدادات الأيقونات)

### Android
- **المسار**: `android/app/src/main/res/`
- **المجلدات المُنشأة**:
  - `mipmap-hdpi/` - `mipmap-mdpi/` - `mipmap-xhdpi/` - `mipmap-xxhdpi/` - `mipmap-xxxhdpi/`
  - `drawable-hdpi/` - `drawable-mdpi/` - `drawable-xhdpi/` - `drawable-xxhdpi/` - `drawable-xxxhdpi/`
  - `mipmap-anydpi-v26/` (للأيقونات التكيفية)
  - `values/` (ملف colors.xml)

## ملاحظات مهمة

### للأيقونات مع قناة ألفا (شفافية)
إذا كانت أيقونتك تحتوي على شفافية، أضف هذا السطر في `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  remove_alpha_ios: true
```

### للأيقونات التكيفية في Android
تم إعداد الأيقونات التكيفية تلقائياً مع:
- خلفية بيضاء (`#FFFFFF`)
- الأيقونة الأمامية من `assets/img/new_logo.png`

## التحقق من النتيجة
بعد استبدال الأيقونة وإعادة التوليد:
1. شغل التطبيق على iOS Simulator
2. شغل التطبيق على Android Emulator
3. تحقق من ظهور الأيقونة الجديدة في قائمة التطبيقات

## استكشاف الأخطاء
إذا واجهت مشاكل:
1. تأكد من أن الأيقونة بحجم 1024x1024 بكسل
2. تأكد من تنسيق PNG
3. تأكد من عدم وجود أخطاء في `pubspec.yaml`
4. جرب حذف مجلد `build/` وإعادة البناء
