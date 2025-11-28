import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class NoRouteCard extends StatelessWidget {
  final VoidCallback? onTap;
  const NoRouteCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: UIConstants.borderRadiusLarge,
      child: Container(
        padding: UIConstants.paddingXLarge,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: UIConstants.borderRadiusLarge,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[500], size: 40),
            const SizedBox(height: 16),
            Text(
              'No routes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or check your locations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
