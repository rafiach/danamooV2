import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/user_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/profile_provider.dart';
import '../../home/provider/home_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Profil',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.surfaceCard,
        foregroundColor: Constant.textPrimary,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Constant.limeAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),

                  // Menu Section
                  _buildMenuSection(context, user, authProvider, profileProvider),

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(authProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return CustomCard.surface(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constant.limeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Constant.limeAccent,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: Constant.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: Constant.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: Constant.bodyMedium.copyWith(
              color: Constant.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    UserModel user,
    AuthProvider authProvider,
    ProfileProvider profileProvider,
  ) {
    return CustomCard.surface(
      borderRadius: 16,
      child: Column(
        children: [
          // Notifications
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            trailing: Switch(
              value: user.notifEnabled,
              activeColor: Constant.limeAccent,
              activeTrackColor: Constant.limeAccent.withValues(alpha: 0.3),
              onChanged: (value) {
                authProvider.updateProfile(notifEnabled: value);
              },
            ),
            onTap: () {},
          ),
          _buildDivider(),

          // Export Data
          _buildMenuItem(
            icon: Icons.download_rounded,
            title: 'Export Data (Excel)',
            onTap: () => _showExportBottomSheet(context, user, profileProvider),
          ),
          _buildDivider(),

          // Cloud Sync (Backup/Restore combined)
          _buildMenuItem(
            icon: Icons.cloud_sync_rounded,
            title: 'Sinkronisasi Cloud',
            onTap: () => _showCloudSyncDialog(context, user, profileProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Constant.limeAccent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Constant.limeAccent, size: 20),
      ),
      title: Text(
        title,
        style: Constant.textSemiBold.copyWith(
          color: Constant.textPrimary,
          fontSize: 15,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Constant.textSecondary),
      onTap: onTap,
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
              style: Constant.bodyMedium.copyWith(color: Constant.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton.mainButton(
                label: 'Export & Simpan',
                onPressed: () async {
                  Navigator.pop(context);
                  await _exportData(context, user, profileProvider, isShare: false);
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
        isShare ? 'File siap dibagikan!' : 'Data berhasil disimpan ke Downloads!',
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
              style: Constant.bodyMedium.copyWith(color: Constant.textSecondary),
            ),
            const SizedBox(height: 20),
            // Backup Button
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
            // Restore Button
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
      content: 'Data lokal saat ini akan ditimpa dengan data dari Cloud. Lanjutkan?',
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