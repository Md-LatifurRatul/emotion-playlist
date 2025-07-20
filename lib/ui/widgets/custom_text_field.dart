import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final List<Color> gradientColor;
  final TextEditingController textEditingController;
  const CustomTextField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.isPassword,
    required this.gradientColor,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        controller: textEditingController,

        style: TextStyle(color: Color(0xFF1D1C1D)),
        decoration: InputDecoration(
          prefixIcon: ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: gradientColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
            child: Icon(icon, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF1D1D1D).withValues(alpha: 0.5)),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
