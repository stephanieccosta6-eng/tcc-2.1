import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  final bool isPortuguese;
  final VoidCallback onToggleLanguage;
  final void Function(Map<String, dynamic> userData) onAuthenticated;

  const AuthScreen({
    super.key,
    required this.isPortuguese,
    required this.onToggleLanguage,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores 100% vazios — nenhum dado pré-preenchido
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Critérios de Senha Forte (Regex)
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  void _evaluatePasswordStrength() {
    final pwd = _passwordController.text;
    setState(() {
      _hasMinLength = pwd.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(pwd);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(pwd);
      _hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
      _hasSpecialChar = RegExp(r'[!@#\$%\^&\*\(\),.?":\{\}\|<>_\-\+=\[\]\;/~`]').hasMatch(pwd);
    });
  }

  bool get _isPasswordStrong =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (!_isLoginMode && !_isPasswordStrong) {
      setState(() {
        _errorMessage = AppStrings.t(widget.isPortuguese, 'pwd_weak_err');
      });
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    Map<String, dynamic> result;
    if (_isLoginMode) {
      result = await ApiService.loginUser(email: email, password: password);
    } else {
      result = await ApiService.registerUser(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true && result['user'] != null) {
      widget.onAuthenticated(result['user']);
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  void _switchMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.isPortuguese;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: widget.onToggleLanguage,
                      icon: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                      label: Text(
                        pt ? 'Português / English' : 'English / Português',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Center(
                        child: Text('G', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.t(pt, _isLoginMode ? 'welcome_title' : 'register_title'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.t(pt, _isLoginMode ? 'welcome_sub' : 'register_sub'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLoginMode) ...[
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(fontSize: 16.5),
                              decoration: InputDecoration(
                                labelText: AppStrings.t(pt, 'full_name'),
                                hintText: AppStrings.t(pt, 'full_name_hint'),
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().length < 2) {
                                  return AppStrings.t(pt, 'name_error');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 16.5),
                            decoration: InputDecoration(
                              labelText: AppStrings.t(pt, 'email'),
                              hintText: AppStrings.t(pt, 'email_hint'),
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (val) {
                              if (val == null || !val.contains('@') || !val.contains('.')) {
                                return AppStrings.t(pt, 'email_error');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 16.5),
                            decoration: InputDecoration(
                              labelText: AppStrings.t(pt, 'password'),
                              hintText: AppStrings.t(pt, 'password_hint'),
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return AppStrings.t(pt, 'password_empty');
                              }
                              return null;
                            },
                          ),

                          if (!_isLoginMode) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.t(pt, 'pwd_req_title'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 8),
                                  _reqRow(AppStrings.t(pt, 'pwd_min'), _hasMinLength),
                                  _reqRow(AppStrings.t(pt, 'pwd_upper'), _hasUppercase),
                                  _reqRow(AppStrings.t(pt, 'pwd_lower'), _hasLowercase),
                                  _reqRow(AppStrings.t(pt, 'pwd_num'), _hasNumber),
                                  _reqRow(AppStrings.t(pt, 'pwd_spec'), _hasSpecialChar),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppStrings.t(pt, 'lgpd_notice'),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],

                          const SizedBox(height: 22),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      AppStrings.t(pt, _isLoginMode ? 'sign_in' : 'create_account'),
                                      style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _switchMode,
                    child: Text(
                      AppStrings.t(pt, _isLoginMode ? 'no_account' : 'has_account'),
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reqRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 17,
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: met ? AppColors.success : AppColors.textSecondary,
                fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
