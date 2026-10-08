part of '../truck_form_screen.dart';

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totalPallets,
    required this.totalMistas,
    required this.totalExpositores,
  });

  final int totalPallets;
  final int totalMistas;
  final int totalExpositores;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TotalCell(label: 'Paletes', value: totalPallets),
            Container(width: 1, height: 40, color: Colors.white24),
            _TotalCell(label: 'Mistas', value: totalMistas),
            Container(width: 1, height: 40, color: Colors.white24),
            _TotalCell(label: 'Expositores', value: totalExpositores),
          ],
        ),
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
