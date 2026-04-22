import 'dart:async';
import 'dart:io'; // Для проверки InternetAddress
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isRealOffline = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _performRealCheck();

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _performRealCheck();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _performRealCheck();
    });
  }

  Future<void> _performRealCheck() async {
    bool isOffline;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOffline = false;
      } else {
        isOffline = true;
      }
    } on SocketException catch (_) {
      isOffline = true;
    } on TimeoutException catch (_) {
      isOffline = true;
    } catch (e) {
      isOffline = true;
    }

    if (mounted && _isRealOffline != isOffline) {
      debugPrint('REAL INTERNET CHECK: ${isOffline ? "OFFLINE" : "ONLINE"}');
      setState(() {
        _isRealOffline = isOffline;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isRealOffline ? 35 : 0,
      width: double.infinity,
      color: Colors.orange,
      clipBehavior: Clip.hardEdge,
      child: _isRealOffline
          ? const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.white, size: 14),
            SizedBox(width: 8),
            Text(
              'Offline Mode: Data from cache',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}