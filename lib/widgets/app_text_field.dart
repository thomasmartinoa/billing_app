import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

/// Reusable styled text field used across add_customer and add_product screens
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData icon;
  final String hint;
  final String? label;
  final TextInputType inputType;
  final int maxLines;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.controller,
    required this.icon,
    required this.hint,
    this.label,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: TextStyle(color: context.textGray, fontSize: AppFontSize.md)),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
                color: context.borderColor
                    .withValues(alpha: OpacityConstants.tertiary)),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: context.textWhite),
            keyboardType: inputType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.textGray),
              prefixIcon: Icon(icon, color: context.textGray),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.xl),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide(color: context.accentColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
