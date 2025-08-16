import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/stat_info.dart';
import 'features/members/domain/entities/member.dart';
import 'models/entry.dart';
import 'features/notes/domain/entities/note.dart';
import 'core/providers/app_state.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/members/presentation/screens/members_screen.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/sales/presentation/screens/sales_screen.dart';
import 'features/purchases/presentation/screens/purchases_screen.dart';
import 'features/p_assets/presentation/screens/assets_screen.dart';
import 'features/interest/presentation/screens/interest_screen.dart';
import 'features/ledger/presentation/screens/ledger_screen.dart';
import 'features/notes/presentation/screens/note_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(EntryAdapter());
  Hive.registerAdapter(NoteAdapter());

  // Open Boxes
  await Hive.openBox<Member>('members');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Entry>('entries');
  await Hive.openBox<Note>('notes');

  // Create and initialize AppState
  final appState = AppState();
  await appState.init();
  await appState.seedDemoData();

  runApp(BusinessTrackerApp(appState: appState));
}

class BusinessTrackerApp extends StatelessWidget {
  final AppState appState;
  const BusinessTrackerApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Business Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  static const _tabs = [
    ('Dashboard', Icons.dashboard),
    ('Members', Icons.group),
    ('Expenses', Icons.money_off),
    ('Sales', Icons.point_of_sale),
    ('Purchases', Icons.shopping_cart),
    ('Assets', Icons.account_balance),
    ('Interest', Icons.percent),
    ('Ledger', Icons.receipt_long),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardScreen(),
      MembersScreen(),
      ExpensesScreen(),
      SalesScreen(),
      PurchasesScreen(),
      AssetsScreen(),
      InterestScreen(),
      LedgerScreen(),
    ];

    return DefaultTabController(
      length: _tabs.length,
      child: Builder(
        builder:
            (context) => Scaffold(
              key: _scaffoldKey,
              drawer: Drawer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6FE7FF), Color(0xFFE3F0FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.indigo,
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Business Tracker',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.bar_chart,
                            color: Colors.indigo,
                          ),
                          title: const Text('Stats'),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final s = Provider.of<AppState>(
                                  ctx,
                                  listen: false,
                                );
                                final stats = [
                                  StatInfo(
                                    'Cash Balance',
                                    s.cashBalance,
                                    Icons.account_balance,
                                    Colors.green,
                                  ),
                                  StatInfo(
                                    'Total Equity',
                                    s.totalEquity,
                                    Icons.trending_up,
                                    Colors.blue,
                                  ),
                                  StatInfo(
                                    'Assets Value',
                                    s.totalAssets,
                                    Icons.pie_chart,
                                    Colors.orange,
                                  ),
                                  StatInfo(
                                    'Sales',
                                    s.totalSales,
                                    Icons.shopping_cart,
                                    Colors.purple,
                                  ),
                                  StatInfo(
                                    'Purchases',
                                    s.totalPurchases,
                                    Icons.shopping_bag,
                                    Colors.teal,
                                  ),
                                  StatInfo(
                                    'Expenses',
                                    s.totalExpenses,
                                    Icons.money_off,
                                    Colors.red,
                                  ),
                                  StatInfo(
                                    'Interest',
                                    s.totalInterest,
                                    Icons.percent,
                                    Colors.indigo,
                                  ),
                                ];
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFE3F0FF),
                                          Color(0xFFF8FBFF),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Stats',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...stats.map(
                                          (stat) => ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: stat.color,
                                              child: Icon(
                                                stat.icon,
                                                color: Colors.white,
                                              ),
                                            ),
                                            title: Text(stat.title),
                                            subtitle: Text(
                                              stat.value.toStringAsFixed(2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.indigo,
                          ),
                          title: const Text('Profile'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.note_alt,
                            color: Colors.indigo,
                          ),
                          title: const Text('Notes'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NoteScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.indigo,
                          ),
                          title: const Text('Settings'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: Colors.indigo,
                          ),
                          title: const Text('About'),
                          onTap: () {},
                        ),
                        // Helper class for stats (used in main.dart dialog)
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              appBar: AppBar(
                title: const Text('Business Tracker'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8CFF), Color(0xFF6FE7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                bottom: TabBar(
                  isScrollable: true,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8CFF), Color(0xFF6FE7FF)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs:
                      _tabs
                          .map((t) => Tab(icon: Icon(t.$2), text: t.$1))
                          .toList(),
                ),
              ),
              body: TabBarView(children: pages),
            ),
      ),
    );
  }
}
