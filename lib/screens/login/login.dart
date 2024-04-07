import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/components/button/button_login.dart';
import 'package:social_media_app/screens/components/button/outline_button_login.dart';
import 'package:social_media_app/screens/components/button/social_button_login.dart';
import 'package:social_media_app/screens/components/field/field_login.dart';
import 'package:social_media_app/screens/components/form/general_form.dart';
import 'package:social_media_app/screens/components/text/forgot_password.dart';
import 'package:social_media_app/screens/home/home_main.dart';
import 'package:social_media_app/serviecs/Authentication/google_services.dart';
import 'package:social_media_app/utils/handle_icon_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  void handleIcon(HandleIconField handle) {
    setState(() {
      switch (handle) {
        case HandleIconField.clear:
          emailController.text = '';
          return;
        case HandleIconField.visibility:
          obscurePassword = !obscurePassword;
          return;
      }
    });
  }

  void navigationToRegisterScreen() {
    Navigator.pushNamed(context, "/register");
  }

  signInWithGoogle() async {
    AuthenticationSocialMediaApp authenticationSocialMediaApp =
        AuthenticationSocialMediaApp();
    final userCredential =
        await authenticationSocialMediaApp.signInWithGoogle();

    if (userCredential != null) {
      print('Đã đăng nhập với người dùng: ${userCredential.user.displayName}');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeMain(
          user: userCredential.user,
        ),
      ));
    } else {
      print('Đăng nhập không thành công.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralForm(
      listWidget: [
        Expanded(
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
                height: 16.0,
              ),
              //Email Input
              InputFieldLogin(
                controller: emailController,
                text: 'Email',
                obscure: false,
                textInputType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: const Icon(Icons.close),
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
                onPressSuffixIcon: () => handleIcon(HandleIconField.visibility),
              ),
              const SizedBox(
                height: 16,
              ),
              ButtonLogin(
                text: "Login",
                onTap: () => {},
              ),
              const SizedBox(
                height: 16,
              ),
              const ForgotPasswordText(),
              const SizedBox(
                height: 25.0,
              ),
              SocialLoginButtonImage(
                onTapGoogle: signInWithGoogle,
              ),
            ],
          ),
        ),
        OutlineButtonLogin(
            text: "Create new account", onTap: navigationToRegisterScreen),
      ],
    );
  }
}
