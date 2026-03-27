import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  'Papeeta',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            // Lista principal
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: const Text('Home'),
                    onTap: () {
                      context.pop();
                      context.go('/');
                    },
                  ),
                  ListTile(
                    title: const Text('Categorías'),
                    onTap: () {
                      context.pop();
                      context.push('/categories');
                    },
                  ),
                ],
              ),
            ),
            // Ítem fijo al fondo
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
