import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/category_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../../home/provider/home_provider.dart';
import '../provider/category_prvider.dart';

class CategoryManageView extends StatelessWidget {
  const CategoryManageView({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<CategoryProvider>(); // rebuild setelah rename

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Kelola Kategori',
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => CustomNavigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, 'PEMASUKAN', CategoryModel.incomeCategories),
          const SizedBox(height: 20),
          _section(context, 'PENGELUARAN', CategoryModel.expenseCategories),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String label,
    List<CategoryModel> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Constant.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        CustomCard.surface(
          padding: EdgeInsets.zero,
          child: Column(
            children: items
                .map(
                  (c) => ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: c.icon),
                    ),
                    title: Text(c.name, style: Constant.textSemiBold),
                    trailing: const Icon(LucideIcons.pencilLine, size: 20),
                    onTap: () => _edit(context, c),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, CategoryModel c) async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(category: c),
    );
    if (result == null || !context.mounted) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final provider = context.read<CategoryProvider>();

    // Peringatan kalau sudah ada transaksi
    final count = await provider.countUsage(user.id, c.id);
    if (!context.mounted) return;
    if (count > 0) {
      final ok = await Utils.showConfirmDialog(
        context,
        title: 'Ubah Kategori?',
        content:
            '$count transaksi memakai kategori "${c.name}". Semua transaksi '
            'tersebut, termasuk yang lama, akan ikut tampil dengan nama dan '
            'ikon baru. Lanjutkan?',
        confirmText: 'Ubah',
      );
      if (ok != true || !context.mounted) return;
    }

    if (result.reset) {
      await provider.reset(c.id);
    } else {
      await provider.save(
        categoryId: c.id,
        name: result.name,
        iconKey: result.iconKey,
      );
    }
    if (!context.mounted) return;

    context.read<HomeProvider>().fetchData(user); // Home cache label/ikon
    Utils.showSuccessSnackbar(context, 'Kategori diperbarui');
  }
}

class _EditResult {
  final String name;
  final String? iconKey;
  final bool reset;
  _EditResult({required this.name, this.iconKey, this.reset = false});
}

class _EditSheet extends StatefulWidget {
  final CategoryModel category;
  const _EditSheet({required this.category});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _nameController;
  String? _iconKey;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    // Cocokkan ikon saat ini dengan daftar pilihan
    for (final e in CategoryModel.iconOptions.entries) {
      if (e.value == widget.category.icon.icon) {
        _iconKey = e.key;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final error = context.read<CategoryProvider>().validateName(
      widget.category,
      _nameController.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(
      context,
      _EditResult(name: _nameController.text.trim(), iconKey: _iconKey),
    );
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
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Constant.greyMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Ubah Kategori', style: Constant.h6),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: InputDecoration(
                labelText: 'Nama kategori',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 8),
            Text('Ikon', style: Constant.textSemiBold),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CategoryModel.iconOptions.entries.map((e) {
                final selected = e.key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = e.key),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? Constant.limeAccentDark.withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? Constant.limeAccentDark
                            : Constant.borderSubtle,
                        width: selected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(e.value, color: Constant.textPrimary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomButton.mainButton(
              label: 'Simpan',
              color: Constant.surfaceDark,
              textColor: Constant.limeAccent,
              height: 52,
              borderRadius: 16,
              onPressed: _submit,
            ),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pop(context, _EditResult(name: '', reset: true)),
                child: const Text('Kembalikan ke default'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
