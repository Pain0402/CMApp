import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, String message) {
    _showGlassFlushbar(
      context: context,
      message: message,
      icon: Icons.check_circle_outline,
      color: Colors.greenAccent,
    );
  }

  static void showError(BuildContext context, String message) {
    _showGlassFlushbar(
      context: context,
      message: message,
      icon: Icons.error_outline,
      color: Colors.redAccent,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showGlassFlushbar(
      context: context,
      message: message,
      icon: Icons.info_outline,
      color: Colors.lightBlueAccent,
    );
  }

  static void _showGlassFlushbar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Flushbar(
      message: message,
      messageSize: 16,
      messageColor: const Color.fromARGB(255, 0, 0, 0),
      
      icon: Icon(
        icon,
        size: 28.0,
        color: color,
      ),
      
      backgroundColor: const Color.fromARGB(255, 194, 194, 194).withOpacity(0.6),
      barBlur: 20.0, 
      
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      
      flushbarPosition: FlushbarPosition.TOP,
      
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 1200),
      leftBarIndicatorColor: color, 
      
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    ).show(context);
  }
}