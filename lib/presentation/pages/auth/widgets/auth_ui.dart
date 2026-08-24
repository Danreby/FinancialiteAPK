import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dark neumorphic "soft-UI" palette and building blocks reserved
/// EXCLUSIVELY for the Login/Cadastro screens -- mirrors the Financialite
/// web app's own scoping rule ("Neumorphic surface used only by the
/// Login/Register auth screens"). This intentionally does NOT read from
/// [AppColorScheme] / [ThemeColors]: a guest has no saved theme preference
/// yet, so auth always renders in this one fixed look, exactly like the web
/// app's `GuestLayout` (always dark, independent of the dashboard's active
/// color scheme). The rest of the app keeps its existing flat, neutral-
/// shadow language untouched.
class AuthColors {
  AuthColors._();

  static const bg = Color(0xFF0A0404);
  static const surface = Color(0xFF150707);
  static const surfaceInset = Color(0xFF100505);
  static const accent = Color(0xFFF43F5E);
  static const primary = Color(0xFFBE123C);
  static const primaryAlt = Color(0xFFFB7185);
  static const onSurface = Color(0xFFF4F4F5);
  static const onSurfaceVar = Color(0xFFA1A1AA);
  static const hint = Color(0xFF71717A);
  static const divider = Color(0x80450A0A);
  static const error = Color(0xFFF87171);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary],
  );

  /// 6px/6px raised dual-shadow -- the auth card and the circular Google
  /// button. Warm off-black base + a faint highlight, never pure black.
  static const outset = [
    BoxShadow(color: Color(0x8C000000), blurRadius: 14, offset: Offset(6, 6)),
    BoxShadow(color: Color(0x0AFFFFFF), blurRadius: 14, offset: Offset(-6, -6)),
  ];

  /// Carved/inset shadow for text fields -- depth without a visible border.
  static const inset = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 8,
      offset: Offset(4, 4),
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: Color(0x08FFFFFF),
      blurRadius: 8,
      offset: Offset(-4, -4),
      blurStyle: BlurStyle.inner,
    ),
  ];

  /// Color appears here and ONLY here -- never as an ambient page/card glow.
  static List<BoxShadow> ctaShadow() => [
        BoxShadow(
          color: accent.withValues(alpha: 0.35),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Two soft blurred circles behind the auth content -- subtle depth, not a
/// hero gradient mesh. One tinted [AuthColors.primary], one neutral.
class AuthAmbientBackground extends StatelessWidget {
  const AuthAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _Blob(color: AuthColors.primary, opacity: 0.08),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _Blob(color: Colors.black, opacity: 0.35),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double opacity;
  const _Blob({required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

/// Fades + rises [child] into place, honoring `disableAnimations`
/// (the OS "reduce motion" setting) by skipping straight to the end state.
class AuthStagger extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AuthStagger({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<AuthStagger> createState() => _AuthStaggerState();
}

class _AuthStaggerState extends State<AuthStagger> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
    );
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(curved);
    _offset = Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved);
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// The raised neumorphic panel that hosts the auth form.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AuthColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AuthColors.outset,
      ),
      child: child,
    );
  }
}

const _googleLogoSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4" />
  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
</svg>
''';

/// Circular neumorphic Google sign-in button carrying the REAL 4-color
/// Google "G" mark (never a generic letter/icon substitute).
class NeumorphicGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const NeumorphicGoogleButton({super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AuthColors.surface,
        boxShadow: AuthColors.outset,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading ? null : onPressed,
          focusColor: AuthColors.accent.withValues(alpha: 0.25),
          child: Semantics(
            button: true,
            label: 'Entrar com Google',
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AuthColors.hint),
                    )
                  : SvgPicture.string(_googleLogoSvg, width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
  }
}

/// "ou continue com" hairline divider.
class AuthDivider extends StatelessWidget {
  final String label;
  const AuthDivider({super.key, this.label = 'ou continue com'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AuthColors.hint)),
        ),
        const Expanded(child: Divider(color: AuthColors.divider, height: 1)),
      ],
    );
  }
}

/// Carved/inset text field with a real label above the input (never
/// placeholder-as-label), rose focus ring, and inline error text.
class NeumorphicField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffix;
  final List<String>? autofillHints;

  const NeumorphicField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffix,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AuthColors.onSurfaceVar)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AuthColors.surfaceInset,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AuthColors.inset,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            autofillHints: autofillHints,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500, color: AuthColors.onSurface),
            cursorColor: AuthColors.accent,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AuthColors.hint),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AuthColors.accent, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AuthColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AuthColors.error, width: 1.5),
              ),
              errorStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AuthColors.error),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small icon-button used inside [NeumorphicField] for password visibility.
class FieldIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const FieldIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: color ?? AuthColors.hint,
      tooltip: tooltip,
      onPressed: onPressed,
      focusColor: AuthColors.accent.withValues(alpha: 0.2),
    );
  }
}

/// Full-width-capped pill CTA, rose gradient fill, the only place on the
/// screen where a colored shadow is allowed to glow.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: _PressableTap(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AuthColors.gradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isLoading ? null : AuthColors.ctaShadow(),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, strokeCap: StrokeCap.round, color: Colors.white),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// InkWell + Material wrapper shared by the CTA and icon-only controls:
/// gives real keyboard focus + screen-reader semantics for free.
class _PressableTap extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Widget child;

  const _PressableTap({required this.onTap, required this.borderRadius, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        focusColor: Colors.white.withValues(alpha: 0.12),
        child: child,
      ),
    );
  }
}

/// Small neumorphic "Lembrar-me" checkbox + label, real [Checkbox] under
/// the hood so it stays keyboard/screen-reader accessible.
class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMeCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: BorderSide.none,
                fillColor: WidgetStateProperty.all(AuthColors.surfaceInset),
                checkColor: AuthColors.accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Lembrar-me', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AuthColors.hint)),
          ],
        ),
      ),
    );
  }
}

/// Logo mark badge: an ascending 3-bar chart (financial growth), matching
/// the app's own launcher icon motif. The original three EQUAL horizontal
/// bars read as a hamburger-menu glyph in a screen with no menu -- swapped
/// for uneven, bottom-aligned, ascending bars so it reads unambiguously as
/// a chart/brand mark instead. Fixed rose-alt tint so it renders identically
/// regardless of the dashboard's active color scheme.
class AuthLogoMark extends StatelessWidget {
  final double size;
  const AuthLogoMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final barWidth = size * (4.4 / 24);
    final gap = size * (2.2 / 24);
    final heights = [size * (7 / 24), size * (11 / 24), size * (15 / 24)];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.circular(size * (6 / 24)),
        boxShadow: AuthColors.outset,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Container(
                width: barWidth,
                height: heights[i],
                decoration: BoxDecoration(
                  color: i == 2 ? AuthColors.accent : AuthColors.primaryAlt,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
