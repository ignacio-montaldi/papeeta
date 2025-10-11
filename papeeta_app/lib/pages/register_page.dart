import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/services/socket_service.dart';

import 'package:papeeta/helpers/mostrar_alerta.dart';

import 'package:papeeta/widgets/logo.dart';
import 'package:papeeta/widgets/custom_input.dart';
import 'package:papeeta/widgets/labels.dart';
import 'package:papeeta/widgets/boton_azul.dart';

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
                Logo(
                  titulo: 'Registro',
                ),
                _Form(),
                Labels(
                  ruta: 'login',
                  titulo: '¿Ya tienes una cuenta?',
                  subtitulo: 'Ingresa ahora!',
                ),
                Text(
                  'Terminos y condiciones de uso',
                  style: TextStyle(fontWeight: FontWeight.w200),
                )
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
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.person_2_outlined,
            placeholder: 'Nombre',
            textController: nameCtrl,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passwordCtrl,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          BotonAzul(
            text: "Crear cuenta",
            onPressed: authService.autenticando
                ? () {}
                : () async {
                    final registroOk = await authService.register(
                        nameCtrl.text, emailCtrl.text, passwordCtrl.text);

                    if (!context.mounted) return;

                    if (registroOk == true) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(context, 'usuarios');
                    } else {
                      mostrarAlerta(context, 'Registro incorrecto', registroOk);
                    }
                  },
          )
        ],
      ),
    );
  }
}
