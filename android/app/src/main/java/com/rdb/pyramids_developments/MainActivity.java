package com.rdb.pyramids_developments;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.window.SplashScreenView;
import androidx.core.view.WindowCompat;

import io.flutter.embedding.android.FlutterActivity;

import android.view.WindowManager;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;



public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            getSplashScreen()
                    .setOnExitAnimationListener(
                            (SplashScreenView splashScreenView) -> {
                                splashScreenView.remove();
                            });
        }
        super.onCreate(savedInstanceState);

        //getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);

        MethodChannel channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "no_snaps_allowed");
        channel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("preventScreenshots")) {
//                Boolean prevent = call.argument("prevent") != null && call.argument("prevent");
                Boolean prevent = call.argument("prevent");


                if (call.argument("prevent") != null && prevent) {
                    getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
                } else {
                    getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
                }
            }
        });



    }
}
