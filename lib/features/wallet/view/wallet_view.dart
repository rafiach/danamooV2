import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/wallet_selector.dart';
import '../../../data/models/wallet_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/wallet_provider.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<WalletProvider>().load(user);
    });
  }

  Future<void> _openForm({WalletModel? wallet}) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final provider = context.read<WalletProvider>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletFormSheet(
        wallet: wallet,
        onSave: (name, iconKey, initialBalance) {
          if (wallet == null) {
            return provider.add(
              user,
              name: name,
              iconKey: iconKey,
              initialBalance: initialBalance,
            );
          }
          return provider.update(
            user,
            wallet.copyWith(name: name, iconKey: iconKey),
          );
        },
        onDelete: (wallet == null || wallet.isMain)
            ? null
            : () => _confirmDelete(wallet),
      ),
    );
  }

  void _confirmDelete(WalletModel wallet) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final balance = context.read<WalletProvider>().balanceOf(wallet.id);

    Utils.showWarningDialog(
      context,
      title: 'Hapus Dompet',
      content:
          'Dompet "${wallet.name}" akan dilebur ke Dompet Utama. '
          'Sisa saldo ${Utils.formatIDR(balance)} beserta seluruh transaksinya '
          'ikut dipindahkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      onConfirm: () async {
        if (!mounted) return;
        await context.read<WalletProvider>().delete(user, wallet.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Dompet',
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.bgNeutral,
        foregroundColor: Constant.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading && provider.wallets.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Constant.limeAccentDark,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.wallets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final w = provider.wallets[i];
                      return CustomCard.surface(
                        borderRadius: 16,
                        onTap: () => _openForm(wallet: w),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Constant.limeAccent.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                WalletIcons.of(w.iconKey),
                                size: 20,
                                color: Constant.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name,
                                    style: Constant.textSemiBold.copyWith(
                                      color: Constant.textPrimary,
                                    ),
                                  ),
                                  if (w.isMain)
                                    Text('Utama', style: Constant.caption),
                                ],
                              ),
                            ),
                            Text(
                              Utils.formatIDR(provider.balanceOf(w.id)),
                              style: Constant.textSemiBold.copyWith(
                                color: Constant.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: CustomButton.mainButton(
                label: 'Tambah Dompet',
                color: Constant.surfaceDark,
                textColor: Constant.limeAccent,
                fontWeight: FontWeight.w800,
                height: 56,
                borderRadius: 16,
                onPressed: () => _openForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= FORM SHEET (tambah / edit) =================
class _WalletFormSheet extends StatefulWidget {
  final WalletModel? wallet;
  final Future<bool> Function(
    String name,
    String iconKey,
    double initialBalance,
  )
  onSave;
  final VoidCallback? onDelete;

  const _WalletFormSheet({
    required this.wallet,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<_WalletFormSheet> {
  static const _iconKeys = ['wallet', 'cash', 'bank', 'card', 'phone'];

  late final TextEditingController _nameController;
  final _balanceController = TextEditingController();
  late String _iconKey;
  bool _saving = false;

  bool get _isEdit => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _iconKey = widget.wallet?.iconKey ?? 'wallet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final raw = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final balance = double.tryParse(raw) ?? 0;

    setState(() => _saving = true);
    final ok = await widget.onSave(name, _iconKey, balance);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Constant.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEdit ? 'Edit Dompet' : 'Dompet Baru',
            style: Constant.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField.standard(
            controller: _nameController,
            label: 'Nama',
            hint: 'Contoh: BCA, Cash, GoPay',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          if (!_isEdit) ...[
            CustomTextField.standard(
              controller: _balanceController,
              label: 'Saldo Awal',
              hint: '0',
              prefixText: 'Rp  ',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text('Ikon', style: Constant.textSemiBold),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _iconKeys.map((k) {
              final selected = k == _iconKey;
              return GestureDetector(
                onTap: () => setState(() => _iconKey = k),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? Constant.surfaceDark : Constant.greyLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    WalletIcons.of(k),
                    color: selected
                        ? Constant.limeAccent
                        : Constant.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          CustomButton.mainButton(
            label: 'Simpan',
            color: Constant.surfaceDark,
            textColor: Constant.limeAccent,
            fontWeight: FontWeight.w800,
            height: 52,
            borderRadius: 16,
            isLoading: _saving,
            onPressed: _submit,
          ),
          if (widget.onDelete != null) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete!();
                },
                child: Text(
                  'Hapus Dompet',
                  style: Constant.textMedium.copyWith(
                    color: Constant.expenseRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
