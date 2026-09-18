import 'package:flutter/material.dart';
import '../constants/constant.dart';

class CustomCard {
  // ================= HERO CARD (Dark surface for balance/summary) =================
  static Widget hero({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Color? borderColor,
    double borderRadius = 24,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Constant.surfaceDark,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: Constant.shadowMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  // ================= SURFACE CARD (Standard white card) =================
  static Widget surface({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color = Constant.greyLight,
    Color? borderColor,
    double borderRadius = 16,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Constant.surfaceCard,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : Border.all(color: Constant.borderSubtle, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: Constant.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ================= ELEVATED CARD (Legacy - kept for backward compat) =================
  static Widget elevated({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Color? borderColor,
    double elevation = 8,
    double borderRadius = 12,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: BoxBorder.all(
          color: borderColor ?? Colors.grey.shade200,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: elevation,
            offset: const Offset(6, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ================= OUTLINED CARD =================
  static Widget outlined({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Color? borderColor,
    double borderWidth = 1,
    double borderRadius = 12,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE0E0E0),
          width: borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ================= FILLED CARD (Legacy) =================
  static Widget filled({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double borderRadius = 12,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ================= IMAGE CARD =================
  static Widget image({
    required Widget child,
    required String imageUrl,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double height = 200,
    double borderRadius = 12,
    BoxFit imageFit = BoxFit.cover,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
                  height: height,
                  width: double.infinity,
                  fit: imageFit,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: height,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
                Container(
                  color: Colors.white,
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
