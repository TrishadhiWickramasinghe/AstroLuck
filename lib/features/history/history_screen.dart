import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/local/local_storage.dart';
import '../../data/models/lottery_history_model.dart';
import '../../data/repositories/lottery_repository.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late LocalStorageService _storage;
  late LotteryRepository _repository;
  List<LotteryEntry>? _history;
  PatternAnalysis? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _storage = LocalStorageService();
    await _storage.initialize();
    _repository = LotteryRepository(_storage);
    
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _isLoading = true;
    });

    _history = _repository.getHistory();
    _analysis = _repository.analyzePatterns();

    setState(() {
      _isLoading = false;
    });
  }

  void _addEntry() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddEntryBottomSheet(),
    ).then((_) {
      _loadHistory();
    });
  }

  void _deleteEntry(String id) {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          strings.confirmDelete,
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _repository.deleteEntry(id);
              _loadHistory();
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.deletedSuccessfully),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.historyTitle),
        backgroundColor: AppColors.darkPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.deepCosmicGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pattern Analysis Section
                    if (_analysis != null) ...[
                      Text(
                        strings.patternAnalysis,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _analysis!.analysisMessage,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_analysis!.frequentDigits.isNotEmpty)
                              _buildAnalysisRow(
                                label: strings.frequentDigits,
                                numbers: _analysis!.frequentDigits,
                                color: AppColors.highEnergy,
                              ),
                            if (_analysis!.recommendThisWeek.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildAnalysisRow(
                                label: strings.recommendThisWeek,
                                numbers: _analysis!.recommendThisWeek,
                                color: AppColors.gold,
                              ),
                            ],
                            if (_analysis!.avoidThisWeek.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildAnalysisRow(
                                label: strings.avoidThisWeek,
                                numbers: _analysis!.avoidThisWeek,
                                color: AppColors.warning,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // History List Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${strings.historyTitle} (${_history?.length ?? 0})',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: AppColors.gold,
                          onPressed: _addEntry,
                          child: const Icon(
                            Icons.add,
                            color: AppColors.darkPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // History List
                    if (_history == null || _history!.isEmpty)
                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            strings.noHistory,
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = _history![_history!.length - 1 - index];
                          return _buildHistoryCard(entry);
                        },
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: _addEntry,
        child: const Icon(
          Icons.add,
          color: AppColors.darkPurple,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(LotteryEntry entry) {
    final strings = AppLocalizations.of(context);
    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.lotteryType,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (entry.didWin)
                Chip(
                  label: Text(strings.historyWon),
                  backgroundColor: AppColors.highEnergy,
                  labelStyle: const TextStyle(color: AppColors.darkPurple),
                )
              else
                Chip(
                  label: Text(strings.historyPlayed),
                  backgroundColor: AppColors.lowEnergy,
                  labelStyle: const TextStyle(color: AppColors.darkPurple),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${strings.historyNumbersLabel}${entry.numbers.join(", ")}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${strings.historyDrawLabel}${entry.drawDate.toString().split(' ')[0]}',
            style: const TextStyle(
              color: AppColors.lightGrey,
              fontSize: 11,
            ),
          ),
          if (entry.prizeAmount != null) ...[
            const SizedBox(height: 4),
            Text(
              '${strings.historyPrizeLabel}${entry.prizeAmount}',
              style: const TextStyle(
                color: AppColors.mediumEnergy,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _deleteEntry(entry.id),
                icon: const Icon(Icons.delete, size: 18),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow({
    required String label,
    required List<int> numbers,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.lightGrey,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Wrap(
            spacing: 6,
            children: numbers
                .take(4)
                .map((num) => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.3),
                        border: Border.all(color: color, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          num.toString(),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AddEntryBottomSheet extends StatefulWidget {
  const _AddEntryBottomSheet();

  @override
  State<_AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends State<_AddEntryBottomSheet> {
  final _numberController = TextEditingController();
  final _prizeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedType;
  bool _didWin = false;

  @override
  dispose() {
    _numberController.dispose();
    _prizeController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final strings = AppLocalizations.of(context);
    // Validation
    if (_selectedType == null || _numberController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.historyRequiredFields)),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cosmicGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.addEntry,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: strings.close,
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.gold,
              textColor: AppColors.darkPurple,
            ),
          ],
        ),
      ),
    );
  }
}
