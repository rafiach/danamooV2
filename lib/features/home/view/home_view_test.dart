import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_bottom_sheet.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/constants/constant.dart';
import '../../auth/provider/auth_provider.dart';

class HomeViewTest extends StatelessWidget {
  const HomeViewTest({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Testing'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Buttons'),
              Tab(text: 'Components'),
              Tab(text: 'Account'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ColorsTab(),
            _TypographyTab(),
            _ButtonsTab(),
            _ComponentsTab(),
            _AccountTab(),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// TAB 1 — COLORS
// ================================================================
class _ColorsTab extends StatelessWidget {
  const _ColorsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Constant.paddingAll16,
      children: [
        _sectionTitle('Brand Colors'),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.primaryColor, 'primary'),
          _colorBox(Constant.primaryLight, 'primaryLight'),
          _colorBox(Constant.primaryDark, 'primaryDark'),
        ]),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.secondaryColor, 'secondary'),
          _colorBox(Constant.secondaryLight, 'secondaryLight'),
          _colorBox(Constant.secondaryDark, 'secondaryDark'),
        ]),
        Constant.height8,
        _colorRow([_colorBox(Constant.accentColor, 'accent')]),
        Constant.height16,
        _sectionTitle('Status Colors'),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.success, 'success'),
          _colorBox(Constant.successLight, 'successLight'),
          _colorBox(Constant.successDark, 'successDark'),
        ]),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.warning, 'warning'),
          _colorBox(Constant.warningLight, 'warningLight'),
          _colorBox(Constant.warningDark, 'warningDark'),
        ]),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.error, 'error'),
          _colorBox(Constant.errorLight, 'errorLight'),
          _colorBox(Constant.errorDark, 'errorDark'),
        ]),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.info, 'info'),
          _colorBox(Constant.infoLight, 'infoLight'),
          _colorBox(Constant.infoDark, 'infoDark'),
        ]),
        Constant.height16,
        _sectionTitle('Text Colors'),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.textPrimary, 'textPrimary'),
          _colorBox(Constant.textSecondary, 'textSecondary'),
          _colorBox(Constant.textHint, 'textHint'),
          _colorBox(Constant.textDisabled, 'textDisabled'),
        ]),
        Constant.height16,
        _sectionTitle('Background Colors'),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.bgPrimary, 'bgPrimary', hasBorder: true),
          _colorBox(Constant.bgSecondary, 'bgSecondary'),
          _colorBox(Constant.bgTertiary, 'bgTertiary'),
          _colorBox(Constant.bgDark, 'bgDark'),
        ]),
        Constant.height16,
        _sectionTitle('Grey Scale'),
        Constant.height8,
        _colorRow([
          _colorBox(Constant.greyLight, 'greyLight', hasBorder: true),
          _colorBox(Constant.grey, 'grey'),
          _colorBox(Constant.greyMedium, 'greyMedium'),
          _colorBox(Constant.greyDark, 'greyDark'),
        ]),
        Constant.height32,
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: Constant.h6);
  }

  Widget _colorRow(List<Widget> children) {
    return Row(children: children.map((e) => Expanded(child: e)).toList());
  }

  Widget _colorBox(Color color, String label, {bool hasBorder = false}) {
    return Column(
      children: [
        Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: Constant.radiusMedium,
            border: hasBorder ? Border.all(color: Constant.borderColor) : null,
          ),
        ),
        Text(
          label,
          style: Constant.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Constant.height4,
      ],
    );
  }
}

