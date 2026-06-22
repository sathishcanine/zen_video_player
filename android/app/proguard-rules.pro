# Meta Audience Network (AdMob mediation) — compile-time annotations not needed at runtime.
-dontwarn com.facebook.infer.annotation.Nullsafe

# Firebase Cloud Messaging + local notifications (release shrinker safety).
-keep class com.google.firebase.messaging.** { *; }
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
