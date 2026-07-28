# ==============================================================================
# Trydos — قواعد R8 / ProGuard
#
# مُفعَّلة عبر `minifyEnabled true` في build.gradle (release فقط).
# ملاحظة: `shrinkResources` يبقى معطّلاً عمداً — راجع التعليق في build.gradle.
#
# عند إضافة أي مكتبة أصلية جديدة تعتمد على reflection أو على أسماء أصناف نصية،
# أضِف قاعدة keep هنا واختبر بناء release على جهاز فعلي.
# ==============================================================================

# ------------------------------------------------------------------------------
# سمات عامة — مطلوبة للـ reflection ولقراءة آثار المكدّس في Sentry
# ------------------------------------------------------------------------------
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault
# يُبقي آثار المكدّس مقروءة دون كشف مسارات المصدر الأصلية
-renamesourcefileattribute SourceFile

-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
-keep @androidx.annotation.Keep class * { *; }

# Enums — تُقرأ بالاسم في كثير من المكتبات
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable / Serializable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ------------------------------------------------------------------------------
# Flutter — المحرّك وطبقة الاندماج ومُسجّل الإضافات
# ------------------------------------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ------------------------------------------------------------------------------
# كود التطبيق الأصلي (MainActivity وMemoryInfoPlugin) — الحزم الموجودة فعلياً
# ------------------------------------------------------------------------------
-keep class com.example.trydos.** { *; }
-keep class com.trydos.trydos.** { *; }
-keep class com.trydos.www.** { *; }

# ------------------------------------------------------------------------------
# Firebase — messaging / analytics / database / core
# معالج الإشعارات في الخلفية يُستدعى من عزلة منفصلة عبر reflection
# ------------------------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
# نماذج Realtime Database تُبنى عبر reflection
-keep class com.google.firebase.database.** { *; }
-keepclassmembers class * {
    @com.google.firebase.database.PropertyName <methods>;
    @com.google.firebase.database.PropertyName <fields>;
}

# ------------------------------------------------------------------------------
# flutter_local_notifications — يعتمد على Gson لفكّ حمولة الإشعار المجدول
# ------------------------------------------------------------------------------
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.models.** { <fields>; }

# Gson — بلا هذه القواعد تُفقد أنواع الأصناف العامة فتفشل إعادة البناء
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn com.google.gson.**
-dontwarn sun.misc.**

# ------------------------------------------------------------------------------
# flutter_callkit_incoming — واجهة المكالمات الواردة (قاعدة سابقة)
# ------------------------------------------------------------------------------
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

# ------------------------------------------------------------------------------
# pusher_client — مُبقاة من القواعد السابقة (تبعية غير مباشرة)
# ------------------------------------------------------------------------------
-keep class com.github.chinloyal.pusher_client.** { *; }
-dontwarn com.github.chinloyal.pusher_client.**

# ------------------------------------------------------------------------------
# WebView — مكالمات Agora تعمل داخل webview
# ------------------------------------------------------------------------------
-keep class android.webkit.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.pichillilorenzo.** { *; }
-dontwarn com.pichillilorenzo.**

# ------------------------------------------------------------------------------
# Google Maps
# ------------------------------------------------------------------------------
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# ------------------------------------------------------------------------------
# ML Kit — mobile_scanner (قارئ QR)
# ------------------------------------------------------------------------------
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.odml.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.odml.**

# ------------------------------------------------------------------------------
# الوسائط — video_player (Media3/ExoPlayer)، audioplayers، flutter_sound
# ------------------------------------------------------------------------------
-keep class androidx.media3.** { *; }
-keep interface androidx.media3.** { *; }
-dontwarn androidx.media3.**
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
-keep class xyz.luan.audioplayers.** { *; }
-keep class com.dooboolab.** { *; }
-dontwarn com.dooboolab.**

# ------------------------------------------------------------------------------
# Sentry
# ------------------------------------------------------------------------------
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# ------------------------------------------------------------------------------
# PostHog
# ------------------------------------------------------------------------------
-keep class com.posthog.** { *; }
-dontwarn com.posthog.**

# ------------------------------------------------------------------------------
# التخزين الآمن — flutter_secure_storage (AndroidX Security / Tink)
# ------------------------------------------------------------------------------
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# ------------------------------------------------------------------------------
# صور/ملفات/أذونات — wechat_assets_picker، file_picker، permission_handler، geocoding
# ------------------------------------------------------------------------------
-keep class com.fluttercandies.** { *; }
-dontwarn com.fluttercandies.**
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**

# ------------------------------------------------------------------------------
# الموقع — location plugin
# ------------------------------------------------------------------------------
-keep class com.lyokone.location.** { *; }
-dontwarn com.lyokone.location.**

# ------------------------------------------------------------------------------
# جهات الاتصال — fast_contacts
# ------------------------------------------------------------------------------
-keep class com.github.s0nerik.fast_contacts.** { *; }
-dontwarn com.github.s0nerik.fast_contacts.**

# ------------------------------------------------------------------------------
# Lottie
# ------------------------------------------------------------------------------
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# ------------------------------------------------------------------------------
# Kotlin — البيانات الوصفية والكوروتينات
# ------------------------------------------------------------------------------
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings { <fields>; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
-dontwarn kotlin.**

# ------------------------------------------------------------------------------
# OkHttp / Okio — تبعيات غير مباشرة لعدة إضافات
# ------------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# ------------------------------------------------------------------------------
# Play Core — R8 يشتكي من غيابها عند عدم استخدام deferred components
# ------------------------------------------------------------------------------
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ------------------------------------------------------------------------------
# تحذيرات مُولَّدة تلقائياً من Android Gradle Plugin (قواعد سابقة)
# ------------------------------------------------------------------------------
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn androidx.window.**
