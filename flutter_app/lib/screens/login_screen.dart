import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  String _error = '';
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() { _error = ''; _submitting = true; });
    final auth = context.read<AuthService>();
    try {
      if (_isSignUp) {
        await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
      } else {
        await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text);
      }
    } catch (e) {
      setState(() => _error = auth.friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _error = '');
    final auth = context.read<AuthService>();
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      setState(() => _error = auth.friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Terminal header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                border: Border(bottom: BorderSide(color: AppColors.borderPrimary)),
              ),
              child: Row(
                children: [
                  const Text('user', style: TextStyle(color: AppColors.accentGreen, fontSize: 11)),
                  const Text('@', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  const Text('init.habits', style: TextStyle(color: AppColors.accentCyan, fontSize: 11)),
                  const Text(':~\$', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  const SizedBox(width: 4),
                  Text('auth.${_isSignUp ? 'signup' : 'login'}()', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('// ${_isSignUp ? 'create account' : 'authenticate'}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(_isSignUp ? '\$ create_account' : '\$ sign_in', style: const TextStyle(color: AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      if (_error.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('stderr: $_error', style: const TextStyle(color: AppColors.accentRed, fontSize: 10)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const Text('--email', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'user@example.com'),
                      ),
                      const SizedBox(height: 12),
                      const Text('--password', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        decoration: const InputDecoration(hintText: '••••••••'),
                      ),
                      const SizedBox(height: 16),
                      // Email submit
                      GestureDetector(
                        onTap: _submitting ? null : _handleSubmit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _submitting ? '\$ processing...' : '\$ sign_${_isSignUp ? 'up' : 'in'} --email',
                            style: TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.borderPrimary)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('||', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                          ),
                          Expanded(child: Divider(color: AppColors.borderPrimary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Google
                      GestureDetector(
                        onTap: _handleGoogle,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            border: Border.all(color: AppColors.borderPrimary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, color: AppColors.textSecondary, size: 20),
                              SizedBox(width: 6),
                              Text('\$ sign_in --google', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Toggle
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() { _isSignUp = !_isSignUp; _error = ''; }),
                          child: Text(
                            _isSignUp ? '// already have an account? sign_in' : '// need an account? sign_up',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
