import 'package:danamoo/generated/assets.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const AuthHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 16,
        24,
        28,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF15161A), // ganti ke konstanta hitam di Constant
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            Assets.assetsImagesLogoHorizontalWhite,
            height: 38,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          if (title != null) ...[
            const SizedBox(height: 28),
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
