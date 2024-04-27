import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/button/outline_button_login.component.dart';
import 'package:social_media_app/components/button/social_button_login.component.dart';
import 'package:social_media_app/components/field/field_default.component.dart';
import 'package:social_media_app/components/form/general_form.component.dart';
import 'package:social_media_app/components/text/forgot_password.component.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/authentication/authentication.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/handle_icon_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationServices _authServices = AuthenticationServices();
  final _formKey = GlobalKey<FormState>();
  String? _emailErrorText, _passwordErrorText;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoginSuccess = false;

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
      } else {
        _passwordErrorText = null;
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
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
          return;
      }
    });
  }

  void _navigationToRegisterScreen() {
    Navigator.pushNamed(context, "/register");
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final UserCredential userCredential =
        await _authServices.signInWithGoogle();
    final User? currentUser = userCredential.user;

    if (currentUser != null) {
      // ignore: avoid_print
      print('Login successed: ${currentUser.displayName}');
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeMain(),
      ));
    } else {
      // ignore: avoid_print
      print('Login failed !!!!!!');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
    });
    final resultEmail = _emailController.text.trim();
    final resultPassword = _passwordController.text.trim();
    _validateEmail(resultEmail);
    _validatePassword(resultPassword);
    bool isValidation = _formKey.currentState!.validate();
    if (isValidation) {
      try {
        await _authServices.signInWithEmailPassword(
            resultEmail, resultPassword);
        _isLoginSuccess = (FirebaseAuth.instance.currentUser != null &&
                await _authServices.isEmailVerified())
            ? true
            : false;
        if (!_isLoginSuccess) {
          _emailErrorText = '$resultEmail have not verified your email.';
        }
      } on FirebaseAuthException catch (error) {
        // ignore: avoid_print
        print("Error for sign in ---> $error");
        _passwordErrorText = error.message;
      }

      if (_isLoginSuccess) {
        Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const HomeMain(),
            ),
            ModalRoute.withName('/'));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFormComponent(
      listWidget: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80.0,
                  width: 80.0,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage("assets/images/logo_social_media.png"),
                          fit: BoxFit.cover)),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                SizedBox(
                  height: 40.0,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: AppColors.backgroundColor,
                        ))
                      : null,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                //Email Input
                InputFieldDefaultComponent(
                  controller: _emailController,
                  text: 'Email',
                  obscure: false,
                  textInputType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: const Icon(Icons.close),
                  isValidation: (value) => _emailErrorText,
                  onPressSuffixIcon: () => _handleIcon(HandleIconField.clear),
                ),
                const SizedBox(
                  height: 16.0,
                ),
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
                  onPressSuffixIcon: () =>
                      _handleIcon(HandleIconField.visibilityPassword),
                ),
                const SizedBox(
                  height: 16,
                ),
                ButtonDefaultComponent(
                  text: "Login",
                  onTap: _onSubmit,
                  colorBackground: AppColors.secondaryColor,
                  colorText: AppColors.backgroundColor,
                ),
                const SizedBox(
                  height: 16,
                ),
                const ForgotPasswordTextComponent(),
                const SizedBox(
                  height: 25.0,
                ),
                SocialLoginButtonImageComponent(
                  onTapFacebook: () {},
                  onTapGoogle: _signInWithGoogle,
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
        ),
        OutlineButtonLoginComponent(
            text: "Create new account", onTap: _navigationToRegisterScreen),
      ],
    );
  }
}
