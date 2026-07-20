import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else {
      context.go('/user/home');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đăng ký')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AuthTextField(
            controller: _name,
            label: 'Họ tên',
            validator: (v) => requiredText(v, field: 'Họ tên'),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _password,
            label: 'Mật khẩu',
            obscureText: true,
            validator: passwordValidator,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirm,
            label: 'Xác nhận mật khẩu',
            obscureText: true,
            validator: (v) =>
                v != _password.text ? 'Mật khẩu xác nhận không khớp.' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: ref.watch(authControllerProvider).isLoading
                ? null
                : _submit,
            child: ref.watch(authControllerProvider).isLoading
                ? const CircularProgressIndicator()
                : const Text('Đăng ký'),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Đã có tài khoản? Đăng nhập'),
          ),
        ],
      ),
    ),
  );
}
