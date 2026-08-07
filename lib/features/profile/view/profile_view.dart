import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_navigator.dart';
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
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.standard(
        title: 'Profile',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.violetDarker,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(16.0),
              color: Constant.violet50,
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Constant.violetDarker.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          Assets.assetsIconsCowMascot,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 48),

                  // Menu List
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Constant.white,
                    ),
                    child: Column(
                      children: [
                        _buildProfileMenu(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifications',
                          trailing: Switch(
                            value: user.notifEnabled,
                            activeColor: Constant.white,
                            activeTrackColor: Constant.violetDarker,
                            onChanged: (value) {
                              authProvider.updateProfile(notifEnabled: value);
                            },
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 2, color: Constant.violet50),
                        _buildProfileMenu(
                          icon: Icons.download_rounded,
                          title: 'Export Data (Excel)',
                          onTap: () {
                            Utils.showCustomBottomSheet(
                              context,
                              child: SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Pilih Metode Export',
                                        style: Constant.h6,
                                      ),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.save_alt,
                                        color: Constant.violetDarker,
                                      ),
                                      title: const Text('Simpan ke Perangkat'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _handleExport(context, isShare: false);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.share,
                                        color: Constant.violetDarker,
                                      ),
                                      title: const Text('Bagikan File (Share)'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _handleExport(context, isShare: true);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 2, color: Constant.violet50),
                        _buildProfileMenu(
                          icon: Icons.cloud_upload_outlined,
                          title: 'Backup Data ke Cloud',
                          onTap: () async {
                            Utils.showLoadingDialog(
                              context,
                              message: 'Mencadangkan data...',
                            );
                            final success = await profileProvider.backupData();
                            if (!context.mounted) return;
                            Utils.hideLoadingDialog(context);

                            if (success) {
                              Utils.showSuccessSnackbar(
                                context,
                                'Backup data berhasil!',
                              );
                            } else {
                              Utils.showErrorSnackbar(
                                context,
                                'Gagal melakukan backup data.',
                              );
                            }
                          },
                        ),
                        const Divider(height: 2, color: Constant.violet50),
                        _buildProfileMenu(
                          icon: Icons.cloud_download_outlined,
                          title: 'Restore Data dari Cloud',
                          onTap: () async {
                            final confirm = await Utils.showConfirmDialog(
                              context,
                              title: 'Restore Data',
                              content:
                                  'Data lokal saat ini akan ditimpa dengan data dari Cloud. Anda yakin?',
                              confirmText: 'Restore',
                            );
                            if (confirm != true) return;

                            if (!context.mounted) return;
                            Utils.showLoadingDialog(
                              context,
                              message: 'Memulihkan data...',
                            );
                            final success = await profileProvider.restoreData();
                            if (!context.mounted) return;
                            Utils.hideLoadingDialog(context);

                            if (success) {
                              // Refresh data home agar list transaksi segera menyesuaikan
                              context.read<HomeProvider>().fetchData(user);
                              Utils.showSuccessSnackbar(
                                context,
                                'Restore data berhasil!',
                              );
                            } else {
                              Utils.showErrorSnackbar(
                                context,
                                'Gagal memulihkan data. Pastikan ada backup di Cloud.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Constant.violetDarker.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Constant.violetDarker),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _handleExport(
    BuildContext context, {
    required bool isShare,
  }) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profileProvider = context.read<ProfileProvider>();

    Utils.showLoadingDialog(context, message: 'Menyiapkan file...');

    try {
      await profileProvider.exportDataToExcel(user.id, isShare: isShare);

      if (!context.mounted) return;
      Utils.hideLoadingDialog(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isShare ? 'File siap dibagikan!' : 'Data berhasil disimpan!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Constant.success,
        ),
      );

      if (user.notifEnabled == true) {
        NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Export Excel Berhasil',
          body: isShare
              ? 'Laporan transaksi siap dibagikan.'
              : 'Laporan transaksi Anda telah berhasil disimpan.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Utils.hideLoadingDialog(context);
      Utils.showErrorSnackbar(context, 'Gagal mengekspor data: $e');
    }
  }
}
