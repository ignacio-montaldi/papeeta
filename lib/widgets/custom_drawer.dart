import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/global/enviroment.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return SafeArea(
      bottom: false,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      user != null && user.imagenPerfil != null
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${Enviroment.uploadsUrl}${user.imagenPerfil}',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                      const SizedBox(width: 12),
                      const Text(
                        'Papeeta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (user != null &&
                      user.alias != null &&
                      user.alias!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.alias!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.nombreUsuario}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ] else if (user != null && user.nombreUsuario.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.nombreUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Lista principal
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: const Text('Home'),
                          onTap: () {
                            context.pop();
                            context.go('/');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Categorías'),
                          onTap: () {
                            context.pop();
                            context.push('/categories');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.group),
                          title: const Text('Mis Grupos'),
                          onTap: () {
                            context.pop();
                            context.push('/groups');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Perfil'),
                          onTap: () {
                            context.pop();
                            context.push('/profile');
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
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
