import 'package:flutter/material.dart';

class GeneralForm extends StatelessWidget {
  const GeneralForm({super.key, required this.listWidget});
  final List<Widget> listWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffD3E9F5), Color(0xff7BA7B4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listWidget,
          ),
        ),
      ),
    );
  }
}
