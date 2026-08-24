import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/utils/validators.dart';
import 'widgets/auth_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AuthColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AuthColors.bg,
        body: Stack(
          children: [
            const AuthAmbientBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Voltar para o login',
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => context.pop(),
                              focusColor: Colors.white.withValues(alpha: 0.25),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.arrow_back_rounded,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        children: [
                          const AuthStagger(
                            child: Column(
                              children: [
                                Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AuthColors.onSurface,
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Preencha seus dados para se cadastrar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AuthColors.onSurfaceVar,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthStagger(
                            delay: const Duration(milliseconds: 70),
                            child: AuthCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    NeumorphicField(
                                      controller: _nameController,
                                      label: 'Nome completo',
                                      hint: 'Como podemos te chamar?',
                                      textInputAction: TextInputAction.next,
                                      validator: Validators.required,
                                      autofillHints: const [AutofillHints.name],
                                    ),
                                    const SizedBox(height: 20),
                                    NeumorphicField(
                                      controller: _emailController,
                                      label: 'E-mail',
                                      hint: 'seu@email.com',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: Validators.email,
                                      autofillHints: const [AutofillHints.email],
                                    ),
                                    const SizedBox(height: 20),
                                    NeumorphicField(
                                      controller: _passwordController,
                                      label: 'Senha',
                                      hint: 'Crie uma senha forte',
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      validator: Validators.password,
                                      autofillHints: const [AutofillHints.newPassword],
                                      suffix: FieldIconButton(
                                        icon: _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        tooltip: _obscurePassword
                                            ? 'Mostrar senha'
                                            : 'Ocultar senha',
                                        onPressed: () => setState(() =>
                                            _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    NeumorphicField(
                                      controller: _confirmController,
                                      label: 'Confirmar senha',
                                      hint: 'Repita a senha',
                                      obscureText: _obscureConfirm,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _submit(),
                                      validator: (value) => Validators
                                          .confirmPassword(
                                              value, _passwordController.text),
                                      autofillHints: const [AutofillHints.newPassword],
                                      suffix: FieldIconButton(
                                        icon: _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        tooltip: _obscureConfirm
                                            ? 'Mostrar senha'
                                            : 'Ocultar senha',
                                        onPressed: () => setState(() =>
                                            _obscureConfirm = !_obscureConfirm),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        final isLoading = state is AuthLoading;
                                        return AuthPrimaryButton(
                                          label: 'Cadastrar',
                                          isLoading: isLoading,
                                          onPressed: isLoading ? null : _submit,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthStagger(
                            delay: const Duration(milliseconds: 140),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Já tem uma conta? ',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AuthColors.onSurfaceVar,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    'Faça login',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AuthColors.primaryAlt,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
