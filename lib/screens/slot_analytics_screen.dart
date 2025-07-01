import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/slot_provider.dart';
import '../widgets/line_chart_widget.dart';

class SlotAnalyticsScreen extends StatelessWidget {
  SlotAnalyticsScreen({super.key});

  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final List<String> imagePaths = [
    'assets/images/dummylot.jpg',
    'assets/images/dummylot.jpg',
    'assets/images/dummylot.jpg',
  ];

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage.value + 1) % imagePaths.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _currentPage.value = next;
      }
    });
  }

  List<FlSpot> toFlSpots(Map<int, int> map) {
    return map.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    final slotData = Provider.of<SlotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Slot Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) => _currentPage.value = index,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(imagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, value, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imagePaths.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: value == index ? 12 : 8,
                    height: value == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: value == index ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Average Rating', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Booking Frequency', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            slotData.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${slotData.bookingFrequency}/mo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Slot Statistics',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.9),
                    scrollDirection: Axis.horizontal,
                    children: [
                      LineChartWidget(
                        data: toFlSpots(slotData.hourlyCount),
                        title: "Daily Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.weekdayCount),
                        title: "Weekly Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.dayOfMonthCount),
                        title: "Monthly Parking",
                      ),
                      LineChartWidget(
                        data: toFlSpots(slotData.monthCount),
                        title: "Yearly Parking",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            const Text(
              'User Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            ...slotData.userFeedbacks.map(
                  (feedback) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/images/profile_default.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          feedback,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
