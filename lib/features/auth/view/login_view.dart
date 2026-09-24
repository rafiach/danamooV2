import 'package:danamoo/features/auth/view/widget/auth_header.dart';
import 'package:danamoo/generated/assets.dart';
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
      Utils.showAutoDismissDialog(
        context,
        title: "Login Gagal!",
        content:
            auth.errorMessage ??
            "Login gagal, pastikan email dan password benar!",
        imagePath: Assets.assetsIconsError,
      );
    }
  }

  Future<void> _onGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();

    if (!success && mounted) {
      Utils.showAutoDismissDialog(
        context,
        title: 'Login Gagal',
        content: auth.errorMessage ?? 'Login dengan Google gagal',
        imagePath: Assets.assetsIconsError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // samakan dengan register
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthHeader(
                        title: 'Yuk, Lanjutin!',
                        subtitle: 'Masuk dulu buat lanjut pantau keuanganmu',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            const SizedBox(height: 12),

                            // Lupa Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: sambungkan ke flow reset password
                                },
                                child: Text(
                                  'Lupa Password?',
                                  style: Constant.textSemiBold.copyWith(
                                    color: Constant.expenseRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===== SPACER: dorong tombol ke bawah kalau konten pendek =====
                      const Expanded(child: SizedBox()),

                      // ===== TOMBOL: sekarang bagian dari scroll content =====
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomButton.mainButton(
                                label: 'Masuk',
                                textColor: Constant.textPrimary,
                                onPressed: _onLogin,
                                isLoading: auth.isLoading,
                                height: 56,
                                borderRadius: 16,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Constant.borderSubtle,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'atau',
                                      style: Constant.caption,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Constant.borderSubtle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomButton.borderButton(
                                label: 'Login dengan Google',
                                onPressed: _onGoogleLogin,
                                color: Constant.limeAccentDark,
                                isLoading: auth.isLoading,
                                height: 56,
                                borderRadius: 16,
                                icon: Icons.g_mobiledata,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun? ',
                                    style: Constant.bodyMedium.copyWith(
                                      color: Constant.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => CustomNavigator.push(
                                      context,
                                      const RegisterView(),
                                    ),
                                    child: Text(
                                      'Daftar',
                                      style: Constant.textSemiBold.copyWith(
                                        color: Constant.expenseRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
