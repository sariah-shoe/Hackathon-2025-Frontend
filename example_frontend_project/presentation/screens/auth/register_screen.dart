import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ironiq/config/app_config.dart';
import 'package:ironiq/presentation/blocs/auth/auth_bloc.dart';
import 'package:ironiq/presentation/blocs/auth/auth_event.dart';
import 'package:ironiq/presentation/blocs/auth/auth_state.dart';
import 'package:ironiq/presentation/screens/home/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  void _populateDevCredentials() {
    setState(() {
      _firstNameController.text = 'John';
      _lastNameController.text = 'Doe';
      _emailController.text = 'dev@ironiq.dev';
      _passwordController.text = 'Test1234!';
      _confirmPasswordController.text = 'Test1234!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        }
      },

      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Colors.black,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Development quick-fill button
              if (AppConfig.isDevelopment)
                IconButton(
                  icon: const Icon(Icons.developer_mode),
                  onPressed: _populateDevCredentials,
                  tooltip: 'Fill dev credentials',
                ),
            ],
          ),
          body: SafeArea(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: null),
                        TextFormField(
                          controller: _firstNameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'REGISTER',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 