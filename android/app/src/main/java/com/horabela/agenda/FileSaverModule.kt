package com.horabela.agenda

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import android.util.Base64
import java.io.FileOutputStream

class FileSaverModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "FileSaver"
    }

    @ReactMethod
    fun saveFile(base64: String, fileName: String) {
        try {
            val data = Base64.decode(base64, Base64.DEFAULT)
            val out = FileOutputStream("${reactApplicationContext.filesDir}/$fileName")
            out.write(data)
            out.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}