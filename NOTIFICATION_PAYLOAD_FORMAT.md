# iOS Push Notifications - Correct Payload Format

## ⚠️ Critical Issue: Notifications Not Received in Background

If notifications work when the app is **open** but NOT when the app is **closed/background**, the issue is usually the **notification payload format** sent from the backend.

---

## ✅ Correct Notification Payload Format

Your backend MUST send notifications in this **exact format** for iOS to deliver them in background:

### Format 1: FCM HTTP v1 API (RECOMMENDED)

```json
{
  "message": {
    "token": "USER_FCM_TOKEN_HERE",
    "notification": {
      "title": "طلب توصيل جديد!",
      "body": "لديك طلب جديد من أحمد"
    },
    "data": {
      "order_id": "12345",
      "customer_name": "أحمد",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "apns": {
      "headers": {
        "apns-priority": "10",
        "apns-push-type": "alert"
      },
      "payload": {
        "aps": {
          "alert": {
            "title": "طلب توصيل جديد!",
            "body": "لديك طلب جديد من أحمد"
          },
          "sound": "default",
          "badge": 1,
          "content-available": 1,
          "mutable-content": 1
        }
      }
    },
    "android": {
      "priority": "high",
      "notification": {
        "sound": "default",
        "channel_id": "alerts"
      }
    }
  }
}
```

### Format 2: FCM Legacy API (if still using old format)

```json
{
  "to": "USER_FCM_TOKEN_HERE",
  "priority": "high",
  "notification": {
    "title": "طلب توصيل جديد!",
    "body": "لديك طلب جديد من أحمد",
    "sound": "default",
    "badge": "1"
  },
  "data": {
    "order_id": "12345",
    "customer_name": "أحمد",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "content_available": true,
  "mutable_content": true
}
```

---

## 🔑 Critical Fields Explained

### For Background Delivery on iOS:

1. **`notification` object is REQUIRED**
   - Must contain `title` and `body`
   - iOS will NOT show notification without this

2. **`apns.payload.aps.content-available: 1`**
   - Allows app to wake up in background
   - Essential for background delivery

3. **`apns.headers.apns-priority: "10"`**
   - Priority 10 = immediate delivery
   - Priority 5 = power-saving mode (delayed)

4. **`apns.headers.apns-push-type: "alert"`**
   - Required for iOS 13+
   - Must match notification type

5. **`data` object (optional but recommended)**
   - Contains custom data (order_id, etc.)
   - Available in Flutter when notification is tapped

---

## ❌ Common Backend Mistakes

### Mistake 1: Sending Data-Only Message
```json
❌ WRONG - Will NOT show in background
{
  "to": "token",
  "data": {
    "title": "New Order",
    "body": "You have an order"
  }
}
```

**Why it fails:** iOS requires the `notification` field for background delivery.

---

### Mistake 2: Missing APNs Configuration
```json
❌ WRONG - May not work reliably on iOS
{
  "to": "token",
  "notification": {
    "title": "New Order",
    "body": "You have an order"
  }
}
```

**Why it fails:** Missing iOS-specific settings like `content-available`.

---

### Mistake 3: Wrong Priority
```json
❌ WRONG - Will be delayed
{
  "to": "token",
  "priority": "normal",
  ...
}
```

**Why it fails:** Normal priority may delay or not wake the app.

---

## 📱 Backend Code Examples

### PHP (using Firebase Admin SDK)

```php
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\ApnsConfig;

$factory = (new Factory)->withServiceAccount('/path/to/firebase-credentials.json');
$messaging = $factory->createMessaging();

$deviceToken = 'USER_FCM_TOKEN_FROM_DATABASE';

$message = CloudMessage::withTarget('token', $deviceToken)
    ->withNotification(Notification::create(
        'طلب توصيل جديد!',  // title
        'لديك طلب جديد من أحمد'  // body
    ))
    ->withData([
        'order_id' => '12345',
        'customer_name' => 'أحمد',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ])
    ->withApnsConfig(
        ApnsConfig::new()
            ->withHeaders([
                'apns-priority' => '10',
                'apns-push-type' => 'alert'
            ])
            ->withPayload([
                'aps' => [
                    'sound' => 'default',
                    'badge' => 1,
                    'content-available' => 1,
                    'mutable-content' => 1
                ]
            ])
    );

try {
    $messaging->send($message);
    echo "✅ Notification sent successfully\n";
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
```

---

### Node.js (using Firebase Admin SDK)

