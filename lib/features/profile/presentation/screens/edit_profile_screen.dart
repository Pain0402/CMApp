import 'dart:io';
import 'package:mycomicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycomicsapp/core/utils/toast_utils.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final initialProfile = ref.read(userProfileProvider).value;
    _nameController = TextEditingController(
      text: initialProfile?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(profileUpdaterProvider.notifier)
          .updateProfile(
            displayName: _nameController.text.trim(),
            avatarFile: _avatarFile,
          );

      if (mounted && ref.read(profileUpdaterProvider).hasError == false) {
        context.pop();
        ToastUtils.showSuccess(context, 'Profile updated successfully!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initialProfile = ref.watch(userProfileProvider).value;

    ref.listen<AsyncValue<void>>(profileUpdaterProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      }
    });

    final isUpdating = ref.watch(profileUpdaterProvider) is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isUpdating ? null : _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : (initialProfile?.avatarUrl != null
                                  ? NetworkImage(initialProfile!.avatarUrl!)
                                  : null)
                              as ImageProvider?,
                    child:
                        _avatarFile == null && initialProfile?.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              if (isUpdating) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
