package com.lane_dane.lane_dane

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable support for Splash Screen API for
        // proper Android 12+ support
        installSplashScreen()
    }


}

