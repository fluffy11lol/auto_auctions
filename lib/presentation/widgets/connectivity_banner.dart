import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<ConnectivityResult?>();

    final bool isOffline = status == ConnectivityResult.none;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 35 : 0,
      width: double.infinity,
      color: Colors.orange,
      clipBehavior: Clip.hardEdge,
      child: isOffline
          ? const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Offline Mode: Data from cache',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
