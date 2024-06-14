import 'package:test_app/consts/consts.dart';

class CustomButton extends StatelessWidget {
  final Function onTap;
  final String buttonText;
  const CustomButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.screenWidth,
      height: 44,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                  fontSize: AppSize.size18, fontWeight: FontWeight.bold)),
          onPressed: () => onTap(),
          child: buttonText.text.make()),
    );
  }
}
