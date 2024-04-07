import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:social_media_app/models/users.dart';
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
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  Users? user;
  void navigationToLoginScreen() {
    Navigator.pushNamed(context, '/login');
  }

  void clearEmailText() {
    setState(() {
      emailController.text = '';
    });
  }

  void onSubmit() {
    bool isValidation = formKey.currentState!.validate();
    if (isValidation) {}
  }

  @override
  Widget build(BuildContext context) {
    return GeneralForm(listWidget: [
      const SizedBox(
        height: 45.0,
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
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Email Input
              InputFieldLogin(
                controller: emailController,
                text: 'Email',
                obscure: false,
                textInputType: TextInputType.emailAddress,
                suffixIcon: const Icon(Icons.close),
                isValidation: ValidationBuilder().required().email().build(),
              ),
              const SizedBox(
                height: 16.0,
              ),
              ButtonLogin(
                text: "Next",
                onTap: onSubmit,
              ),
            ],
          ),
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
