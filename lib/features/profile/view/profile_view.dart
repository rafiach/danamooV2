import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/user_model.dart';
import '../../../generated/assets.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/profile_provider.dart';
import '../../home/provider/home_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // TODO: ganti jadi ambil dari provider/local storage kalau sudah ada fiturnya
  // bool _appLockEnabled = false;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'Versi ${info.version} (${info.buildNumber})';
        // atau kalau nggak mau nampilin build number:
        // _appVersion = 'Versi ${info.version}';
      });
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirm = await Utils.showConfirmDialog(
      context,
      title: 'Hapus Akun',
      content:
          'Semua data transaksi dan akun kamu akan dihapus permanen. Tindakan ini tidak bisa dibatalkan. Lanjutkan?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDanger: true,
    );

    if (confirm != true || !context.mounted) return;

    Utils.showLoadingDialog(context, message: 'Menghapus akun...');

    final success = await authProvider.deleteAccount();

    if (!context.mounted) return;
    Utils.hideLoadingDialog(context);

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      Utils.showAutoDismissDialog(
        context,
        title: 'Gagal Menghapus Akun',
        content: authProvider.errorMessage ?? 'Terjadi kesalahan',
        imagePath: Assets.assetsIconsError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profileProvider = context.watch<ProfileProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Constant.white,
        body: user == null
            ? const Center(
                child: CircularProgressIndicator(color: Constant.limeAccent),
              )
            : Column(
                children: [
                  _buildProfileHeader(context, user),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _buildSectionLabel('AKUN'),
                          // const SizedBox(height: 8),
                          // _buildMenuGroup([
                          //   _MenuItemData(
                          //     icon: Icons.lock_outline_rounded,
                          //     title: 'Kunci Aplikasi (PIN/Biometrik)',
                          //     trailing: Switch(
                          //       value: _appLockEnabled,
                          //       activeColor: Constant.limeAccent,
                          //       activeTrackColor: Constant.limeAccent
                          //           .withValues(alpha: 0.3),
                          //       onChanged: (value) {
                          //         setState(() => _appLockEnabled = value);
                          //         // TODO: simpan ke provider/local storage
                          //       },
                          //     ),
                          //     onTap: () {},
                          //   ),
                          // ]),
                          const SizedBox(height: 20),

                          _buildSectionLabel('DATA'),
                          const SizedBox(height: 8),
                          _buildMenuGroup([
                            _MenuItemData(
                              icon: Icons.notifications_outlined,
                              title: 'Notifikasi',
                              trailing: Switch(
                                value: user.notifEnabled,
                                activeColor: Constant.limeAccentDark,
                                activeTrackColor: Constant.limeAccentDark
                                    .withValues(alpha: 0.3),
                                trackOutlineColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? Constant.limeAccentDark
                                          : Constant.borderSubtle,
                                    ),
                                trackOutlineWidth: const WidgetStatePropertyAll(
                                  1.5,
                                ),
                                onChanged: (value) {
                                  authProvider.updateProfile(
                                    notifEnabled: value,
                                  );
                                },
                              ),
                              onTap: () {},
                            ),
                            _MenuItemData(
                              icon: Icons.download_rounded,
                              title: 'Export Data (Excel)',
                              onTap: () => _showExportBottomSheet(
                                context,
                                user,
                                profileProvider,
                              ),
                            ),
                            _MenuItemData(
                              icon: Icons.cloud_sync_rounded,
                              title: 'Sinkronisasi Cloud',
                              onTap: () => _showCloudSyncDialog(
                                context,
                                user,
                                profileProvider,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),

                          _buildSectionLabel('LAINNYA'),
                          const SizedBox(height: 8),
                          _buildMenuGroup([
                            _MenuItemData(
                              icon: Icons.help_outline_rounded,
                              title: 'Bantuan & Dukungan',
                              onTap: () {
                                // TODO: navigasi ke halaman bantuan
                              },
                            ),
                            _MenuItemData(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Kebijakan Privasi',
                              onTap: () {
                                // TODO: navigasi ke halaman kebijakan privasi
                              },
                            ),
                            _MenuItemData(
                              icon: Icons.info_outline_rounded,
                              title: 'Tentang DANAMOO',
                              onTap: () {
                                // TODO: navigasi ke halaman about
                              },
                            ),
                          ]),
                          const SizedBox(height: 28),

                          _buildLogoutButton(authProvider),
                          const SizedBox(height: 16),

                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  _confirmDeleteAccount(context, authProvider),
                              child: Text(
                                'Hapus Akun',
                                style: Constant.textMedium.copyWith(
                                  color: Constant.expenseRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              _appVersion,
                              style: Constant.bodySmall.copyWith(
                                color: Constant.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Constant.surfaceDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => CustomNavigator.pop(context),
                ),
              ),
              Text(
                'Profil',
                style: Constant.textSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constant.limeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Constant.limeAccent, size: 40),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            user.name,
            style: Constant.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          Text(
            user.email,
            style: Constant.bodyMedium.copyWith(color: Constant.limeAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'Edit Profil',
              style: Constant.textSemiBold.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Constant.bodySmall.copyWith(
        color: Constant.textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuItemData> items) {
    return CustomCard.surface(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      color: Constant.greyLight,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildMenuItem(items[i]),
            if (i != items.length - 1) _buildDivider(),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Constant.limeAccent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: Constant.black, size: 20),
      ),
      title: Text(
        item.title,
        style: Constant.textSemiBold.copyWith(
          color: Constant.textPrimary,
          fontSize: 14,
        ),
      ),
      trailing:
          item.trailing ?? Icon(Icons.chevron_right, color: Constant.black),
      onTap: item.onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Constant.borderSubtle,
      height: 1,
      indent: 72,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton.mainButton(
        label: 'Keluar',
        onPressed: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        height: 56,
        borderRadius: 16,
        color: Constant.expenseRed,
      ),
    );
  }

  void _showExportBottomSheet(
    BuildContext context,
    UserModel user,
    ProfileProvider profileProvider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Constant.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Constant.greyMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Export Data ke Excel',
                style: Constant.h6.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data transaksi akan diekspor ke folder Downloads.',
              style: Constant.bodyMedium.copyWith(
                color: Constant.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton.mainButton(
                label: 'Export & Simpan',
                onPressed: () async {
                  Navigator.pop(context);
                  await _exportData(
                    context,
                    user,
                    profileProvider,
                    isShare: false,
                  );
                },
                height: 52,
                borderRadius: 16,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    UserModel user,
    ProfileProvider profileProvider, {
    required bool isShare,
  }) async {
    Utils.showLoadingDialog(context, message: 'Menyiapkan file...');

    try {
      await profileProvider.exportDataToExcel(user.id, isShare: isShare);

      if (!context.mounted) return;
      Utils.hideLoadingDialog(context);

      if (!context.mounted) return;
      Utils.showSuccessSnackbar(
        context,
        isShare
            ? 'File siap dibagikan!'
            : 'Data berhasil disimpan ke Downloads!',
      );
    } catch (e) {
      if (!context.mounted) return;
      Utils.hideLoadingDialog(context);
      Utils.showErrorSnackbar(context, 'Gagal mengekspor data: $e');
    }
  }

  void _showCloudSyncDialog(
    BuildContext context,
    UserModel user,
    ProfileProvider profileProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sinkronisasi Cloud', style: Constant.h6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih aksi sinkronisasi:',
              style: Constant.bodyMedium.copyWith(
                color: Constant.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomButton.mainButton(
                label: 'Backup ke Cloud',
                onPressed: () async {
                  Navigator.pop(context);
                  await _performBackup(context, user, profileProvider);
                },
                height: 48,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton.borderButton(
                label: 'Restore dari Cloud',
                onPressed: () async {
                  Navigator.pop(context);
                  await _performRestore(context, user, profileProvider);
                },
                height: 48,
                borderRadius: 12,
                color: Constant.limeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performBackup(
    BuildContext context,
    UserModel user,
    ProfileProvider profileProvider,
  ) async {
    Utils.showLoadingDialog(context, message: 'Mencadangkan data ke Cloud...');

    final success = await profileProvider.backupData();

    if (!context.mounted) return;
    Utils.hideLoadingDialog(context);

    if (success) {
      Utils.showSuccessSnackbar(context, 'Backup data berhasil!');
    } else {
      Utils.showErrorSnackbar(context, 'Gagal melakukan backup data.');
    }
  }

  Future<void> _performRestore(
    BuildContext context,
    UserModel user,
    ProfileProvider profileProvider,
  ) async {
    final confirm = await Utils.showConfirmDialog(
      context,
      title: 'Restore Data',
      content:
          'Data lokal saat ini akan ditimpa dengan data dari Cloud. Lanjutkan?',
      confirmText: 'Restore',
    );

    if (confirm != true) return;

    Utils.showLoadingDialog(context, message: 'Memulihkan data dari Cloud...');

    final success = await profileProvider.restoreData();

    if (!context.mounted) return;
    Utils.hideLoadingDialog(context);

    if (success) {
      context.read<HomeProvider>().fetchData(user);
      Utils.showSuccessSnackbar(context, 'Restore data berhasil!');
    } else {
      Utils.showErrorSnackbar(
        context,
        'Gagal memulihkan data. Pastikan ada backup di Cloud.',
      );
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}
