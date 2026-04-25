import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/core/widgets/app_button.dart';
import 'package:golden_chicken/core/widgets/app_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.signUp,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppTextField(
                label: l10n.fullName,
                hint: 'John Doe',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: l10n.phoneNumber,
                hint: '01XXXXXXXXX',
                prefixText: '+880 ',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: l10n.password,
                hint: '••••••••',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: const Icon(Icons.visibility_off_outlined),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.signUp,
                onPressed: () => context.go('/main/chat'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.alreadyHaveAccount),
                  AppButton(
                    label: l10n.login,
                    variant: AppButtonVariant.text,
                    onPressed: () => context.go('/auth/login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
