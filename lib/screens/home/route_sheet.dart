import 'package:flutter/material.dart';

class RouteSheet extends StatelessWidget {
  const RouteSheet({
    super.key,
    required this.fromController,
    required this.toController,
    required this.isFormValid,
    required this.onSwap,
    required this.onFindRoute,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final bool isFormValid;
  final VoidCallback onSwap;
  final VoidCallback onFindRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(),
                    const SizedBox(height: 24),
                    _InputForm(
                      primaryBlue: primaryBlue,
                      fromController: fromController,
                      toController: toController,
                      onSwap: onSwap,
                    ),
                    const SizedBox(height: 20),
                    _FindRouteButton(
                      primaryBlue: primaryBlue,
                      isEnabled: isFormValid,
                      onPressed: onFindRoute,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          height: 1.3,
          color: Color(0xFF1F2024),
          fontFamily: 'Montserrat',
        ),
        children: [
          TextSpan(
            text: 'WHERE WOULD YOU\nLIKE TO GO ',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'TODAY?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputForm extends StatelessWidget {
  const _InputForm({
    required this.primaryBlue,
    required this.fromController,
    required this.toController,
    required this.onSwap,
  });

  final Color primaryBlue;
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryBlue, width: 2),
                  color: primaryBlue,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Column(
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryBlue, width: 2),
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _InputField(
                  label: 'From',
                  placeholder: 'Your Location',
                  controller: fromController,
                ),
                const SizedBox(height: 20),
                _InputField(
                  label: 'To',
                  placeholder: 'Your Destination',
                  controller: toController,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onSwap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryBlue, width: 1.5),
                color: Colors.white,
              ),
              child: Icon(Icons.swap_vert, color: primaryBlue, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.placeholder,
    required this.controller,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2024),
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _FindRouteButton extends StatelessWidget {
  const _FindRouteButton({
    required this.primaryBlue,
    required this.isEnabled,
    required this.onPressed,
  });

  final Color primaryBlue;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryBlue.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Find Route',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
