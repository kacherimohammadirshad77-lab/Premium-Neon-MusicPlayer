# Keep just_audio / audio_service / media classes from being stripped.
-keep class com.ryanheise.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