// ================================================================
// TAB 2 — TYPOGRAPHY
// ================================================================
class _TypographyTab extends StatelessWidget {
  const _TypographyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Constant.paddingAll16,
      children: [
        _typoSection('Heading', [
          _typoRow('h1 · 32 Bold', Constant.h1),
          _typoRow('h2 · 28 Bold', Constant.h2),
          _typoRow('h3 · 24 Bold', Constant.h3),
          _typoRow('h4 · 20 SemiBold', Constant.h4),
          _typoRow('h5 · 18 SemiBold', Constant.h5),
          _typoRow('h6 · 16 SemiBold', Constant.h6),
        ]),
        Constant.height16,
        _typoSection('Body', [
          _typoRow('bodyLarge · 16', Constant.bodyLarge),
          _typoRow('bodyMedium · 14', Constant.bodyMedium),
          _typoRow('bodySmall · 12', Constant.bodySmall),
        ]),
        Constant.height16,
        _typoSection('Weight Variants', [
          _typoRow('textBold · Bold', Constant.textBold),
          _typoRow('textSemiBold · SemiBold', Constant.textSemiBold),
          _typoRow('textMedium · Medium', Constant.textMedium),
          _typoRow('textRegular · Regular', Constant.textRegular),
          _typoRow('textLight · Light', Constant.textLight),
        ]),
        Constant.height16,
        _typoSection('Special', [
          _typoRow('textItalic', Constant.textItalic),
          _typoRow('textUnderline', Constant.textUnderline),
          _typoRow('textLineThrough', Constant.textLineThrough),
        ]),
        Constant.height16,
        _typoSection('Button & Label', [
          _typoRow(
            'buttonLarge',
            Constant.buttonLarge.copyWith(color: Constant.textPrimary),
          ),
          _typoRow(
            'buttonMedium',
            Constant.buttonMedium.copyWith(color: Constant.textPrimary),
          ),
          _typoRow(
            'buttonSmall',
            Constant.buttonSmall.copyWith(color: Constant.textPrimary),
          ),
          _typoRow('caption', Constant.caption),
          _typoRow('captionBold', Constant.captionBold),
          _typoRow('label', Constant.label),
          _typoRow('overline', Constant.overline),
        ]),
        Constant.height32,
      ],
    );
  }

  Widget _typoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Constant.primaryColor.withValues(alpha: 0.1),
            borderRadius: Constant.radiusSmall,
          ),
          child: Text(
            title,
            style: Constant.label.copyWith(color: Constant.primaryColor),
          ),
        ),
        Constant.height8,
        ...children,
      ],
    );
  }

  Widget _typoRow(String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: Constant.caption)),
          Expanded(child: Text('Aa Bb Cc 123', style: style)),
        ],
      ),
    );
  }
}

// ================================================================
// TAB 3 — BUTTONS
// ================================================================
class _ButtonsTab extends StatelessWidget {
  const _ButtonsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Constant.paddingAll16,
      children: [
        // ===== MAIN BUTTON =====
        Text('Main Button', style: Constant.h6),
        Constant.height12,
        CustomButton.mainButton(label: 'Default', onPressed: () {}),
        Constant.height8,
        CustomButton.mainButton(
          label: 'With Icon',
          onPressed: () {},
          icon: Icons.rocket_launch,
        ),
        Constant.height8,
        CustomButton.mainButton(
          label: 'Loading...',
          onPressed: () {},
          isLoading: true,
        ),
        Constant.height8,
        CustomButton.mainButton(
          label: 'Disabled',
          onPressed: () {},
          enabled: false,
        ),
        Constant.height8,
        CustomButton.mainButton(
          label: 'Custom Color',
          onPressed: () {},
          color: Constant.success,
        ),
        Constant.height8,
        CustomButton.mainButton(
          label: 'Danger',
          onPressed: () {},
          color: Constant.error,
        ),
        Constant.height24,

        // ===== BORDER BUTTON =====
        Text('Border Button', style: Constant.h6),
        Constant.height12,
        CustomButton.borderButton(label: 'Default', onPressed: () {}),
        Constant.height8,
        CustomButton.borderButton(
          label: 'Custom Color',
          onPressed: () {},
          color: Constant.success,
        ),
        Constant.height8,
        CustomButton.borderButton(
          label: 'Disabled',
          onPressed: () {},
          enabled: false,
        ),
        Constant.height24,

        // ===== TEXT BUTTON =====
        Text('Text Button', style: Constant.h6),
        Constant.height12,
        Row(
          children: [
            CustomButton.textButton(label: 'Default', onPressed: () {}),
            Constant.width8,
            CustomButton.textButton(
              label: 'Custom Color',
              onPressed: () {},
              color: Constant.error,
            ),
            Constant.width8,
            CustomButton.textButton(
              label: 'Disabled',
              onPressed: () {},
              enabled: false,
            ),
          ],
        ),
        Constant.height24,

        // ===== ICON BUTTON =====
        Text('Icon Button', style: Constant.h6),
        Constant.height12,
        Row(
          children: [
            CustomButton.iconButton(
              icon: Icons.favorite,
              onPressed: () {},
              color: Constant.error,
            ),
            CustomButton.iconButton(
              icon: Icons.share,
              onPressed: () {},
              color: Constant.primaryColor,
            ),
            CustomButton.iconButton(
              icon: Icons.download,
              onPressed: () {},
              isLoading: true,
            ),
            CustomButton.iconButton(
              icon: Icons.delete,
              onPressed: () {},
              enabled: false,
            ),
          ],
        ),
        Constant.height32,
      ],
    );
  }
}

