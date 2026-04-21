import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bill_cubit.dart';
import '../models/bill_model.dart';
import '../models/bill_scenario.dart';
import '../widgets/bill_card.dart';
import '../widgets/stacked_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BillCubit, BillState>(
          builder: (context, state) {
            final section = state.section;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section != null)
                    _BillsHeader(
                      title: section.title,
                      billCountLabel: section.billCountLabel,
                    ),
                  const SizedBox(height: 18),
                  _ScenarioSelector(
                    selected: state.selectedScenario,
                    onSelected: (scenario) =>
                        context.read<BillCubit>().load(scenario),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ...previousChildren,
                            ...[currentChild].whereType<Widget>(),
                          ],
                        );
                      },
                      child: switch (state.status) {
                        BillStatus.initial ||
                        BillStatus.loading => const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        ),
                        BillStatus.error => _ErrorState(
                          key: const ValueKey('error'),
                          message:
                              state.errorMessage ??
                              'Unable to load bills at the moment.',
                          onRetry: () => context.read<BillCubit>().load(),
                        ),
                        BillStatus.loaded when section != null =>
                          SizedBox.expand(
                            child: section.bills.length <= 2
                                ? _CompactBillsList(
                                    key: const ValueKey('compact-list'),
                                    bills: section.bills,
                                  )
                                : StackedCarousel(
                                    key: const ValueKey('carousel'),
                                    bills: section.bills,
                                  ),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BillsHeader extends StatelessWidget {
  const _BillsHeader({required this.title, required this.billCountLabel});

  final String title;
  final String billCountLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$title ($billCountLabel)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF6F6D6A),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'view all',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF3B3937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Color(0xFF3B3937),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenarioSelector extends StatelessWidget {
  const _ScenarioSelector({required this.selected, required this.onSelected});

  final BillScenario selected;
  final ValueChanged<BillScenario> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: BillScenario.values
              .map((scenario) {
                final isSelected = selected == scenario;
                return Expanded(
                  child: InkWell(
                    key: Key('scenario-${scenario.name}'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onSelected(scenario),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF111111)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenario.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3B3937),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            scenario.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isSelected
                                      ? Colors.white70
                                      : const Color(0xFF7B7874),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _CompactBillsList extends StatelessWidget {
  const _CompactBillsList({super.key, required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('compact-bills-list'),
      itemCount: bills.length,
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      itemBuilder: (context, index) =>
          BillCard(bill: bills[index], elevation: index == 0 ? 0 : 8),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: Color(0xFF6F6D6A),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF3B3937)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
