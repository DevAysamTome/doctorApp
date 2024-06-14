import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/consts/images.dart';
import 'package:test_app/controllers/auth_controllers.dart';

class PhoneOTPVerification extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;

  PhoneOTPVerification(
      {required this.fullname, required this.email, required this.password});

  @override
  _PhoneOTPVerificationState createState() => _PhoneOTPVerificationState();
}

class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  bool visible = false;
  String verificationId = "";
  String countryCode = "+970";
  @override
  void dispose() {
    phoneNumber.dispose();
    otp.dispose();
    super.dispose();
  }

  void setVerificationId(String id) {
    setState(() {
      verificationId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  !visible
                      ? AppAssets.otpscreen1
                      : AppAssets
                          .otpscreen2, // Add your verification image here
                  height: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Phone Verification",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  !visible
                      ? "We need to register your phone number before getting started!"
                      : "Enter the verification code we just sent to your number  ${phoneNumber.text}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (!visible)
                  Row(
                    children: [
                      CountryCodePicker(
                        onChanged: (code) {
                          countryCode = code.dialCode!;
                        },
                        initialSelection: 'PS',
                        favorite: ['+972', 'PS'],
                      ),
                      Expanded(
                        child: inputTextField(
                          "Contact Number",
                          phoneNumber,
                          context,
                        ),
                      ),
                    ],
                  )
                else
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    controller: otp,
                    onCompleted: (v) {
                      print("Completed");
                    },
                    onChanged: (value) {
                      print(value);
                      setState(() {});
                    },
                  ),
                SizedBox(height: 20),
                if (!visible)
                  SendOTPButton("Send the Code")
                else
                  SubmitOTPButton("Verify Phone Number"),
                if (visible)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        visible = false;
                      });
                    },
                    child: Text("Edit phone number?"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SendOTPButton(String text) => ElevatedButton(
        onPressed: () async {
          setState(() {
            visible = !visible;
          });
          await AuthController()
              .sendOTP(phoneNumber.text, setVerificationId, context);
        },
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: TextStyle(fontSize: 21, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            fixedSize: Size(200, 70)),
        child: Text(text),
      );

  Widget SubmitOTPButton(String text) => ElevatedButton(
        onPressed: () async {
          await AuthController().authenticate(
            widget.email,
            widget.password,
            widget.fullname,
            phoneNumber.text,
            otp.text,
            verificationId, // Pass the verificationId here
            context,
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(text),
      );

  Widget inputTextField(String labelText,
          TextEditingController textEditingController, BuildContext context) =>
      TextField(
        obscureText: labelText == "OTP",
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