// ================================================================
// TAB 4 — COMPONENTS
// ================================================================
class _ComponentsTab extends StatefulWidget {
  const _ComponentsTab();

  @override
  State<_ComponentsTab> createState() => _ComponentsTabState();
}

class _ComponentsTabState extends State<_ComponentsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Constant.paddingAll16,
      children: [
        // ===== CARDS =====
        Text('Cards', style: Constant.h6),
        Constant.height12,
        CustomCard.elevated(
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Constant.width12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elevated Card', style: Constant.textSemiBold),
                  Text('Tap untuk aksi', style: Constant.caption),
                ],
              ),
            ],
          ),
          onTap: () => CustomSnackbar.info(
            context: context,
            message: 'Elevated card tapped!',
          ),
        ),
        Constant.height8,
        CustomCard.outlined(
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Constant.info),
              Constant.width12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outlined Card', style: Constant.textSemiBold),
                  Text('Tap untuk aksi', style: Constant.caption),
                ],
              ),
            ],
          ),
          onTap: () => CustomSnackbar.info(
            context: context,
            message: 'Outlined card tapped!',
          ),
        ),
        Constant.height8,
        CustomCard.filled(
          child: Row(
            children: [
              const Icon(Icons.palette, color: Constant.accentColor),
              Constant.width12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filled Card', style: Constant.textSemiBold),
                  Text('Tap untuk aksi', style: Constant.caption),
                ],
              ),
            ],
          ),
          onTap: () => CustomSnackbar.info(
            context: context,
            message: 'Filled card tapped!',
          ),
        ),
        Constant.height24,

        // ===== CHIPS =====
        Text('Chips', style: Constant.h6),
        Constant.height12,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CustomChip.filled(label: 'Flutter'),
            CustomChip.filled(label: 'With Icon', icon: Icons.code),
            CustomChip.filled(
              label: 'Deletable',
              onDelete: () {},
              color: Constant.accentColor,
            ),
            CustomChip.outlined(label: 'Outlined'),
            CustomChip.outlined(
              label: 'With Icon',
              icon: Icons.star,
              color: Constant.success,
            ),
            CustomChip.status(label: 'Success', type: StatusType.success),
            CustomChip.status(label: 'Warning', type: StatusType.warning),
            CustomChip.status(label: 'Error', type: StatusType.error),
            CustomChip.status(label: 'Info', type: StatusType.info),
          ],
        ),
        Constant.height24,

        // ===== SNACKBARS =====
        Text('Snackbars', style: Constant.h6),
        Constant.height12,
        Row(
          children: [
            Expanded(
              child: CustomButton.mainButton(
                label: 'Success',
                onPressed: () => CustomSnackbar.success(
                  context: context,
                  message: 'Berhasil disimpan!',
                ),
                color: Constant.success,
                height: 40,
              ),
            ),
            Constant.width8,
            Expanded(
              child: CustomButton.mainButton(
                label: 'Error',
                onPressed: () => CustomSnackbar.error(
                  context: context,
                  message: 'Terjadi kesalahan!',
                ),
                color: Constant.error,
                height: 40,
              ),
            ),
          ],
        ),
        Constant.height8,
        Row(
          children: [
            Expanded(
              child: CustomButton.mainButton(
                label: 'Info',
                onPressed: () => CustomSnackbar.info(
                  context: context,
                  message: 'Ini adalah informasi',
                ),
                color: Constant.info,
                height: 40,
              ),
            ),
            Constant.width8,
            Expanded(
              child: CustomButton.mainButton(
                label: 'Warning',
                onPressed: () => CustomSnackbar.warning(
                  context: context,
                  message: 'Perhatikan ini!',
                ),
                color: Constant.warning,
                height: 40,
              ),
            ),
          ],
        ),
        Constant.height24,

        // ===== DIALOGS =====
        Text('Dialogs', style: Constant.h6),
        Constant.height12,
        Row(
          children: [
            Expanded(
              child: CustomButton.borderButton(
                label: 'Alert',
                onPressed: () => CustomDialog.alert(
                  context: context,
                  title: 'Perhatian',
                  message: 'Ini adalah alert dialog',
                ),
                height: 40,
              ),
            ),
            Constant.width8,
            Expanded(
              child: CustomButton.borderButton(
                label: 'Confirm',
                onPressed: () async {
                  final result = await CustomDialog.confirm(
                    context: context,
                    title: 'Konfirmasi',
                    message: 'Apakah kamu yakin?',
                    isDanger: true,
                  );
                  if (result == true && context.mounted) {
                    CustomSnackbar.success(
                      context: context,
                      message: 'Dikonfirmasi!',
                    );
                  }
                },
                height: 40,
              ),
            ),
          ],
        ),
        Constant.height8,
        Row(
          children: [
            Expanded(
              child: CustomButton.borderButton(
                label: 'Success',
                onPressed: () => CustomDialog.success(
                  context: context,
                  title: 'Berhasil',
                  message: 'Data berhasil disimpan!',
                ),
                height: 40,
                color: Constant.success,
              ),
            ),
            Constant.width8,
            Expanded(
              child: CustomButton.borderButton(
                label: 'Error',
                onPressed: () => CustomDialog.error(
                  context: context,
                  title: 'Gagal',
                  message: 'Terjadi kesalahan pada server!',
                ),
                height: 40,
                color: Constant.error,
              ),
            ),
          ],
        ),
        Constant.height24,

        // ===== BOTTOM SHEET =====
        Text('Bottom Sheet', style: Constant.h6),
        Constant.height12,
        Row(
          children: [
            Expanded(
              child: CustomButton.borderButton(
                label: 'List',
                height: 40,
                onPressed: () async {
                  final result = await CustomBottomSheet.list(
                    context: context,
                    title: 'Pilih Opsi',
                    items: [
                      BottomSheetItem(
                        title: 'Edit',
                        icon: Icons.edit,
                        value: 'edit',
                      ),
                      BottomSheetItem(
                        title: 'Duplikat',
                        icon: Icons.copy,
                        value: 'duplicate',
                      ),
                      BottomSheetItem(
                        title: 'Hapus',
                        icon: Icons.delete,
                        value: 'delete',
                      ),
                    ],
                  );
                  if (result != null && context.mounted) {
                    CustomSnackbar.info(
                      context: context,
                      message: 'Dipilih: $result',
                    );
                  }
                },
              ),
            ),
            Constant.width8,
            Expanded(
              child: CustomButton.borderButton(
                label: 'Menu',
                height: 40,
                onPressed: () => CustomBottomSheet.menu(
                  context: context,
                  items: [
                    MenuBottomSheetItem(
                      title: 'Edit',
                      icon: Icons.edit,
                      onTap: () => CustomSnackbar.info(
                        context: context,
                        message: 'Edit dipilih',
                      ),
                    ),
                    MenuBottomSheetItem(
                      title: 'Hapus',
                      icon: Icons.delete,
                      color: Constant.error,
                      onTap: () => CustomSnackbar.error(
                        context: context,
                        message: 'Hapus dipilih',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Constant.height32,
      ],
    );
  }
}

// ================================================================
// TAB 5 — ACCOUNT
// ================================================================
class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return ListView(
      padding: Constant.paddingAll16,
      children: [
        Constant.height16,

        // ===== AVATAR =====
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constant.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: Constant.h2.copyWith(color: Constant.primaryColor),
              ),
            ),
          ),
        ),
        Constant.height16,

        // ===== USER INFO =====
        Center(child: Text(user?.name ?? 'Guest', style: Constant.h5)),
        Constant.height4,
        Center(child: Text(user?.email ?? '-', style: Constant.caption)),
        Constant.height32,

        // ===== INFO CARD =====
        CustomCard.outlined(
          child: Column(
            children: [
              _infoRow(Icons.person_outline, 'Nama', user?.name ?? '-'),
              Divider(height: 24, color: Constant.borderColor),
              _infoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
              Divider(height: 24, color: Constant.borderColor),
              _infoRow(Icons.tag, 'User ID', user?.id ?? '-'),
            ],
          ),
        ),
        Constant.height32,

        // ===== LOGOUT =====
        CustomButton.mainButton(
          label: 'Logout',
          onPressed: () async {
            final confirm = await CustomDialog.confirm(
              context: context,
              title: 'Logout',
              message: 'Apakah kamu yakin ingin keluar?',
              confirmText: 'Logout',
              cancelText: 'Batal',
              isDanger: true,
            );

            if (confirm == true && context.mounted) {
              await context.read<AuthProvider>().logout();
            }
          },
          color: Constant.error,
          isLoading: auth.isLoading,
        ),
        Constant.height32,
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Constant.textSecondary),
        Constant.width12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Constant.label),
            Text(value, style: Constant.bodyMedium),
          ],
        ),
      ],
    );
  }
}
