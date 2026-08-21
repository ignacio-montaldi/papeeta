import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/widgets/ds/ds.dart';
import 'package:papeeta/widgets/image_source_sheet.dart';

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

  Future<void> _elegirImagen(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imagenSeleccionada = File(picked.path));
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
      showAppSnackBar(
        context,
        message: 'El correo es obligatorio',
        intent: SnackIntent.error,
      );
      return;
    }

    if (alias.isEmpty && passwordNueva.isEmpty && _imagenSeleccionada == null) {
      showAppSnackBar(
        context,
        message: 'No hiciste ningún cambio',
        intent: SnackIntent.warning,
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
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is! ProfileUpdating &&
            !(current is Authenticated && previous is ProfileUpdateError),
        listener: (context, state) {
          if (state is ProfileUpdateError) {
            showAppSnackBar(
              context,
              message: _traducirError(state.message),
              intent: SnackIntent.error,
            );
          } else if (state is Authenticated) {
            final nueva = state.user.imagenPerfil;
            if (nueva != null && nueva != _imagenUrlAnterior) {
              setState(() {
                _imagenUrlAnterior = nueva;
                _imagenSeleccionada = null;
              });
            }
            showAppSnackBar(
              context,
              message: 'Perfil actualizado',
              intent: SnackIntent.success,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final guardando = state is ProfileUpdating;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [
                Center(child: _avatar()),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  label: 'Alias',
                  icon: Icons.person_outline_rounded,
                  controller: _aliasCtrl,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Correo electrónico',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Cambiar contraseña',
                  style: AppTypography.title.copyWith(
                    fontSize: 16,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nueva contraseña',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordNuevaCtrl,
                  isPassword: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Contraseña actual',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordActualCtrl,
                  isPassword: true,
                  helper: 'Solo hace falta si vas a cambiar la contraseña',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Guardar cambios',
                  isLoading: guardando,
                  loadingLabel: 'Guardando…',
                  onPressed: guardando ? null : _guardar,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _avatar() {
    final colors = context.colors;

    final ruta = _imagenSeleccionada?.path ??
        (_imagenUrlAnterior != null
            ? '${Enviroment.uploadsUrl}$_imagenUrlAnterior'
            : null);
    final esArchivo = _imagenSeleccionada != null;

    return GestureDetector(
      onTap: () => ImageSourceSheet.show(
        context,
        onImageSourceSelected: _elegirImagen,
      ),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: ruta == null
                ? Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: context.semantic.emptyIcon,
                  )
                : esArchivo
                    ? Image.file(File(ruta), fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: ruta,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: context.semantic.emptyIcon,
                        ),
                      ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Traduce los códigos que devuelve la API a mensajes en español.
///
/// El design system generaliza este patrón: nunca se muestra el código técnico
/// crudo al usuario.
String _traducirError(String raw) {
  final msg = raw.replaceFirst('Exception: ', '');

  if (msg.contains('EMAIL_IN_USE')) return 'Ese correo ya está en uso';
  if (msg.contains('PASSWORD_CURRENT_INVALID')) {
    return 'La contraseña actual no es correcta';
  }
  if (msg.contains('PASSWORD_CURRENT_REQUIRED')) {
    return 'Ingresá tu contraseña actual para cambiarla';
  }
  if (msg.contains('UPDATE_FAILED')) return 'No se pudo actualizar el perfil';

  return 'Ocurrió un error inesperado';
}
