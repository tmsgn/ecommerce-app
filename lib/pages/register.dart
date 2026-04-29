import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailAddress.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() => isGoogleLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isGoogleLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoURL: user.photoURL ?? '',
        );
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Google Sign-In failed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-In error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  Future<void> register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => isLoading = true);
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress.text.trim(),
        password: password.text.trim(),
      );
      await result.user!.updateDisplayName(nameController.text.trim());
      // Save user profile to Firestore
      await FirestoreService().createUserProfile(
        uid: result.user!.uid,
        name: nameController.text.trim(),
        email: emailAddress.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'weak-password') message = 'The password is too weak';
      else if (e.code == 'email-already-in-use') message = 'Email already in use';
      else if (e.code == 'invalid-email') message = 'Invalid email';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [color.primary, color.secondary],
                          ),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create Your Store Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Buy & Sell products easily',
                        style: TextStyle(
                          fontSize: 14,
                          color: color.inversePrimary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name is required";
                          }
                          if (value.trim().length < 2) {
                            return "Enter a valid name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailAddress,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: password,
                        obscureText: !isPasswordVisible,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 characters";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPassword,
                        obscureText: !isConfirmPasswordVisible,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm your password";
                          }
                          if (value != password.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: (isLoading || isGoogleLoading)
                            ? null
                            : () => register(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.inversePrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: TextStyle(
                                      color: color.secondary,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: (isLoading || isGoogleLoading)
                            ? null
                            : () => signInWithGoogle(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isGoogleLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.google),
                                      SizedBox(width: 20),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(color: color.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading || isGoogleLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }
}
