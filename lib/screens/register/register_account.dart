import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/dialog/dialog_register.component.dart';
import 'package:social_media_app/components/field/field_default.component.dart';
import 'package:social_media_app/components/form/general_form.component.dart';
import 'package:social_media_app/screens/register/register_verify.dart';
import 'package:social_media_app/services/authentication/authentication.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/handle_icon_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthenticationServices _authServices = AuthenticationServices();
  String? _emailErrorText, _passwordErrorText, _confirmPasswordErrorText;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegisterSuccess = false;
  bool _isVisibility = false;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailErrorText = 'Email is required';
      } else if (!_isValidEmail(value)) {
        _emailErrorText = 'Enter a valid email address (example@gmail.com)';
      } else {
        _emailErrorText = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordErrorText = 'Password is required';
      } else if (!_isValidPassword(value)) {
        _passwordErrorText = 'Enter a valid password (example: Vignesh123!)';
      } else {
        _passwordErrorText = null;
      }
    });
  }

  void _validatePasswordConfirm(String password, String confirmPassword) {
    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordErrorText = 'Confirm password is required';
      } else if (!_comparePasswordConfirm(password, confirmPassword)) {
        _confirmPasswordErrorText = 'Confirmation passwords are not the same';
      } else {
        _confirmPasswordErrorText = null;
      }
    });
  }

  bool _isValidPassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool _isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool _comparePasswordConfirm(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return false;
    } else {
      return true;
    }
  }

  void _navigationToLoginScreen() {
    Navigator.pushNamed(context, '/login');
  }

  void _handleIcon(HandleIconField handle) {
    setState(() {
      switch (handle) {
        case HandleIconField.clear:
          _emailController.text = '';
          return;
        case HandleIconField.visibilityPassword:
          _obscurePassword = !_obscurePassword;
          return;
        case HandleIconField.visibilityConfirmPassword:
          _obscureConfirmPassword = !_obscureConfirmPassword;
          return;
      }
    });
  }

  Future<void> _onSubmit() async {
    late User? currentUser;
    setState(() {
      _isLoading = true;
    });
    String resultEmail = _emailController.text.trim();
    String resultPassword = _passwordController.text.trim();
    String resultConfirmPassword = _confirmPasswordController.text.trim();
    _validateEmail(resultEmail);
    _validatePassword(resultPassword);
    _validatePasswordConfirm(resultPassword, resultConfirmPassword);
    final bool isValidation = _formKey.currentState!.validate();
    if (isValidation) {
      try {
        await _authServices.createNewAccount(resultEmail, resultPassword);
        currentUser = FirebaseAuth.instance.currentUser;
        _isRegisterSuccess = (currentUser != null) ? true : false;
      } on FirebaseAuthException catch (error) {
        // ignore: avoid_print
        print("ERROR send email verify !!! $error");
        _emailErrorText = error.message;
      }
      if (_isRegisterSuccess) {
        _emailController.text = '';
        _passwordController.text = '';
        _confirmPasswordController.text = '';
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const RegisterVerifyScreen(),
        ));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFormComponent(listWidget: [
      const SizedBox(
        height: 45.0,
      ),
      DialogComponent(
        title: "Do you want to stop creating your account?",
        content: const Text(
            "If you stop now, you'll lose any progress you've made."),
        labelStatusStop: "Stop creating account",
        labelStatusContinue: "Continue creating account",
        onPressedStop: _navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: true,
      ),
      const SizedBox(
        height: 16.0,
      ),
      const Text(
        "What's your email?",
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24.0),
      ),
      const Text(
        "Enter the email where you can be contacted. No one will see this on your profile.",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
      ),
      const SizedBox(
        height: 16.0,
      ),
      Expanded(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Email Input
              InputFieldDefaultComponent(
                controller: _emailController,
                text: 'Email',
                obscure: false,
                textInputType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: const Icon(Icons.close),
                isValidation: (value) => _emailErrorText,
                onPressSuffixIcon: () => _handleIcon(
                  HandleIconField.clear,
                ),
                onTap: () {
                  setState(() {
                    _isVisibility = false;
                  });
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              //Password Input
              InputFieldDefaultComponent(
                controller: _passwordController,
                text: 'Password',
                obscure: _obscurePassword,
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.password),
                suffixIcon: _obscurePassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                isValidation: (value) => _passwordErrorText,
                onPressSuffixIcon: () => _handleIcon(
                  HandleIconField.visibilityPassword,
                ),
                onTap: () {
                  setState(() {
                    _isVisibility = true;
                  });
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              Visibility(
                visible: _isVisibility,
                child: FlutterPwValidator(
                  width: 300,
                  height: 150,
                  minLength: 8,
                  normalCharCount: 1,
                  numericCharCount: 1,
                  uppercaseCharCount: 1,
                  lowercaseCharCount: 1,
                  specialCharCount: 1,
                  onSuccess: () {},
                  controller: _passwordController,
                  defaultColor: Theme.of(context).colorScheme.background,
                ),
              ),
              Visibility(
                visible: _isVisibility,
                child: const SizedBox(
                  height: 16.0,
                ),
              ),
              InputFieldDefaultComponent(
                controller: _confirmPasswordController,
                text: 'Confirm password',
                obscure: _obscureConfirmPassword,
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.password),
                suffixIcon: _obscureConfirmPassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                isValidation: (value) => _confirmPasswordErrorText,
                onPressSuffixIcon: () => _handleIcon(
                  HandleIconField.visibilityConfirmPassword,
                ),
                onTap: () {
                  setState(() {
                    _isVisibility = false;
                  });
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              ButtonDefaultComponent(
                text: "Next",
                onTap: _onSubmit,
                colorBackground: AppColors.secondaryColor,
                colorText: AppColors.backgroundColor,
              ),
              const SizedBox(
                height: 16.0,
              ),
              SizedBox(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: AppColors.backgroundColor,
                      ))
                    : null,
              )
            ],
          ),
        ),
      ),
      DialogComponent(
        title: "Already have an account?",
        labelStatusStop: "Login",
        labelStatusContinue: "Continue creating account",
        onPressedStop: _navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: false,
      ),
    ]);
  }
}
