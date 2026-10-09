import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/utils.dart';
import '../../model/home_model.dart';
import 'hero_wallet_card.dart'; // sesuaikan path file HeroWalletCard

class HeroWalletCarousel extends StatefulWidget {
  final HomeModel? data;
  const HeroWalletCarousel({super.key, required this.data});

  @override
  State<HeroWalletCarousel> createState() => _HeroWalletCarouselState();
}

class _HeroWalletCarouselState extends State<HeroWalletCarousel> {
  final _controller = PageController();
  int _page = 0;

  IconData _iconFor(String key) {
    switch (key) {
      case 'cash':
        return LucideIcons.banknote;
      case 'bank':
        return LucideIcons.landmark;
      case 'card':
        return LucideIcons.creditCard;
      case 'phone':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.walletMinimal;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final wallets = d?.walletItems ?? [];

    // Slide 0 = total semua dompet, sisanya per dompet
    final slides = <Widget>[
      HeroWalletCard(
        label: 'Total saldo',
        balance: Utils.formatIDR(d?.balance ?? 0),
        income: Utils.formatIDR(d?.totalIncome ?? 0),
        expense: Utils.formatIDR(d?.totalExpense ?? 0),
        icon: Icons.account_balance_wallet,
      ),
      ...wallets.map(
        (w) => HeroWalletCard(
          label: w.wallet.name,
          balance: Utils.formatIDR(w.balance),
          income: Utils.formatIDR(w.income),
          expense: Utils.formatIDR(w.expense),
          icon: _iconFor(w.wallet.iconKey),
          accent: Color(w.wallet.colorValue),
        ),
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double page = _page.toDouble();
                if (_controller.hasClients &&
                    _controller.position.haveDimensions) {
                  page = _controller.page ?? page;
                }
                final dist = (page - i).abs().clamp(0.0, 0.1);
                return Opacity(opacity: 1 - dist, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: slides[i],
              ),
            ),
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: Constant.durationShort,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? Constant.limeAccent
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
