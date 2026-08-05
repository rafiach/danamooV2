import 'package:flutter/material.dart';

class CustomEmptyState {
  // ================= STANDARD EMPTY STATE =================
  static Widget standard({
    IconData? icon,
    String? image,
    required String title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.asset(image, width: 200, height: 200)
            else if (icon != null)
              Icon(icon, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= NO DATA =================
  static Widget noData({String? title, String? description}) {
    return standard(
      icon: Icons.inbox_outlined,
      title: title ?? 'Tidak Ada Data',
      description: description ?? 'Belum ada data untuk ditampilkan',
    );
  }

  // ================= NO SEARCH RESULT =================
  static Widget noSearchResult({String? query, String? description}) {
    return standard(
      icon: Icons.search_off,
      title: query != null
          ? 'Hasil untuk "$query" tidak ditemukan'
          : 'Tidak Ada Hasil',
      description: description ?? 'Coba gunakan kata kunci yang berbeda',
    );
  }

  // ================= ERROR STATE =================
  static Widget error({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    return standard(
      icon: Icons.error_outline,
      title: title ?? 'Terjadi Kesalahan',
      description: description ?? 'Terjadi kesalahan saat memuat data',
      buttonText: buttonText ?? 'Coba Lagi',
      onButtonPressed: onRetry,
    );
  }
}