```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./path/to/firebase-credentials.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const deviceToken = 'USER_FCM_TOKEN_FROM_DATABASE';

const message = {
  token: deviceToken,
  notification: {
    title: 'طلب توصيل جديد!',
    body: 'لديك طلب جديد من أحمد'
  },
  data: {
    order_id: '12345',
    customer_name: 'أحمد',
    click_action: 'FLUTTER_NOTIFICATION_CLICK'
  },
  apns: {
    headers: {
      'apns-priority': '10',
      'apns-push-type': 'alert'
    },
    payload: {
      aps: {
        alert: {
          title: 'طلب توصيل جديد!',
          body: 'لديك طلب جديد من أحمد'
        },
        sound: 'default',
        badge: 1,
        'content-available': 1,
        'mutable-content': 1
      }
    }
  },
  android: {
    priority: 'high'
  }
};

admin.messaging().send(message)
  .then((response) => {
    console.log('✅ Notification sent successfully:', response);
  })
  .catch((error) => {
    console.log('❌ Error sending notification:', error);
  });
```

---

### Python (using Firebase Admin SDK)

```python
import firebase_admin
from firebase_admin import credentials, messaging

# Initialize Firebase Admin
cred = credentials.Certificate('/path/to/firebase-credentials.json')
firebase_admin.initialize_app(cred)

device_token = 'USER_FCM_TOKEN_FROM_DATABASE'

message = messaging.Message(
    token=device_token,
    notification=messaging.Notification(
        title='طلب توصيل جديد!',
        body='لديك طلب جديد من أحمد'
    ),
    data={
        'order_id': '12345',
        'customer_name': 'أحمد',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    },
    apns=messaging.APNSConfig(
        headers={
            'apns-priority': '10',
            'apns-push-type': 'alert'
        },
        payload=messaging.APNSPayload(
            aps=messaging.Aps(
                alert=messaging.ApsAlert(
                    title='طلب توصيل جديد!',
                    body='لديك طلب جديد من أحمد'
                ),
                sound='default',
                badge=1,
                content_available=True,
                mutable_content=True
            )
        )
    ),
    android=messaging.AndroidConfig(
        priority='high'
    )
)

try:
    response = messaging.send(message)
    print(f'✅ Notification sent successfully: {response}')
except Exception as e:
    print(f'❌ Error sending notification: {e}')
```

---

## 🧪 Testing Notifications

### Test from Firebase Console

1. Go to Firebase Console → Engage → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Paste the FCM token from your app
6. Send the test

**Test in 3 states:**
- ✅ App in foreground
- ✅ App in background (home button pressed)
- ✅ App terminated (swiped away)

---

## 🔍 Debugging Backend Issues

### Check FCM Response

When sending notifications, log the FCM response:

```php
$result = $messaging->send($message);
var_dump($result); // Check for errors
```

Common error codes:
- `UNREGISTERED` / `NOT_FOUND` → Token is invalid/expired
- `INVALID_ARGUMENT` → Wrong payload format
- `SENDER_ID_MISMATCH` → Wrong Firebase project

---

### Handle Invalid Tokens

```php
try {
    $messaging->send($message);
} catch (\Kreait\Firebase\Exception\Messaging\NotFound $e) {
    // Token not found - remove from database
    echo "Token invalid, removing from database\n";
    // DELETE FROM users WHERE device_token = ?
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

---

## 📋 Backend Checklist

Before sending notifications, verify:

- [ ] Using Firebase Admin SDK (not REST API directly)
- [ ] `notification` object included with `title` and `body`
- [ ] `apns.headers.apns-priority` set to `"10"`
- [ ] `apns.headers.apns-push-type` set to `"alert"`
- [ ] `apns.payload.aps.content-available` set to `1`
- [ ] `priority` set to `"high"` (for Android)
- [ ] Valid FCM token from database
- [ ] Handle `UNREGISTERED`/`NOT_FOUND` errors
- [ ] Firebase project matches mobile app
- [ ] APNs authentication key uploaded to Firebase

---

## 🎯 Quick Fix Summary

**If notifications don't appear in background:**

1. ✅ Update AppDelegate.swift (already done in mobile app)
2. ✅ Add notification handlers (already done)
3. ⚠️ **Fix backend payload format** (backend team must do this)
4. ✅ Ensure `notification` object is present in payload
5. ✅ Add iOS-specific APNs configuration
6. ✅ Set `apns-priority: "10"` and `content-available: 1`

**The mobile app is now ready. The backend needs to send the correct payload format!**

---

## 📞 Need Help?

If notifications still don't work after updating the backend:

1. Check Xcode console logs when notification is sent
2. Look for "📩 Remote Notification Received" logs
3. Verify notification appears in iOS Notification Center
4. Check Firebase Console → Cloud Messaging → Reports for delivery stats
5. Ensure user hasn't disabled notifications in iOS Settings
