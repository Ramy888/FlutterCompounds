import 'package:flutter/material.dart';


class CustomStepper extends StatelessWidget {
  final List<int> steps = [1, 2];
  int currentStep = 1;

  CustomStepper({super.key, required this.currentStep});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: SizedBox(
          width: 200.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 180.0,
                child: Divider(
                  color: Colors.grey,
                  thickness: 2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var step in steps)
                    Icon(
                      Icons.circle,
                      color: step == 1 ? Colors.greenAccent[400] : Colors.black,
                      size: step == 1 ? 24.0 : 16.0,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
