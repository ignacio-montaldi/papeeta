import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Crear grupo',
      onClose: () => Navigator.pop(context),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Nombre del grupo',
              hint: 'Ej. Recetas de la familia',
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresá un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Descripción (opcional)',
              hint: 'Ej. Lo que cocinamos los domingos',
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Crear grupo',
              icon: Icons.group_add_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _crearGrupo,
            ),
          ],
        ),
      ),
    );
  }

  void _crearGrupo() {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();

    context.read<GroupsBloc>().add(
          CreateGroup(
            name: _nameController.text.trim(),
            description: description.isEmpty ? null : description,
          ),
        );
    Navigator.pop(context);
  }
}
