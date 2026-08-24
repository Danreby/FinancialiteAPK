import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/utils/validators.dart';
import 'widgets/auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _googleLoading = false;

  static const _googleClientId =
      '105982257579-bj5rmr9qcuuggr3rmf081ib4ri4ckfvh.apps.googleusercontent.com';

  // Singleton instance: must not be recreated on every tap
  late final GoogleSignIn _googleSignInInstance = GoogleSignIn(
    // On Web: pass clientId; on Android/iOS: null (uses google-services / strings.xml)
    clientId: kIsWeb ? _googleClientId : null,
    // On Android: serverClientId requests an id_token for the backend
    serverClientId: kIsWeb ? null : _googleClientId,
    scopes: const ['email', 'profile', 'openid'],
  );

  Future<void> _googleSignIn() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      final googleSignIn = _googleSignInInstance;
      // Sign out first to force account picker every time
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _googleLoading = false);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() => _googleLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Não foi possível obter o token do Google. Verifique a configuração do app.')),
          );
        }
        return;
      }
      if (mounted) {
        context
            .read<AuthBloc>()
            .add(AuthGoogleLoginRequested(idToken: idToken));
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('sign_in_canceled')) {
          return;
        } else if (errorMsg.contains('network_error')) {
          errorMsg = 'Sem conexão com a internet';
        } else if (errorMsg.contains('sign_in_failed') ||
            errorMsg.contains('ApiException: 10')) {
          errorMsg =
              'Falha na configuração do Google Sign-In. Verifique se o app está registrado no Google Cloud Console.';
        } else if (errorMsg.contains('ApiException: 12500')) {
          errorMsg =
              'Google Play Services desatualizado. Atualize pelo Play Store.';
        } else {
          errorMsg =
              'Erro ao autenticar com Google: ${errorMsg.replaceAll(RegExp(r'Exception:\s*|PlatformException\(|\)$'), '')}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    const AuthStagger(
                      child: Column(
                        children: [
                          Text(
                            'Financialite',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AuthColors.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Entrar',
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
                            'Entre na sua conta',
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
                              Center(
                                child: NeumorphicGoogleButton(
                                  onPressed: _googleSignIn,
                                  isLoading: _googleLoading,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const AuthDivider(),
                              const SizedBox(height: 24),
                              NeumorphicField(
                                controller: _emailController,
                                label: 'E-mail',
                                hint: 'Digite seu e-mail',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validators.email,
                                autofillHints: const [AutofillHints.username],
                              ),
                              const SizedBox(height: 20),
                              NeumorphicField(
                                controller: _passwordController,
                                label: 'Senha',
                                hint: 'Sua senha',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                validator: Validators.required,
                                onFieldSubmitted: (_) => _submit(),
                                autofillHints: const [AutofillHints.password],
                                suffix: FieldIconButton(
                                  icon: _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  tooltip: _obscurePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RememberMeCheckbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? false),
                                  ),
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      final isLoading = state is AuthLoading;
                                      return TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Recuperação de senha em breve.'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                )),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AuthColors.hint,
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Esqueceu a senha?',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return AuthPrimaryButton(
                                    label: 'Entrar',
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
                            'Não tem conta? ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AuthColors.onSurfaceVar,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: const Text(
                              'Cadastre-se',
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
    );
  }
}
