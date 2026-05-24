import 'package:ecommerce/services/firestore_service.dart';
import 'package:ecommerce/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailAddress.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (!mounted) return;
    setState(() => isGoogleLoading = true);
    try {
      final result = await GoogleAuthService().signIn();
      if (result == null) {
        return;
      }
      final user = result.user;

      if (user != null) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoURL: user.photoURL ?? '',
        );
      }
      if (context.mounted) {
        Navigator.pop(
            context); // Pop back to login which will auto navigate via auth state
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Google Sign-In failed')));
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
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
      await result.user!.reload();

      await FirestoreService().createUserProfile(
        uid: result.user!.uid,
        name: nameController.text.trim(),
        email: emailAddress.text.trim(),
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email';
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: color.inversePrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Create Account',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Join us and start shopping.',
                    style: TextStyle(color: color.secondary, fontSize: 15)),
                const SizedBox(height: 40),

                // Name
                TextFormField(
                  controller: nameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your name'
                      : null,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: emailAddress,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your email'
                      : null,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: password,
                  obscureText: !isPasswordVisible,
                  validator: (value) => value != null && value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: color.secondary,
                      ),
                      onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => register(context),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 24),

                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: color.tertiary)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR',
                          style: TextStyle(
                              color: color.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: color.tertiary)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isGoogleLoading
                        ? null
                        : () => signInWithGoogle(context),
                    icon: isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const FaIcon(FontAwesomeIcons.google, size: 18),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color.inversePrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: color.tertiary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
