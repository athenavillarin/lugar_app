import 'package:flutter/material.dart';
import '../../models/route_option.dart';

class FareTypeToggle extends StatelessWidget {
  final FareType selectedType;
  final Function(FareType) onChanged;
  final Color primaryBlue;

  const FareTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Regular',
            icon: Icons.directions_walk,
            isSelected: selectedType == FareType.regular,
            onTap: () => onChanged(FareType.regular),
            primaryBlue: primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _ToggleButton(
            label: 'Student/PWD/ Senior',
            icon: Icons.accessible,
            isSelected: selectedType == FareType.discounted,
            onTap: () => onChanged(FareType.discounted),
            primaryBlue: primaryBlue,
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryBlue;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F2937) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
