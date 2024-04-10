import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/components/button/button_login.dart';
import 'package:social_media_app/screens/components/button/outline_button_login.dart';
import 'package:social_media_app/screens/components/button/social_button_login.dart';
import 'package:social_media_app/screens/components/field/field_login.dart';
import 'package:social_media_app/screens/components/form/general_form.dart';
import 'package:social_media_app/screens/components/text/forgot_password.dart';
import 'package:social_media_app/screens/home/home_main.dart';
import 'package:social_media_app/serviecs/Authentication/auth_services.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/handle_icon_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthenticationServices authServices = AuthenticationServices();
  final UserServices userServices = UserServices();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  String? emailErrorText, passwordErrorText;
  bool obscurePassword = true;
  bool isLoading = false;
  bool isLoginSuccess = false;

  void validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailErrorText = 'Email is required';
      } else if (!isValidEmail(value)) {
        emailErrorText = 'Enter a valid email address (example@gmail.com)';
      } else {
        emailErrorText = null;
      }
    });
  }

  void validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordErrorText = 'Password is required';
      } else {
        passwordErrorText = null;
      }
    });
  }

  bool isValidPassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void handleIcon(HandleIconField handle) {
    setState(() {
      switch (handle) {
        case HandleIconField.clear:
          emailController.text = '';
          return;
        case HandleIconField.visibilityPassword:
          obscurePassword = !obscurePassword;
          return;
        case HandleIconField.visibilityConfirmPassword:
          return;
      }
    });
  }

  void navigationToRegisterScreen() {
    Navigator.pushNamed(context, "/register");
  }

  signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    final UserCredential userCredential = await authServices.signInWithGoogle();
    final User? currentUser = userCredential.user;

    if (currentUser != null) {
      // ignore: avoid_print
      print('Login successed: ${userCredential.user!.displayName}');
      final QuerySnapshot querySnapshotEmailExist = await firestore
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();
      if (querySnapshotEmailExist.docs.isNotEmpty) {
        // xác định email tồn tại
        // ignore: avoid_print
        print("${currentUser.email} is already registered.");
      } else {
        try {
          await userServices.addUserEmail(currentUser.uid, currentUser.email!);
        } catch (error) {
          // ignore: avoid_print
          print("userServices.addUserEmail (Login): ---> $error");
        }
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeMain(),
      ));
    } else {
      // ignore: avoid_print
      print('Login failed !!!!!!');
    }
    setState(() {
      isLoading = false;
    });
  }

  void onSubmit() async {
    setState(() {
      isLoading = true;
    });
    final resultEmail = emailController.text.trim();
    final resultPassword = passwordController.text.trim();
    validateEmail(resultEmail);
    validatePassword(resultPassword);
    bool isValidation = formKey.currentState!.validate();
    if (isValidation) {
      try {
        await authServices.signInWithEmailPassword(resultEmail, resultPassword);
        isLoginSuccess = (FirebaseAuth.instance.currentUser != null &&
                await authServices.isEmailVerified())
            ? true
            : false;
        if (!isLoginSuccess) {
          emailErrorText = '$resultEmail have not verified your email.';
        }
      } on FirebaseAuthException catch (error) {
        // ignore: avoid_print
        print("Error for sign in ---> $error");
        passwordErrorText = error.message;
      }

      if (isLoginSuccess) {
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
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralForm(
      listWidget: [
        Expanded(
          child: Form(
            key: formKey,
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
                  child: isLoading
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
                InputFieldLogin(
                  controller: emailController,
                  text: 'Email',
                  obscure: false,
                  textInputType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: const Icon(Icons.close),
                  isValidation: (value) => emailErrorText,
                  onPressSuffixIcon: () => handleIcon(HandleIconField.clear),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                InputFieldLogin(
                  controller: passwordController,
                  text: 'Password',
                  obscure: obscurePassword,
                  textInputType: TextInputType.text,
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: obscurePassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  isValidation: (value) => passwordErrorText,
                  onPressSuffixIcon: () =>
                      handleIcon(HandleIconField.visibilityPassword),
                ),
                const SizedBox(
                  height: 16,
                ),
                ButtonLogin(
                  text: "Login",
                  onTap: onSubmit,
                ),
                const SizedBox(
                  height: 16,
                ),
                const ForgotPasswordText(),
                const SizedBox(
                  height: 25.0,
                ),
                SocialLoginButtonImage(
                  onTapFacebook: () {},
                  onTapGoogle: signInWithGoogle,
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
        ),
        OutlineButtonLogin(
            text: "Create new account", onTap: navigationToRegisterScreen),
      ],
    );
  }
}
