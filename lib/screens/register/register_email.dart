import 'package:flutter/material.dart';
import 'package:social_media_app/screens/components/button/button_login.dart';
import 'package:social_media_app/screens/components/dialog/dialog_register.dart';
import 'package:social_media_app/screens/components/field/field_login.dart';
import 'package:social_media_app/screens/components/form/general_form.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterEmailScreen> {
  final TextEditingController emailController = TextEditingController();
  void navigationToLoginScreen() {
    Navigator.pushNamed(context, '/login');
  }

  void clearEmailText() {
    setState(() {
      emailController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralForm(listWidget: [
      const SizedBox(
        height: 30.0,
      ),
      DialogScreen(
        title: "Do you want to stop creating your account?",
        content: const Text(
            "If you stop now, you'll lose any progress you've made."),
        labelStatusStop: "Stop creating account",
        labelStatusContinue: "Continue creating account",
        onPressedStop: navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: true,
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Email Input
            InputFieldLogin(
              controller: emailController,
              text: 'Email',
              obscure: false,
              textInputType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: const Icon(Icons.close),
              onPressSuffixIcon: clearEmailText,
            ),
            const SizedBox(
              height: 16.0,
            ),
            const ButtonLogin(),
          ],
        ),
      ),
      DialogScreen(
        title: "Already have an account?",
        labelStatusStop: "Login",
        labelStatusContinue: "Continue creating account",
        onPressedStop: navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: false,
      ),
    ]);
  }
}
