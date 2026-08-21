import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/login_labels.dart';
import 'package:papeeta/widgets/logo.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Logo(titulo: 'Registro'),
                      const _Form(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        child: Column(
                          children: [
                            const LoginLabels(
                              ruta: 'login',
                              titulo: '¿Ya tenés una cuenta?',
                              subtitulo: 'Ingresá ahora',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Términos y condiciones de uso',
                              style: AppTypography.label.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
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

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _nombreUsuarioCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreUsuarioCtrl.dispose();
    _aliasCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _registrar() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          RegisterRequested(
            _aliasCtrl.text.trim(),
            _nombreUsuarioCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/');
        } else if (state is AuthError) {
          showAppSnackBar(
            context,
            message: state.message,
            intent: SnackIntent.error,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            AppTextField(
              label: 'Alias (opcional)',
              icon: Icons.person_outline_rounded,
              controller: _aliasCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nombre de usuario',
              icon: Icons.alternate_email_rounded,
              controller: _nombreUsuarioCtrl,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Correo',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Contraseña',
              icon: Icons.lock_outline_rounded,
              controller: _passwordCtrl,
              isPassword: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final registrando = state is AuthLoading;
                return AppButton(
                  label: 'Crear cuenta',
                  isLoading: registrando,
                  loadingLabel: 'Creando cuenta…',
                  onPressed: registrando ? null : _registrar,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
