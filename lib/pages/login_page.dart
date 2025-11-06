import 'package:flutter/material.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:provider/provider.dart';

import 'package:papeeta/services/auth_service.dart';

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
    final authService = Provider.of<AuthService>(context);

    return Container(
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
          ButtonComponent(
            text: "Ingrese",
            onPressed: authService.autenticando
                ? () => {}
                : () async {
                    FocusScope.of(context).unfocus();
                    bool loginOk = await authService.login(
                      emailCtrl.text.trim(),
                      passwordCtrl.text.trim(),
                    );

                    if (!context.mounted) return;

                    if (loginOk) {
                      Navigator.pushReplacementNamed(context, 'home');
                    } else {
                      mostrarAlerta(
                        context,
                        "Login incorrecto",
                        "Revise sus credenciales nuevamente",
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}
