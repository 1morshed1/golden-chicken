import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/widgets/app_button.dart';
import 'package:golden_chicken/core/widgets/app_text_field.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_event.dart';
import 'package:golden_chicken/features/profile/presentation/bloc/profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: const _EditProfileForm(),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && _initialized) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated')),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileLoaded && !_initialized) {
            _nameController.text = state.profile.fullName;
            _phoneController.text = state.profile.phone;
            _locationController.text = state.profile.location ?? '';
            _initialized = true;
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  hint: '+880...',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'City or area',
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Save',
                  isLoading: state is ProfileSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          ProfileUpdated(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
          ),
        );
  }
}
