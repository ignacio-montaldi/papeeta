import 'package:flutter/material.dart';
import 'package:papeeta/pages/pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

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
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionDuration: const Duration(milliseconds: 0),
              ),
            );
          } else if (state is Unauthenticated) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoginPage(),
                transitionDuration: const Duration(milliseconds: 0),
              ),
            );
          }
        },
        child: const Center(child: Text('Espere...')),
      ),
    );
  }
}
