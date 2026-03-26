import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      Navigator.pop(context); //Cierra primero el drawer
                      Navigator.pushReplacementNamed(context, 'home');
                    },
                  ),
                  ListTile(
                    title: const Text('Categorías'),
                    onTap: () {
                      Navigator.pop(context); //Cierra primero el drawer
                      Navigator.pushNamed(context, 'categories');
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
                Navigator.pushReplacementNamed(context, 'login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
