import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
    Color textColor = Colors.white,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.top,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    double topPosition;
    switch (position) {
      case ToastPosition.top:
        topPosition = MediaQuery.of(context).padding.top + 20.h;
        break;
      case ToastPosition.center:
        topPosition = MediaQuery.of(context).size.height / 2 - 30.h;
        break;
      case ToastPosition.bottom:
        topPosition = MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.bottom - 80.h;
        break;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green[600]!,
      icon: Icons.check_circle,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red[600]!,
      icon: Icons.error,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.orange[600]!,
      icon: Icons.warning,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.blue[600]!,
      icon: Icons.info,
    );
  }
}

enum ToastPosition {
  top,
  center,
  bottom,
}
