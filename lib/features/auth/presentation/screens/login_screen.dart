import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/cinema_decor.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        actions: [
          IconButton(
            onPressed: () => widget.onThemeChanged(
              widget.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            ),
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: CinemaBackdrop(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(Icons.local_movies_rounded, size: 54),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Chào mừng trở lại',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Đăng nhập để tiếp tục đêm điện ảnh của bạn',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        validator: passwordValidator,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Đăng nhập'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Tạo tài khoản'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: const Text('Quên mật khẩu'),
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
  }
}
