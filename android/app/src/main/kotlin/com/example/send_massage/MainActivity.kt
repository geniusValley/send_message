package com.example.send_massage

import android.os.Build
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val message = call.argument<String>("message")
                val phoneNumber = call.argument<String>("phoneNumber")
                val simSlot = call.argument<Int>("simSlot") ?: 0

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                    try {
                        val subscriptionManager = getSystemService(SubscriptionManager::class.java)
                        val subscriptionInfo = subscriptionManager.getActiveSubscriptionInfoForSimSlotIndex(simSlot)
                        val smsManager = SmsManager.getSmsManagerForSubscriptionId(subscriptionInfo.subscriptionId)
                        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        result.success("Message sent")
                    } catch (e: Exception) {
                        result.error("SMS_ERROR", "Failed to send SMS: ${e.message}", null)
                    }
                } else {
                    result.error("UNSUPPORTED_VERSION", "Android version not supported", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
