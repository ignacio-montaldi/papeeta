import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        children: [
          _Header(
            alias: user?.alias,
            nombreUsuario: user?.nombreUsuario,
            imagenPerfil: user?.imagenPerfil,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _Item(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  onTap: () {
                    context.pop();
                    context.go('/');
                  },
                ),
                _Item(
                  icon: Icons.category_rounded,
                  label: 'Categorías',
                  onTap: () {
                    context.pop();
                    context.push('/categories');
                  },
                ),
                _Item(
                  icon: Icons.group_rounded,
                  label: 'Mis grupos',
                  onTap: () {
                    context.pop();
                    context.push('/groups');
                  },
                ),
                _Item(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: _Item(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.alias, this.nombreUsuario, this.imagenPerfil});

  final String? alias;
  final String? nombreUsuario;
  final String? imagenPerfil;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nombre = alias?.isNotEmpty == true ? alias! : nombreUsuario;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.paddingOf(context).top + AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imagenPerfil != null && imagenPerfil!.isNotEmpty)
                AppAvatar(
                  name: nombre ?? 'Papeeta',
                  imageUrl: '${Enviroment.uploadsUrl}$imagenPerfil',
                  size: 52,
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 30,
                    color: colors.onPrimary,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Papeeta',
                  style: AppTypography.headline.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (nombre != null && nombre.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(color: colors.onPrimary),
            ),
            if (nombreUsuario != null && nombreUsuario!.isNotEmpty)
              Text(
                '@$nombreUsuario',
                style: AppTypography.label.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.75),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(
        label,
        style: AppTypography.body.copyWith(
          fontSize: 15,
          color: colors.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}
