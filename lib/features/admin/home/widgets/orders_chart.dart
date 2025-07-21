// lib/features/admin/home/widgets/orders_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_dashboard_controller.dart';

class OrdersChart extends StatelessWidget {
  const OrdersChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Orders ($currentYear)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.dark,
                ),
              ),
              Obx(() {
                if (controller.isLoadingChart.value) {
                  return const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }
                return IconButton(
                  onPressed: controller.loadMonthlyOrders,
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingChart.value) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final chartData = _generateChartData(controller.monthlyOrderCounts);
            final maxY = _calculateMaxY(controller.monthlyOrderCounts);

            return SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 20 ? (maxY / 5).roundToDouble() : 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final index = value.toInt() - 1;
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY > 20 ? (maxY / 5).roundToDouble() : 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: TColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: TColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: TColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final totalOrdersThisYear = controller.monthlyOrderCounts
                .fold(0.0, (sum, count) => sum + count);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total this year: ${totalOrdersThisYear.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(List<double> monthlyData) {
    return List.generate(12, (index) {
      return FlSpot((index + 1).toDouble(), monthlyData[index]);
    });
  }

  double _calculateMaxY(List<double> monthlyData) {
    final maxValue = monthlyData.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 10;

    // Add 20% padding to the max value and round up to nearest 5
    final paddedMax = maxValue * 1.2;
    return ((paddedMax / 5).ceil() * 5).toDouble();
  }
}