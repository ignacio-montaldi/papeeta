import 'package:flutter/material.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:papeeta/widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(titulo: 'Papeeta'),
                _Form(),
                LoginLabels(
                  ruta: 'register',
                  titulo: '¿No tienes cuenta?',
                  subtitulo: "Crea una ahora!",
                ),
              ],
            ),
          ),
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
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, 'home');
        } else if (state is AuthError) {
          mostrarAlerta(
            context,
            "Ups!",
            state.message,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          children: [
            CustomInput(
              icon: Icons.mail_outline,
              placeholder: 'Correo',
              keyboardType: TextInputType.emailAddress,
              textController: emailCtrl,
            ),
            const SizedBox(height: 20),
            CustomInput(
              icon: Icons.lock_outline,
              placeholder: 'Contraseña',
              textController: passwordCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isAutenticando = state is AuthLoading;

                return ButtonComponent(
                  text: "Ingrese",
                  onPressed: isAutenticando
                      ? () => {}
                      : () {
                          FocusScope.of(context).unfocus();
                          context.read<AuthBloc>().add(
                                LoginRequested(
                                  emailCtrl.text.trim(),
                                  passwordCtrl.text.trim(),
                                ),
                              );
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
