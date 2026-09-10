import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../auth/provider/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      Utils.showErrorSnackbar(
        context,
        auth.errorMessage ?? 'Registrasi gagal',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  color: Constant.textSecondary,
                ),
                const SizedBox(height: 16),

                // Header
                Text(
                  'Buat Akun Baru',
                  style: Constant.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi data untuk mendaftar',
                  style: Constant.bodyMedium.copyWith(
                    color: Constant.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Name Field
                CustomTextField.standard(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomTextField.standard(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'contoh@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField.password(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimal 8 karakter',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField.password(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                CustomButton.mainButton(
                  label: 'Daftar',
                  onPressed: _onRegister,
                  isLoading: auth.isLoading,
                  height: 56,
                  borderRadius: 16,
                ),
                const SizedBox(height: 24),

                // Login Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: Constant.bodyMedium.copyWith(
                          color: Constant.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Masuk',
                          style: Constant.textSemiBold.copyWith(
                            color: Constant.limeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}