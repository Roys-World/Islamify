import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/responsive.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');

    if (savedName != null && savedName.isNotEmpty) {
      // onboarded
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // first launch
      setState(() => _isFirstLaunch = true);
    }
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFirstLaunch) {
      // loading screen
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7F2),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppLogo(context),
              SizedBox(height: Responsive.getPadding(context, 24, 32, 40)),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F7A4D)),
              ),
              SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),
              Text(
                'Loading Islamify...',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14, 16, 18),
                  color: const Color(0xFF1F7A4D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.getPadding(context, 16, 20, 24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.getPadding(context, 30, 40, 50)),

              // Logo Section
              Column(
                children: [
                  _buildAppLogo(context),
                  SizedBox(height: Responsive.getPadding(context, 16, 20, 24)),

                  // App Name
                  Text(
                    'Islamify',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 32, 40, 48),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F7A4D),
                    ),
                  ),
                ],
              ),

              // Input Section
              Column(
                children: [
                  // Greeting Message
                  Text(
                    'Assalamu Alaikum',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 18, 22, 26),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F7A4D),
                    ),
                  ),

                  SizedBox(height: Responsive.getPadding(context, 6, 8, 10)),

                  Text(
                    'Welcome to your Islamic companion',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 12, 14, 16),
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: Responsive.getPadding(context, 20, 24, 28)),

                  // Name Input Field
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getPadding(context, 16, 18, 20),
                        vertical: Responsive.getPadding(context, 12, 14, 16),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF1F7A4D),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Responsive.getPadding(context, 30, 40, 50)),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: Responsive.isMobile(context) ? 52 : 60,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A4D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 15, 16, 18),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo(BuildContext context) {
    return Container(
      height: Responsive.isMobile(context)
          ? 120
          : (Responsive.isTablet(context) ? 150 : 180),
      width: Responsive.isMobile(context)
          ? 120
          : (Responsive.isTablet(context) ? 150 : 180),
      decoration: BoxDecoration(
        color: const Color(0xFF1F7A4D),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A4D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.mosque,
        color: Colors.white,
        size: Responsive.getFontSize(context, 50, 65, 85),
      ),
    );
  }
}
