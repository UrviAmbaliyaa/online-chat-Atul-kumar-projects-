# Oppo Push
-keep class com.heytap.msp.push.HeytapPushManager { *; }
-keep class com.heytap.msp.push.callback.ICallBackResultService { *; }

# Meizu Push
-keep class com.meizu.cloud.pushsdk.PushManager { *; }
-keep class com.meizu.cloud.pushsdk.util.MzSystemUtils { *; }

# Vivo Push
-keep class com.vivo.push.IPushActionListener { *; }
-keep class com.vivo.push.PushClient { *; }
-keep class com.vivo.push.PushConfig { *; }
-keep class com.vivo.push.PushConfig$Builder { *; }
-keep class com.vivo.push.util.VivoPushException { *; }

# Xiaomi Push
-keep class com.xiaomi.mipush.sdk.MiPushClient { *; }

# If you're using Hyphenate/环信 SDK
-keep class com.hyphenate.** { *; }
-dontwarn com.hyphenate.**