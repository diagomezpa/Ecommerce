import 'package:flutter/material.dart';
import 'package:pragma_design_system/pragma_design_system.dart';

/// SupportPage - Customer support and contact page for the eCommerce application
///
/// This page provides customers with support contact information and a contact form
/// to reach out to the support team for assistance with orders, products, or payments.
///
/// **Features:**
/// - Static contact information display
/// - Support message and instructions
/// - Contact form with validation
/// - Form submission with success dialog
///
/// **Design System Usage:**
/// - AppPage: Main page structure
/// - AppSection: Content sections
/// - AppCard: Information and form containers
/// - AppText: Typography hierarchy
/// - AppFormField: Form input fields
/// - AppButton: Submit action
/// - AppSpacer: Consistent spacing
/// - AppIcon: Visual elements
/// - AppDialog: Success feedback
///
/// **Form Validation:**
/// - All fields are required
/// - Real-time validation feedback
/// - Submit prevention when invalid
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Validation state
  String? _nameError;
  String? _emailError;
  String? _messageError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Validates all form fields
  bool _validateForm() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Name is required' : null;
      _emailError = _emailController.text.trim().isEmpty ? 'Email is required' : null;
      _messageError = _messageController.text.trim().isEmpty ? 'Message is required' : null;
    });

    return _nameError == null && _emailError == null && _messageError == null;
  }

  /// Handles form submission
  void _handleSubmit(BuildContext context) {
    if (_validateForm()) {
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      // Show success dialog
      AppDialog.show(
        context: context,
        title: 'Thank You',
        content: AppText(
          'Thank you for contacting us. Our support team will reach out to you soon.',
          variant: AppTextVariant.bodyMedium,
        ),
        actions: [
          AppButton(
            text: 'OK',
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Support',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSpacer(size: AppSpacerSize.large),
            
            // SECTION 1: Contact Information
            _buildContactInformation(),
            
            const AppSpacer(size: AppSpacerSize.large),
            
            // SECTION 2: Informational Text
            _buildSupportMessage(),
            
            const AppSpacer(size: AppSpacerSize.large),
            
            // SECTION 3: Contact Form
            _buildContactForm(),
            
            const AppSpacer(size: AppSpacerSize.extraLarge),
          ],
        ),
      ),
    );
  }

  /// SECTION 1: Contact Information
  Widget _buildContactInformation() {
    return AppSection(
      title: 'Contact Information',
      child: Column(
        children: [
          const AppSpacer(size: AppSpacerSize.medium),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone
                Row(
                  children: [
                    AppIcon(
                      Icons.phone,
                      size: AppIconSize.medium,
                    ),
                    const AppSpacer(size: AppSpacerSize.medium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Phone',
                          variant: AppTextVariant.bodyMedium,
                        ),
                        const AppSpacer(size: AppSpacerSize.extraSmall),
                        AppText(
                          '+57 300 123 4567',
                          variant: AppTextVariant.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const AppSpacer(size: AppSpacerSize.large),
                
                // Email
                Row(
                  children: [
                    AppIcon(
                      Icons.email,
                      size: AppIconSize.medium,
                    ),
                    const AppSpacer(size: AppSpacerSize.medium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Email',
                          variant: AppTextVariant.bodyMedium,
                        ),
                        const AppSpacer(size: AppSpacerSize.extraSmall),
                        AppText(
                          'support@pragma.com',
                          variant: AppTextVariant.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const AppSpacer(size: AppSpacerSize.large),
                
                // Address
                Row(
                  children: [
                    AppIcon(
                      Icons.location_on,
                      size: AppIconSize.medium,
                    ),
                    const AppSpacer(size: AppSpacerSize.medium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Address',
                          variant: AppTextVariant.bodyMedium,
                        ),
                        const AppSpacer(size: AppSpacerSize.extraSmall),
                        AppText(
                          'Bogotá, Colombia',
                          variant: AppTextVariant.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION 2: Informational Text
  Widget _buildSupportMessage() {
    return AppSection(
      title: 'How We Can Help',
      child: Column(
        children: [
          const AppSpacer(size: AppSpacerSize.medium),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIcon(
                      Icons.support_agent,
                      size: AppIconSize.large,
                    ),
                    const AppSpacer(size: AppSpacerSize.medium),
                    Expanded(
                      child: AppText(
                        'Support Team',
                        variant: AppTextVariant.titleMedium,
                      ),
                    ),
                  ],
                ),
                
                const AppSpacer(size: AppSpacerSize.medium),
                
                AppText(
                  'If you have any questions about your orders, products, or payments, our support team is ready to help you. Please fill the form below and we will contact you shortly.',
                  variant: AppTextVariant.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION 3: Contact Form
  Widget _buildContactForm() {
    return AppSection(
      title: 'Contact Form',
      child: Column(
        children: [
          const AppSpacer(size: AppSpacerSize.medium),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form header
                Row(
                  children: [
                    AppIcon(
                      Icons.message,
                      size: AppIconSize.medium,
                    ),
                    const AppSpacer(size: AppSpacerSize.medium),
                    AppText(
                      'Send us a message',
                      variant: AppTextVariant.titleMedium,
                    ),
                  ],
                ),
                
                const AppSpacer(size: AppSpacerSize.large),
                
                // Name field
                AppFormField(
                  label: 'Name',
                  controller: _nameController,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() {
                        _nameError = _nameController.text.trim().isEmpty 
                            ? 'Name is required' 
                            : null;
                      });
                    }
                  },
                ),
                
                // Name validation error
                if (_nameError != null) ...[
                  const AppSpacer(size: AppSpacerSize.small),
                  AppText(
                    _nameError!,
                    variant: AppTextVariant.bodySmall,
                  ),
                ],
                
                const AppSpacer(size: AppSpacerSize.medium),
                
                // Email field
                AppFormField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = _emailController.text.trim().isEmpty 
                            ? 'Email is required' 
                            : null;
                      });
                    }
                  },
                ),
                
                // Email validation error
                if (_emailError != null) ...[
                  const AppSpacer(size: AppSpacerSize.small),
                  AppText(
                    _emailError!,
                    variant: AppTextVariant.bodySmall,
                  ),
                ],
                
                const AppSpacer(size: AppSpacerSize.medium),
                
                // Message field
                AppFormField(
                  label: 'Message',
                  controller: _messageController,
                  maxLines: 4,
                  onChanged: (_) {
                    if (_messageError != null) {
                      setState(() {
                        _messageError = _messageController.text.trim().isEmpty 
                            ? 'Message is required' 
                            : null;
                      });
                    }
                  },
                ),
                
                // Message validation error
                if (_messageError != null) ...[
                  const AppSpacer(size: AppSpacerSize.small),
                  AppText(
                    _messageError!,
                    variant: AppTextVariant.bodySmall,
                  ),
                ],
                
                const AppSpacer(size: AppSpacerSize.large),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Send Message',
                    variant: AppButtonVariant.primary,
                    icon: Icons.send,
                    onPressed: () => _handleSubmit(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}