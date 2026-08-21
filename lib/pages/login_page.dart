import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/login_labels.dart';
import 'package:papeeta/widgets/logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Logo(titulo: 'Papeeta'),
                      _Form(),
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.xl),
                        child: LoginLabels(
                          ruta: 'register',
                          titulo: '¿Todavía no tenés cuenta?',
                          subtitulo: 'Creá una ahora',
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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _ingresar() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          LoginRequested(_emailCtrl.text.trim(), _passwordCtrl.text.trim()),
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
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          children: [
            AppTextField(
              label: 'Correo',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
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
                final autenticando = state is AuthLoading;
                return AppButton(
                  label: 'Ingresar',
                  isLoading: autenticando,
                  loadingLabel: 'Ingresando…',
                  onPressed: autenticando ? null : _ingresar,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
