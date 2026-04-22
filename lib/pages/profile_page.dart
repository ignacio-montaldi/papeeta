import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _aliasCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordNuevaCtrl = TextEditingController();
  final _passwordActualCtrl = TextEditingController();

  File? _imagenSeleccionada;
  String? _imagenUrlAnterior;
  bool _mostrarPassword = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      _aliasCtrl.text = user.alias ?? '';
      _emailCtrl.text = user.email ?? '';
      _imagenUrlAnterior = user.imagenPerfil;
    }
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _emailCtrl.dispose();
    _passwordNuevaCtrl.dispose();
    _passwordActualCtrl.dispose();
    super.dispose();
  }

  void _onImageSourceSelected(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  void _guardar() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final alias = _aliasCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final passwordNueva = _passwordNuevaCtrl.text.trim();
    final passwordActual = _passwordActualCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El correo es obligatorio'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (alias.isEmpty && passwordNueva.isEmpty && _imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No realizaste ningún cambio'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      UpdateProfileRequested(
        alias: alias,
        email: email,
        passwordNueva: passwordNueva.isNotEmpty ? passwordNueva : null,
        passwordActual: passwordNueva.isNotEmpty ? passwordActual : null,
        imagen: _imagenSeleccionada,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is! ProfileUpdating && !(current is Authenticated && previous is ProfileUpdateError),
        listener: (context, state) {
          if (state is ProfileUpdateError) {
            final msg = state.message.replaceFirst('Exception: ', '');
            String mensaje;
            if (msg.contains('EMAIL_IN_USE')) {
              mensaje = 'El correo ya está en uso';
            } else if (msg.contains('PASSWORD_CURRENT_INVALID')) {
              mensaje = 'Contraseña actual incorrecta';
            } else if (msg.contains('PASSWORD_CURRENT_REQUIRED')) {
              mensaje = 'Ingresá tu contraseña actual para cambiarla';
            } else if (msg.contains('UPDATE_FAILED')) {
              mensaje = 'No se pudo actualizar el perfil';
            } else {
              mensaje = 'Ocurrió un error inesperado';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensaje),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is Authenticated) {
            final newImg = state.user.imagenPerfil;
            if (newImg != null && newImg != _imagenUrlAnterior) {
              _imagenUrlAnterior = newImg;
              _imagenSeleccionada = null;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is ProfileUpdating;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 30),
                  CustomInput(
                    icon: Icons.person_outline,
                    placeholder: 'Alias',
                    textController: _aliasCtrl,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    icon: Icons.mail_outline,
                    placeholder: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    textController: _emailCtrl,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cambiar contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    icon: Icons.lock_outline,
                    placeholder: 'Nueva contraseña',
                    textController: _passwordNuevaCtrl,
                    isPassword: !_mostrarPassword,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    icon: Icons.lock_outline,
                    placeholder: 'Contraseña actual',
                    textController: _passwordActualCtrl,
                    isPassword: !_mostrarPassword,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _mostrarPassword = !_mostrarPassword),
                      icon: Icon(
                        _mostrarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(_mostrarPassword ? 'Ocultar' : 'Mostrar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonComponent(
                      text: 'Guardar cambios',
                      onPressed: isLoading ? () {} : _guardar,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = _imagenSeleccionada != null
        ? _imagenSeleccionada!.path
        : _imagenUrlAnterior != null
        ? '${Enviroment.uploadsUrl}$_imagenUrlAnterior'
        : null;

    final isFile = imageUrl != null && imageUrl.startsWith('/');

    return GestureDetector(
      onTap: () => ImageSourceSheet.show(
        context,
        onImageSourceSelected: _onImageSourceSelected,
      ),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: imageUrl != null
                ? (isFile
                    ? FileImage(File(imageUrl))
                    : CachedNetworkImageProvider(imageUrl))
                : null,
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
