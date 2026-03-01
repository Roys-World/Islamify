import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasbeeh_provider.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasbeeh counters when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasbeehProvider>().loadCounts();
    });
  }

  void _incrementCounter() async {
    await context.read<TasbeehProvider>().incrementCounter();
  }

  void _resetCounter() async {
    await context.read<TasbeehProvider>().resetSelectedCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final isDarkMode = settingsProvider.darkMode;

        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          body: Consumer<TasbeehProvider>(
            builder: (context, tasbeehProvider, _) {
              if (tasbeehProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasbeeh Counter',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextPrimaryColor(
                                    isDarkMode,
                                  ),
                                ),
                              ),
                              Text(
                                'Total: ${tasbeehProvider.getTotalCount()} اذكار',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextSecondaryColor(
                                    isDarkMode,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _resetCounter,
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Counter Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.getCardColor(isDarkMode),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              tasbeehProvider.selectedDhikr.arabic,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.getTextPrimaryColor(
                                  isDarkMode,
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tasbeehProvider.selectedDhikr.translation,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: AppColors.getTextSecondaryColor(
                                  isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double size = constraints.maxWidth * 0.75;
                                return Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _incrementCounter,
                                      borderRadius: BorderRadius.circular(
                                        size / 2,
                                      ),
                                      splashColor: Colors.green.withOpacity(
                                        0.3,
                                      ),
                                      highlightColor: Colors.green.withOpacity(
                                        0.1,
                                      ),
                                      child: SizedBox(
                                        width: size,
                                        height: size,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value:
                                                  (tasbeehProvider
                                                          .selectedDhikr
                                                          .count %
                                                      33) /
                                                  33,
                                              strokeWidth:
                                                  constraints.maxWidth * 0.65,
                                              backgroundColor:
                                                  Colors.green.shade100,
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                    Colors.green,
                                                  ),
                                            ),
                                            Text(
                                              tasbeehProvider
                                                  .selectedDhikr
                                                  .count
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 94,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to count',
                              style: TextStyle(
                                color: AppColors.getTextSecondaryColor(
                                  isDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Dhikr List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select a Dhikr',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimaryColor(isDarkMode),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasbeehProvider.dhikrList.length,
                        itemBuilder: (context, index) {
                          final dhikr = tasbeehProvider.dhikrList[index];
                          final isSelected =
                              index == tasbeehProvider.selectedIndex;
                          return GestureDetector(
                            onTap: () {
                              tasbeehProvider.selectDhikr(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : AppColors.getCardColor(isDarkMode),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : AppColors.getBorderColor(isDarkMode),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dhikr.arabic,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.getTextPrimaryColor(
                                                    isDarkMode,
                                                  ),
                                          ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          dhikr.count.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dhikr.translation,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : AppColors.getTextSecondaryColor(
                                              isDarkMode,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
