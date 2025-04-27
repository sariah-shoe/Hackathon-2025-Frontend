import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ironiq/presentation/blocs/auth/auth_bloc.dart';
import 'package:ironiq/presentation/blocs/auth/auth_event.dart';
import 'package:ironiq/presentation/blocs/auth/auth_state.dart';
import 'package:ironiq/presentation/screens/home/main_navigation_screen.dart';
import 'package:ironiq/config/app_config.dart';
import 'package:ironiq/core/error/failures.dart';
import 'package:ironiq/core/error/authentication_failure.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  final bool _isRefreshing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  void _populateDevCredentials() {
    setState(() {
      _emailController.text = 'dev@ironiq.dev';
      _passwordController.text = 'Test1234!';
    });
  }

  String _getErrorMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      if (failure.errors?.containsKey('email') ?? false) {
        return failure.errors!['email']!.first;
      } else if (failure.errors?.containsKey('password') ?? false) {
        return failure.errors!['password']!.first;
      }
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Connection error. Please check your internet connection.';
    }
    return failure.message;
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
              content: Text(_getErrorMessage(state.failure)),
              backgroundColor: Colors.red,
              action: state.failure is NetworkFailure
                  ? SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: _handleLogin,
                    )
                  : null,
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
              'Login',
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                          Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  checkColor: Colors.white,
                                ),
                              ),
                              Text(
                                'Remember Me',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isRefreshing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
