package com.securenet

import android.content.Context
import android.net.wifi.WifiManager
import android.text.format.Formatter
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*

/**
 * Native Network Scanner Module for Android
 * Provides ARP table scanning and network information
 */
class NetworkScannerModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "NetworkScanner"
    }

    /**
     * Get local network information
     */
    @ReactMethod
    fun getLocalNetworkInfo(promise: Promise) {
        try {
            val wifiManager = reactApplicationContext
                .applicationContext
                .getSystemService(Context.WIFI_SERVICE) as WifiManager
            
            val ipAddress = Formatter.formatIpAddress(wifiManager.connectionInfo.ipAddress)
            val dhcpInfo = wifiManager.dhcpInfo
            
            val networkInfo = Arguments.createMap()
            networkInfo.putString("ipAddress", ipAddress)
            networkInfo.putString("gateway", Formatter.formatIpAddress(dhcpInfo.gateway))
            networkInfo.putString("subnetMask", Formatter.formatIpAddress(dhcpInfo.netmask))
            
            promise.resolve(networkInfo)
        } catch (e: Exception) {
            promise.reject("NETWORK_ERROR", "Failed to get network info: ${e.message}", e)
        }
    }

    /**
     * Scan ARP table for devices
     * Note: This requires reading /proc/net/arp which needs root access
     * For non-root devices, we'll return an empty array
     */
    @ReactMethod
    fun scanARPTable(promise: Promise) {
        try {
            val devices = Arguments.createArray()
            
            // Try to read ARP table
            // This is a simplified implementation
            // In production, you might need root access or use alternative methods
            try {
                val arpFile = java.io.File("/proc/net/arp")
                if (arpFile.exists() && arpFile.canRead()) {
                    arpFile.readLines().forEachIndexed { index, line ->
                        if (index > 0) { // Skip header
                            val parts = line.trim().split(Regex("\\s+"))
                            if (parts.size >= 6) {
                                val ip = parts[0]
                                val mac = parts[3]
                                
                                if (mac != "00:00:00:00:00:00" && ip.isNotEmpty()) {
                                    val device = Arguments.createMap()
                                    device.putString("ip_address", ip)
                                    device.putString("mac_address", mac)
                                    device.putString("device_name", "Unknown Device")
                                    device.putString("vendor", "Unknown")
                                    devices.pushMap(device)
                                }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // ARP table might not be accessible without root
                // Return empty array
            }
            
            promise.resolve(devices)
        } catch (e: Exception) {
            promise.reject("SCAN_ERROR", "Failed to scan ARP table: ${e.message}", e)
        }
    }

    /**
     * Scan ports on a device
     */
    @ReactMethod
    fun scanPorts(ipAddress: String, ports: ReadableArray, promise: Promise) {
        try {
            val openPorts = Arguments.createArray()
            
            // Port scanning implementation
            // This is a basic TCP connection test
            for (i in 0 until ports.size()) {
                val port = ports.getInt(i)
                try {
                    val socket = java.net.Socket()
                    socket.connect(java.net.InetSocketAddress(ipAddress, port), 1000)
                    socket.close()
                    openPorts.pushInt(port)
                } catch (e: Exception) {
                    // Port is closed or filtered
                }
            }
            
            promise.resolve(openPorts)
        } catch (e: Exception) {
            promise.reject("PORT_SCAN_ERROR", "Failed to scan ports: ${e.message}", e)
        }
    }
}
