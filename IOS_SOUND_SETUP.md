# إعداد الصوت للأيفون 🔊

## الخطوات المطلوبة لإضافة الصوت في الأيفون:

### 1. إضافة ملف الصوت إلى Xcode:
1. افتح مشروع Xcode: `ios/Runner.xcworkspace`
2. انقر بزر الماوس الأيمن على مجلد `Runner` في Project Navigator
3. اختر `Add Files to "Runner"`
4. اختر ملف `assets/notification_sound.wav`
5. تأكد من تحديد `Add to target: Runner`
6. انقر على `Add`

### 2. التحقق من إعدادات Bundle:
1. في Xcode، اختر `Runner` target
2. اذهب إلى `Build Phases`
3. تأكد من أن ملف الصوت موجود في `Copy Bundle Resources`

### 3. إعدادات Info.plist:
تم إضافة الإعدادات التالية تلقائياً:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>

<key>AVAudioSessionCategory</key>
<string>AVAudioSessionCategoryPlayback</string>
```

### 4. اختبار الصوت:
1. شغل التطبيق على الأيفون
2. اذهب إلى صفحة الإعدادات
3. اضغط على زر "اختبار الأيفون"
4. تأكد من أن الصوت يعمل

### 5. إعدادات الجهاز:
تأكد من:
- تفعيل الإشعارات للتطبيق
- تفعيل الصوت في إعدادات الإشعارات
- عدم تفعيل وضع عدم الإزعاج

### 6. استكشاف الأخطاء:
إذا لم يعمل الصوت:
1. تحقق من مستوى الصوت في الجهاز
2. تأكد من عدم تفعيل وضع الطيران
3. أعد تشغيل التطبيق
4. تحقق من سجلات Xcode للأخطاء

## ملاحظات مهمة:
- ملف الصوت يجب أن يكون بصيغة `.wav` أو `.aiff`
- حجم الملف يجب أن يكون أقل من 5MB
- الصوت سيعمل في الخلفية إذا تم إضافة `audio` إلى `UIBackgroundModes`
