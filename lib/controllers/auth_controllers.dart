import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/views/home_view/home.dart';
import 'package:test_app/views/login_view/login_view.dart';
import '../views/doctor/home_doctor.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  UserCredential? userCredential;
  String phoneNumber = "";

  var aboutController = TextEditingController();
  var servicesController = TextEditingController();
  var phoneController = TextEditingController();
  var timingController = TextEditingController();
  var categoryController = TextEditingController();
  var addressController = TextEditingController();
  String? errorMessage;
  isUserAlreadyLoggedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        var data = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .get();
        var isDoc = data.data()?.containsKey('docName') ?? false;
        if (isDoc) {
          Get.offAll(() => const HomeDoctor());
        } else {
          Get.offAll(() => Home(
                isDoctor: isDoc,
              ));
        }
      } else {
        Get.offAll(() => const LoginView());
      }
    });
  }

  loginUser() async {
    
    userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

  Future<String?> signupUser(String fullname, String email, String password,
      String phoneNumber) async {
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential != null) {
        await storeUserData(
          userCredential!.user!.uid,
          fullnameController.text,
          emailController.text,
          phoneController.text,
        );
        return "success";
      }
    } catch (error) {
      // Handle errors
      if (error is FirebaseAuthException) {
        errorMessage = error.message;
        if (error.code == 'email-already-in-use') {
          // Email already exists
          return "existing_email";
        } else {
          // Other errors
          return null;
        }
      }
    }
    return null;
  }

  Future<void> storeUserData(
      String uid, String fullname, String email, String phone) async {
    var store = FirebaseFirestore.instance.collection('user').doc(uid);

    await store.set({
      'userid': FirebaseAuth.instance.currentUser?.uid,
      'name': fullname,
      'email': email,
      'phone': phone
    });
  }

  Future<void> storePhoneNumber(String uid, String phoneNumber) async {
    var store = FirebaseFirestore.instance.collection('phoneNumbers').doc(uid);

    await store.set({
      'phone': phoneNumber,
    });
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    try {
      if (newPassword != confirmNewPassword) {
        return 'Passwords do not match';
      }

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: oldPassword);

        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);

        // Update the user's password
        await user.updatePassword(newPassword);

        return null; // Password changed successfully
      } else {
        return 'User not signed in';
      }
    } catch (error) {
      // Handle password change errors
      print('Error changing password: $error');
      return 'Failed to change password. Please try again.';
    }
  }

  sendOTP(String phoneNumber, Function(String) setVerificationId,
      BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+970$phoneNumber',
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve or instant verification
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          printMessage("Authentication Successful");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          printMessage("The provided phone number is not valid.");
        } else {
          printMessage("Verification failed. Error: ${e.message}");
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setVerificationId(verificationId);
        printMessage("OTP Sent to +970 $phoneNumber");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setVerificationId(verificationId);
      },
    );
  }

  authenticate(String email, String password, String name, String phoneNumber,
      String otp, String verificationId, BuildContext context) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Verify phone number
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await userCredential.user!.linkWithCredential(credential);

      // Create a new user in the database
      await _firestore.collection('user').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phoneNumber,
        'userid': userCredential.user!.uid,
      });

      // Navigate to the home page
      Get.offAll(() => const Home(
            isDoctor: false,
          ));
    } catch (e) {
      printMessage("Authentication failed. Error: ${e.toString()}");
    }
  }

  printMessage(String msg) {
    debugPrint(msg);
  }
}
