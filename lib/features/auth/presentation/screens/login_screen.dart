import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:mycomicsapp/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginScreen extends ConsumerStatefulWidget {
  
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogoutStatus();
    });
  }

  void _checkLogoutStatus() {
    final justLoggedOut = ref.read(justLoggedOutProvider);
    if (justLoggedOut) {
      ToastUtils.showSuccess(
        context, 
        'Signout Successfully!'
      );
      
      ref.read(justLoggedOutProvider.notifier).state = false;
    }

  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        ref.read(justLoggedInProvider.notifier).state = true;
      } on AuthException catch (e) {
        if (mounted) {
          ToastUtils.showError(context, e.message);

        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithGoogle();

      ref.read(justLoggedInProvider.notifier).state = true;
    } on AuthException catch (e) {
      if (mounted) {
        ToastUtils.showError(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 20),
                Text(
                  'Welcome back to ComicsVerse!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                AuthField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_isLoading || _isGoogleLoading) ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: _isGoogleLoading
                      ? const SizedBox.shrink()
                      : Image.asset('assets/images/google_logo.png', height: 22),
                  label: _isGoogleLoading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Continue with Google'),
                  onPressed: (_isLoading || _isGoogleLoading) ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    foregroundColor: Theme.of(context).colorScheme.onBackground,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

