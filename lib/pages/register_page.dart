import 'package:flutter/material.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/widgets/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                Logo(titulo: 'Registro'),
                _Form(),
                LoginLabels(
                  ruta: 'login',
                  titulo: '¿Ya tienes una cuenta?',
                  subtitulo: 'Ingresa ahora!',
                ),
                Text(
                  'Terminos y condiciones de uso',
                  style: TextStyle(fontWeight: FontWeight.w200),
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
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, 'home');
        } else if (state is AuthError) {
          mostrarAlerta(context, 'Ups!', state.message);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          children: [
            CustomInput(
              icon: Icons.person_2_outlined,
              placeholder: 'Nombre',
              textController: nameCtrl,
            ),
            const SizedBox(height: 20),
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
                  text: "Crear cuenta",
                  onPressed: isAutenticando
                      ? () {}
                      : () {
                          context.read<AuthBloc>().add(
                                RegisterRequested(
                                  nameCtrl.text.trim(),
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
