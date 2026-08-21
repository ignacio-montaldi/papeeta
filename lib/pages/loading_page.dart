import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

/// Primera pantalla que ve el usuario mientras se resuelve la sesión.
///
/// Antes era un "Espere..." sin marca; ahora es un splash con el logo y el
/// púrpura, para que el arranque no se vea como un error.
class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // En oscuro, `primary` es un lila claro: usarlo a pantalla completa daría
    // un flash brillante al arrancar. El contenedor de marca es el equivalente
    // oscuro correcto.
    final fondo = context.isDark ? colors.primaryContainer : colors.primary;
    final sobreFondo =
        context.isDark ? colors.onPrimaryContainer : colors.onPrimary;

    return Scaffold(
      backgroundColor: fondo,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/');
          } else if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                child: Image.asset('images/app_icon/launcher_icon.png'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Papeeta',
                style: AppTypography.display.copyWith(color: sobreFondo),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(sobreFondo),
                  backgroundColor: sobreFondo.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
