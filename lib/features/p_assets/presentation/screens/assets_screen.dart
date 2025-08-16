import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state.dart';
import '../../../../models/models.dart';
import '../widgets/add_asset_dialog.dart';
import '../widgets/edit_asset_dialog.dart';
import '../widgets/asset_header.dart';
import '../widgets/asset_list_item.dart';
import '../widgets/assets_empty.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  String _formatMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_formatMonth(date).substring(0, 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder:
          (context, appState, _) => ValueListenableBuilder(
            valueListenable: Hive.box<Entry>('entries').listenable(),
            builder: (context, box, _) {
              final assets =
                  box.values.where((e) => e.type == 'asset').toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

              final totalAssets = assets.fold<double>(
                0,
                (sum, asset) => sum + asset.amount,
              );

              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: true,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: AssetHeader(
                          totalAssets: totalAssets,
                          assetsCount: assets.length,
                        ),
                        title: const Text('Assets'),
                        centerTitle: true,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                          assets.isEmpty
                              ? const AssetsEmpty()
                              : const SizedBox(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final e = assets[index];
                        final isFirstOfMonth =
                            index == 0 ||
                            e.date.month != assets[index - 1].date.month;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isFirstOfMonth) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF9C27B0,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF9C27B0,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        size: 20,
                                        color: Color(0xFF9C27B0),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatMonth(e.date),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF9C27B0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            AssetListItem(
                              asset: e,
                              formattedDate: _formatDate(e.date),
                              onTap: () => showEditAsset(context, e),
                            ),
                          ],
                        );
                      }, childCount: assets.length),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => showAddAsset(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Asset'),
                  backgroundColor: const Color(0xFF9C27B0),
                ),
              );
            },
          ),
    );
  }
}
