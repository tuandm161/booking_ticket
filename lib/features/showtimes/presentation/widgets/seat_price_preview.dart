import 'package:flutter/material.dart';
import '../../../../core/constants/pricing_constants.dart';

class SeatPricePreview extends StatelessWidget {
  const SeatPricePreview({super.key, required this.basePrice});
  final int basePrice;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview giá ghế',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Standard: $basePrice₫'),
          Text('VIP: ${basePrice + PricingConstants.vipSurcharge}₫'),
          Text('Couple: ${basePrice * 2 + PricingConstants.coupleSurcharge}₫'),
        ],
      ),
    ),
  );
}
