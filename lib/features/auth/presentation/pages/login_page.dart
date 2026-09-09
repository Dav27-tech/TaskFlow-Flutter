import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/taskflow_brand.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(loginProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final state = ref.read(loginProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getFirebaseErrorMessage(state.error))),
      );
      return;
    }

    context.go('/dashboard');
  }

  String _getFirebaseErrorMessage(Object? error) {
    final message = error.toString();

    if (message.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (message.contains('invalid-email')) {
      return 'L’adresse e-mail est invalide.';
    }

    if (message.contains('user-not-found')) {
      return 'Aucun compte ne correspond à cette adresse e-mail.';
    }

    if (message.contains('wrong-password')) {
      return 'Mot de passe incorrect.';
    }

    if (message.contains('user-disabled')) {
      return 'Ce compte a été désactivé.';
    }

    if (message.contains('network-request-failed')) {
      return 'Problème de connexion. Vérifiez votre Internet.';
    }

    return 'Impossible de se connecter. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    const TaskFlowBrand(
                      compact: true,
                      assetPath: 'assets/logo/taskflow-logo.png',
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Connexion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF14213D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Accédez à votre espace de travail TaskFlow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFF718096)),
                    ),

                    const SizedBox(height: 36),

                    // EMAIL
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172554),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'example@gmail.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre adresse e-mail.';
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Veuillez entrer une adresse e-mail valide.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    const Text(
                      'Mot de passe',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172554),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          _login();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '***********',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // LOGIN BUTTON
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // REGISTER LINK
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Vous n’avez pas encore de compte ?',
                          style: TextStyle(color: Color(0xFF718096)),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/register'),
                          child: const Text('Créer un compte', style: TextStyle(color: Color(
                              0xFF608EF3)),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
