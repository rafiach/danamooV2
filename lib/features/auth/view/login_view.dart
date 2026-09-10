import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../auth/provider/auth_provider.dart';
import '../view/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      Utils.showErrorSnackbar(
        context,
        auth.errorMessage ?? 'Login gagal',
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
                // Header
                Text(
                  'Selamat Datang',
                  style: Constant.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constant.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk melanjutkan',
                  style: Constant.bodyMedium.copyWith(
                    color: Constant.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

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
                  hint: 'Masukkan password',
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
                const SizedBox(height: 32),

                // Login Button
                CustomButton.mainButton(
                  label: 'Masuk',
                  onPressed: _onLogin,
                  isLoading: auth.isLoading,
                  height: 56,
                  borderRadius: 16,
                ),
                const SizedBox(height: 24),

                // Register Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: Constant.bodyMedium.copyWith(
                          color: Constant.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            CustomNavigator.push(context, const RegisterView()),
                        child: Text(
                          'Daftar',
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