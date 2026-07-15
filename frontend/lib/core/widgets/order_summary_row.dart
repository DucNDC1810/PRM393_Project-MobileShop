import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/utils/format_utils.dart';

class OrderSummaryRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isDiscount;
  final bool isFree;

  const OrderSummaryRow(
    this.label,
    this.amount, {
    super.key,
    this.isDiscount = false,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
            ),
          ),
          isFree
              ? const Text(
                  'Miễn phí',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                )
              : Text(
                  '${isDiscount ? '-' : ''}${formatVnd(amount.abs())}đ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDiscount ? AppColors.success : AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
        ],
      ),
    );
  }
}
