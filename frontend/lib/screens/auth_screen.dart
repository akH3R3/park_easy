import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ added
import 'package:park_easy/screens/dummy_owner_screen.dart';
import 'package:park_easy/screens/dummy_user_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

enum AuthMode { email, google }

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedUserType = ''; // 'owner' or 'user'
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.email;
  bool _isCreatingAccount = false;

  void showSnackBar(String message, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveUserTypeLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', _selectedUserType);
  }

  void _navigateAfterLogin() {
    Widget targetScreen = _selectedUserType == 'owner'
        ? DummyOwnerScreen()
        : DummyUserScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_selectedUserType.isEmpty) {
      showSnackBar("Please select account type (Owner/User).");
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      showSnackBar("Please fill in both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isCreatingAccount) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        showSnackBar("Account created!", color: Colors.green);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      await _saveUserTypeLocally(); // ✅ Save selected userType
      _navigateAfterLogin(); // ✅ Go to relevant screen
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Authentication failed.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAuthToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text('Email'),
          selected: _authMode == AuthMode.email,
          onSelected: (selected) {
            setState(() {
              _authMode = AuthMode.email;
            });
          },
        ),
        SizedBox(width: 10),
        ChoiceChip(
          label: Text('Google'),
          selected: _authMode == AuthMode.google,
          onSelected: (selected) {
            setState(() {
              _authMode = AuthMode.google;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Account Type'),
        SizedBox(height: 12),
        Row(
          children: [
            _buildSelectionBox(title: 'Owner', type: 'owner'),
            SizedBox(width: 12),
            _buildSelectionBox(title: 'User', type: 'user'),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelectionBox({required String title, required String type}) {
    final isSelected = _selectedUserType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedUserType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthToggle(),
              SizedBox(height: 16),
              _buildUserTypeSelector(),
              Text(
                _authMode == AuthMode.email
                    ? (_isCreatingAccount ? 'Create Account' : 'Sign in')
                    : 'Sign in with Google',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (_authMode == AuthMode.email)
                Row(
                  children: [
                    Text(
                      _isCreatingAccount ? 'Already have an account? ' : 'or ',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingAccount = !_isCreatingAccount;
                        });
                      },
                      child: Text(
                        _isCreatingAccount ? 'Sign in' : 'Create one',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              if (_authMode == AuthMode.email) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmail,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isCreatingAccount ? 'Create Account' : 'Sign In',
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
