import 'package:flutter/material.dart';
import 'package:pragma_design_system/pragma_design_system.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// LoginPage - Authentication page for the eCommerce application
///
/// This page provides user authentication with username and password fields,
/// login functionality, and error handling.
///
/// **Features:**
/// - Username and password input fields with validation
/// - Login button with loading states
/// - Error message display
/// - Form validation and submission
/// - Authentication using fake API
///
/// **Design System Usage:**
/// - AppPage: Main page structure
/// - AppSection: Content sections
/// - AppCard: Form container
/// - AppButton: Login action button
/// - AppText: Typography hierarchy
/// - AppSpacer: Consistent spacing
/// - AppTextField: Input fields
/// - AppEmptyStateSection: Error states
///
/// **State Management:**
/// - Uses AuthBloc with LoginEvent
/// - Handles authentication responses and errors
/// - State derived from auth data presence
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthBloc authBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _authToken;
  String? _authError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthBloc();
  }

  void _initializeAuthBloc() {
    authBloc = initializeAuthBloc((dynamic authResult) {
      setState(() {
        _isLoading = false;
        if (authResult is LoginResponse) {
          _authToken = authResult.token;
          _authError = null;
          _handleLoginSuccess();
        } else if (authResult == null) {
          _authToken = null;
          _authError = null;
        } else if (authResult is String) {
          _authError = authResult;
          _authToken = null;
        }
      });
    });
  }

  void _handleLogin() {
    /// Verifica si el formulario es válido antes de proceder con.
    /// 
    /// Este condicional evalúa dos condiciones:
    /// 1. Primero verifica que `_formKey.currentState` no sea null usando el operador `?.`
    /// 2. Si no es null, llama al método `validate()` que retorna true si todos los campos del formulario son válidos
    /// 3. Si `_formKey.currentState` es null, usa el operador `??` para devolver false como valor por defecto
    /// 
    /// El resultado final es true solo si el formulario existe y todos sus campos pasan la validación.
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _authError = null;
      });
      
      // Consumir API real de autenticación
      authBloc.add(LoginEvent(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }

  void _handleLoginSuccess() {
    // Show success message with token and navigate
    AppDialog.show(
      context: context,
      title: 'Login Successful',
      content: AppText('Welcome! You have been successfully logged in.\\n\\nToken: ${_authToken ?? "Not available"}'),
      actions: [
        AppButton(
          text: 'Continue',
          variant: AppButtonVariant.primary,
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pushReplacementNamed(context, '/home'); // Navigate to home
          },
        ),
      ],
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void dispose() {
    // Note: AuthBloc disposal is handled internally by the fake_maker_api_pragma_api
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Login',
          variant: AppTextVariant.titleLarge,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ATOM: Top spacing
            const AppSpacer(size: AppSpacerSize.extraLarge),
            
            // MOLECULE: Welcome section
            _buildWelcomeSection(),
            
            // ATOM: Section spacing
            const AppSpacer(size: AppSpacerSize.extraLarge),
            
            // ORGANISM: Login form
            _buildLoginForm(),
            
            // Error message display
            if (_authError != null) ...[
              const AppSpacer(size: AppSpacerSize.large),
              _buildErrorMessage(),
            ],
            
            // Bottom spacing
            const AppSpacer(size: AppSpacerSize.extraLarge),
          ],
        ),
      ),
    );
  }

  /// MOLECULE: Welcome section with title and description
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const AppText(
          'Welcome Back!',
          variant: AppTextVariant.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const AppSpacer(size: AppSpacerSize.medium),
        const AppText(
          'Please sign in to your account to continue shopping',
          variant: AppTextVariant.bodyLarge,
          textAlign: TextAlign.center,
          color: Colors.grey,
        ),
      ],
    );
  }

  /// ORGANISM: Login form with input fields and submit button
  Widget _buildLoginForm() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username field
            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              validator: _validateUsername,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            
            const AppSpacer(size: AppSpacerSize.large),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            
            const AppSpacer(size: AppSpacerSize.extraLarge),
            
            // Login button
            AppButton(
              text: _isLoading ? 'Signing In...' : 'Sign In',
              variant: AppButtonVariant.primary,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),
            
            const AppSpacer(size: AppSpacerSize.medium),
            
            // Demo credentials helper
            _buildDemoCredentials(),
          ],
        ),
      ),
    );
  }

  /// MOLECULE: Demo credentials information
  Widget _buildDemoCredentials() {
    return AppCard(
      child: Column(
        children: [
          const AppText(
            'Demo Credentials',
            variant: AppTextVariant.titleSmall,
          ),
          const AppSpacer(size: AppSpacerSize.small),
          const AppText(
            'Username: johnd',
            variant: AppTextVariant.bodySmall,
            color: Colors.grey,
          ),
          const AppText(
            'Password: m38rmF\$',
            variant: AppTextVariant.bodySmall,
            color: Colors.grey,
          ),
          const AppSpacer(size: AppSpacerSize.small),
          AppButton(
            text: 'Use Demo Credentials',
            variant: AppButtonVariant.outline,
            onPressed: _isLoading ? null : _fillDemoCredentials,
          ),
        ],
      ),
    );
  }

  /// Fill demo credentials for quick testing
  void _fillDemoCredentials() {
    setState(() {
      _usernameController.text = 'johnd';
      _passwordController.text = 'm38rmF\$';
    });
  }

  /// MOLECULE: Error message display
  Widget _buildErrorMessage() {
    return AppCard(
      child: Row(
        children: [
          const AppIcon(
            Icons.error_outline,
            color: Colors.red,
            size: AppIconSize.medium,
          ),
          const AppSpacer(size: AppSpacerSize.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Login Failed',
                  variant: AppTextVariant.titleSmall,
                  color: Colors.red,
                ),
                AppText(
                  _authError!,
                  variant: AppTextVariant.bodyMedium,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}