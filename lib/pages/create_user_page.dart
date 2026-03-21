import 'package:flutter/material.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import '../services/user_session.dart';
import '../helpers/form_validation_helper.dart';
import '../helpers/user_creation_helper.dart';
import '../helpers/user_message_helper.dart';

/// CreateUserPage - User registration page for the eCommerce application
///
/// This page provides user registration with personal information fields,
/// create user functionality, and success/error handling.
///
/// **Features:**
/// - Personal information input fields with validation
/// - Create user button with loading states
/// - Success/error message display
/// - Form validation and submission
/// - User creation using fake API
///
/// **Design System Usage:**
/// - AppPage: Main page structure
/// - AppFormSection: Content sections
/// - AppCard: Form container
/// - AppButton: Create user action button
/// - AppText: Typography hierarchy
/// - AppSpacer: Consistent spacing
/// - AppFormField: Input fields
/// - AppSnackbar: Success/error feedback
/// - AppDialog: User creation confirmation
///
/// **State Management:**
/// - Uses UserBloc with CreateUserEvent
/// - Handles user creation responses and errors
/// - State derived from user creation success/failure
class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  late final UserBloc userBloc;

  // Form controllers
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Component state
  User? _createdUser;
  String? _userError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserBloc();
  }

  void _initializeUserBloc() {
    userBloc = initializeUserBloc((dynamic userResult) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (userResult is User) {
            _createdUser = userResult;
            _userError = null;
            _handleUserCreationSuccess();
          } else if (userResult == null) {
            _createdUser = null;
            _userError = null;
          } else if (userResult is String) {
            _userError = userResult;
            _createdUser = null;
            _handleUserCreationError();
          }
        });
      }
    });
  }

  void _handleCreateUser() {
    // Validate form using helper
    if (!_validateForm()) {
      setState(() {}); // Trigger rebuild to show validation messages
      return;
    }

    setState(() {
      _isLoading = true;
      _userError = null;
    });

    // Build User object using helper
    final user = UserCreationHelper.createUserFromFormData(
      firstname: _firstnameController.text,
      lastname: _lastnameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    // Create user using UserBloc
    userBloc.eventSink.add(CreateUserEvent(user));
  }

  void _handleUserCreationSuccess() {
    // Store user in session for persistence using helper
    try {
      final userSession = UserSession();
      final userForStorage = UserCreationHelper.createUserWithFormData(
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      userSession.addUser(userForStorage);
    } catch (e) {
      // User might already exist (rare edge case)
      print('${UserSessionMessages.sessionWarningPrefix} ${e.toString()}');
    }

    // Clear form
    _clearForm();

    // Show success snackbar using helper
    AppSnackbar.success(
      context,
      message: UserMessageHelper.getSuccessSnackbarMessage(),
    );

    // Show user details dialog
    _showUserCreatedDialog();
  }

  void _handleUserCreationError() {
    AppSnackbar.error(
      context,
      message: UserMessageHelper.getErrorSnackbarMessage(_userError),
    );
  }

  void _showUserCreatedDialog() {
    if (_createdUser == null) return;

    AppDialog.show(
      context: context,
      title: UserMessageHelper.getSuccessDialogTitle(),
      content: AppText(
        UserMessageHelper.getSuccessDialogContent(_createdUser!),
      ),
      actions: [
        AppButton(
          text: UserMessageHelper.getSuccessDialogActionText(),
          variant: AppButtonVariant.primary,
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pushReplacementNamed(context, '/login'); // Go to login
          },
        ),
      ],
    );
  }

  bool _validateForm() {
    return FormValidationHelper.validateUserRegistrationForm(
      firstname: _firstnameController.text,
      lastname: _lastnameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  void _clearForm() {
    _firstnameController.clear();
    _lastnameController.clear();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    // Note: UserBloc disposal is handled internally by the fake_maker_api_pragma_api
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: 'Create Account', body: _buildBody());
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ATOM: Top spacing
              const AppSpacer(size: AppSpacerSize.large),

              // MOLECULE: Header section
              _buildHeaderSection(),

              // ATOM: Section spacing
              const AppSpacer(size: AppSpacerSize.extraLarge),

              // ORGANISM: User creation form
              _buildUserForm(),

              // Bottom spacing
              const AppSpacer(size: AppSpacerSize.extraLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// MOLECULE: Header section with title and description
  Widget _buildHeaderSection() {
    return Column(
      children: [
        const AppText(
          'Join Our Store',
          variant: AppTextVariant.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const AppSpacer(size: AppSpacerSize.medium),
        AppText(
          'Create your account to start shopping and track your orders',
          variant: AppTextVariant.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// ORGANISM: User creation form with input fields and submit button
  Widget _buildUserForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Personal Information Section
          _buildPersonalInfoSection(),

          const AppSpacer(size: AppSpacerSize.large),

          // Account Information Section
          _buildAccountInfoSection(),

          const AppSpacer(size: AppSpacerSize.extraLarge),

          // Create User button
          AppButton(
            text: _isLoading ? 'Creating Account...' : 'Create Account',
            variant: AppButtonVariant.primary,
            onPressed: _isLoading ? null : _handleCreateUser,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  /// MOLECULE: Personal information section
  Widget _buildPersonalInfoSection() {
    return AppFormSection(
      title: 'Personal Information',
      description: 'Enter your personal details',
      children: [
        // First Name field
        _buildFormField(
          label: 'First Name',
          hintText: 'Enter your first name',
          controller: _firstnameController,
          validator: FormValidationHelper.validateFirstname,
        ),

        const AppSpacer(size: AppSpacerSize.large),

        // Last Name field
        _buildFormField(
          label: 'Last Name',
          hintText: 'Enter your last name',
          controller: _lastnameController,
          validator: FormValidationHelper.validateLastname,
        ),
      ],
    );
  }

  /// MOLECULE: Account information section
  Widget _buildAccountInfoSection() {
    return AppFormSection(
      title: 'Account Information',
      description: 'Set up your account credentials',
      children: [
        // Email field
        _buildFormField(
          label: 'Email',
          hintText: 'Enter your email address',
          controller: _emailController,
          validator: FormValidationHelper.validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),

        const AppSpacer(size: AppSpacerSize.large),

        // Username field
        _buildFormField(
          label: 'Username',
          hintText: 'Choose a username',
          controller: _usernameController,
          validator: FormValidationHelper.validateUsername,
        ),

        const AppSpacer(size: AppSpacerSize.large),

        // Password field
        _buildFormField(
          label: 'Password',
          hintText: 'Create a secure password',
          controller: _passwordController,
          validator: FormValidationHelper.validatePassword,
          obscureText: true,
        ),
      ],
    );
  }

  /// ATOM: Reusable form field with validation
  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, variant: AppTextVariant.labelLarge),
        const AppSpacer(size: AppSpacerSize.small),
        AppFormField(
          controller: controller,
          hintText: hintText,
          enabled: !_isLoading,
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
        // Custom validation message
        if (controller.text.isNotEmpty && validator(controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AppText(
              validator(controller.text)!,
              variant: AppTextVariant.bodySmall,
            ),
          ),
      ],
    );
  }
}
