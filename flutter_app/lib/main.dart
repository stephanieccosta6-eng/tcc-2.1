import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_strings.dart';
import 'services/api_service.dart';
import 'screens/auth_screen.dart';
import 'screens/tutorials_screen.dart';

void main() {
  runApp(const GlowUpApp());
}

class GlowUpApp extends StatefulWidget {
  const GlowUpApp({super.key});

  @override
  State<GlowUpApp> createState() => _GlowUpAppState();
}

class _GlowUpAppState extends State<GlowUpApp> {
  bool _isPortuguese = true;
  Map<String, dynamic>? _currentUser;

  void _toggleLanguage() {
    setState(() => _isPortuguese = !_isPortuguese);
  }

  void _handleAuthenticated(Map<String, dynamic> user) {
    setState(() => _currentUser = user);
  }

  void _handleLogout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowUp — Grupo Carefull',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _currentUser == null
          ? AuthScreen(
              isPortuguese: _isPortuguese,
              onToggleLanguage: _toggleLanguage,
              onAuthenticated: _handleAuthenticated,
            )
          : HomeNavigation(
              user: _currentUser!,
              isPortuguese: _isPortuguese,
              onToggleLanguage: _toggleLanguage,
              onLogout: _handleLogout,
            ),
    );
  }
}

class HomeNavigation extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isPortuguese;
  final VoidCallback onToggleLanguage;
  final VoidCallback onLogout;

  const HomeNavigation({
    super.key,
    required this.user,
    required this.isPortuguese,
    required this.onToggleLanguage,
    required this.onLogout,
  });

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  String? _skinType;
  String? _skinGoal;
  double _fridgeTemp = 6.0;

  final List<Map<String, dynamic>> _routine = [
    {'step': 'Limpeza Suave', 'time': 'Manhã & Noite', 'desc': 'Gel de Limpeza com Niacinamida 5%', 'done': false},
    {'step': 'Tratamento Antioxidante', 'time': 'Manhã • 5°C', 'desc': 'Sérum Vitamina C 10% (GlowFridge)', 'done': false},
    {'step': 'Fotoproteção Diária', 'time': 'Manhã', 'desc': 'Protetor Solar Fluido FPS 60 Toque Seco', 'done': false},
  ];

  final List<Map<String, String>> _fridgeItems = [
    {'name': 'Sérum Vitamina C 10%', 'ideal': '5°C', 'val': 'Validade: 45 dias'},
    {'name': 'Roll-on Olhos Cafeína', 'ideal': '4°C', 'val': 'Validade: 60 dias'},
    {'name': 'Bruma Facial Calmante', 'ideal': '6°C', 'val': 'Validade: 90 dias'},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Sérum Vitamina C 10% Pura', 'tag': 'Conservação 5°C', 'desc': 'Iluminação e ação antioxidante', 'price': 89.90, 'icon': Icons.water_drop_rounded},
    {'name': 'Gel Hidratante Ácido Hialurônico', 'tag': 'Todos os tipos', 'desc': 'Hidratação leve de rápida absorção', 'price': 74.50, 'icon': Icons.spa_rounded},
    {'name': 'Espuma de Limpeza Micelar', 'tag': 'pH Fisiológico', 'desc': 'Remove impurezas sem ressecar', 'price': 49.90, 'icon': Icons.bubble_chart_rounded},
    {'name': 'Protetor Solar Invisível FPS 60', 'tag': 'Toque Seco', 'desc': 'Alta proteção UVA/UVB sem resíduo', 'price': 65.00, 'icon': Icons.wb_sunny_rounded},
  ];

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Plano Essencial',
      'badge': 'ACESSO COMPLETO',
      'price': 'R\$ 29,90/mês',
      'desc': 'Rotina personalizada, dicas diárias e acesso ilimitado à Área de Aulas.',
      'isPrimary': false,
    },
    {
      'title': 'Plano Smart IoT',
      'badge': 'MAIS ESCOLHIDO',
      'price': 'R\$ 49,90/mês',
      'desc': 'Integração completa com GlowFridge IoT, alertas térmicos e curadoria VIP.',
      'isPrimary': true,
    },
  ];

  final List<Map<String, dynamic>> _cart = [];

  @override
  void initState() {
    super.initState();
    _skinType = widget.user['skinType'];
    _skinGoal = widget.user['skinGoal'];
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    final data = await ApiService.fetchFridgeStatus();
    if (data != null && mounted) {
      setState(() {
        _fridgeTemp = (data['temperature'] as num).toDouble();
      });
    }
  }

  void _openOptionalQuizModal() {
    final pt = widget.isPortuguese;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            Text(AppStrings.t(pt, 'quiz_modal_title'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(AppStrings.t(pt, 'quiz_modal_sub'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            _quizOption('Pele Oleosa', 'Controle de Sebo & Poros', 'Brilho intenso na zona T e poros visíveis', Icons.opacity_rounded),
            _quizOption('Pele Mista', 'Equilíbrio & Luminosidade', 'Oleosa na zona T e equilibrada nas bochechas', Icons.auto_awesome_rounded),
            _quizOption('Pele Seca / Sensível', 'Barreira Cutânea & Hidratação', 'Sensação de repuxamento ou vermelhidão', Icons.local_florist_rounded),
          ],
        ),
      ),
    );
  }

  Widget _quizOption(String type, String goal, String label, IconData icon) {
    final selected = _skinType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _skinType = type;
          _skinGoal = goal;
        });
        ApiService.saveSkinQuiz(
          email: widget.user['email'] ?? '',
          name: widget.user['name'] ?? '',
          skinType: type,
          skinGoal: goal,
        );
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderSubtle, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanReceipt(Map<String, dynamic> plan) {
    final pt = widget.isPortuguese;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(AppStrings.t(pt, 'receipt_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assinante: ${widget.user['name']}', style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Plano: ${plan['title']}', style: const TextStyle(fontSize: 15.5)),
            const SizedBox(height: 6),
            Text('Valor: ${plan['price']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 10),
            const Text('Status: Confirmado (Escopo Acadêmico)', style: TextStyle(fontSize: 13.5, color: AppColors.success, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openCartSheet() {
    final pt = widget.isPortuguese;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          double total = _cart.fold(0, (sum, item) => sum + (item['price'] as double));
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(AppStrings.t(pt, 'bag_title'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                if (_cart.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(AppStrings.t(pt, 'bag_empty'), style: Theme.of(context).textTheme.bodyMedium),
                  )
                else ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 230),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _cart.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderSubtle),
                      itemBuilder: (_, i) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_cart[i]['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          'R\$ ${_cart[i]['price'].toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
                          onPressed: () {
                            setState(() => _cart.removeAt(i));
                            setModalState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.t(pt, 'order_total'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5)),
                        Text(
                          'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () async {
                        final itemsCopy = List<Map<String, dynamic>>.from(_cart);
                        setState(() => _cart.clear());
                        Navigator.pop(context);
                        await ApiService.createOrder(
                          widget.user['name'] ?? '',
                          widget.user['email'] ?? '',
                          itemsCopy,
                          total,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppStrings.t(pt, 'order_saved'))),
                          );
                        }
                      },
                      child: Text(AppStrings.t(pt, 'checkout')),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.isPortuguese;
    final pages = [
      _buildHomeTab(),
      _buildFridgeTab(),
      TutorialsScreen(isPortuguese: pt),
      _buildShopAndPlansTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Center(child: Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19))),
            ),
            const SizedBox(width: 10),
            const Text('GlowUp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21, color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: widget.onToggleLanguage,
            child: Text(pt ? 'PT/EN' : 'EN/PT', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 25),
                onPressed: _openCartSheet,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text('${_cart.length}', style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: pt ? 'Sair' : 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 23),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa_rounded, color: AppColors.primary),
            label: AppStrings.t(pt, 'tab_routine'),
          ),
          const NavigationDestination(
            icon: Icon(Icons.ac_unit_outlined),
            selectedIcon: Icon(Icons.ac_unit_rounded, color: AppColors.primary),
            label: 'GlowFridge',
          ),
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline),
            selectedIcon: const Icon(Icons.play_circle_rounded, color: AppColors.primary),
            label: AppStrings.t(pt, 'tab_lessons'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary),
            label: AppStrings.t(pt, 'tab_plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final pt = widget.isPortuguese;
    final userName = widget.user['name'] ?? '';
    int doneCount = _routine.where((r) => r['done'] == true).length;
    double progress = doneCount / _routine.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Card de Saudação + Foto/Avatar + Questionário Opcional
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${AppStrings.t(pt, 'hello')}, $userName',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _skinType != null ? '$_skinType • ${_skinGoal ?? ''}' : AppStrings.t(pt, 'hero_no_skin'),
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 15.5, height: 1.45),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openOptionalQuizModal,
                icon: const Icon(Icons.tune_rounded, size: 19),
                label: Text(
                  AppStrings.t(pt, _skinType != null ? 'update_quiz_btn' : 'take_quiz_btn'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.t(pt, 'routine_tips'), style: Theme.of(context).textTheme.titleLarge),
            Text('$doneCount/${_routine.length}', style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.primarySoft,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(_routine.length, (i) {
          final item = _routine[i];
          final bool done = item['done'];
          return GestureDetector(
            onTap: () => setState(() => item['done'] = !done),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: done ? AppColors.surfaceTint : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: done ? AppColors.primary : AppColors.borderSubtle, width: 1.3),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: done ? AppColors.primary : Colors.grey.shade400, width: 2),
                    ),
                    child: done ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['step'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: done ? AppColors.textSecondary : AppColors.textPrimary,
                                decoration: done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(item['time'], style: const TextStyle(fontSize: 13.5, color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(item['desc'], style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        // Card de Dica com contraste alto (âmbar escuro sobre creme, sem conflito com rosa)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.amberCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.amberCardBorder, width: 1.3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.amberCardText, size: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(pt, 'smart_tip_title'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.amberCardText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(pt, 'smart_tip_body'),
                      style: const TextStyle(fontSize: 15, color: AppColors.amberCardText, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFridgeTab() {
    final pt = widget.isPortuguese;
    bool isIdeal = _fridgeTemp >= 4.0 && _fridgeTemp <= 8.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('GlowFridge IoT', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(AppStrings.t(pt, 'fridge_sub'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.fridgeDark, AppColors.fridgeDeep]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Text(AppStrings.t(pt, 'internal_temp'), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Text('${_fridgeTemp.toStringAsFixed(1)} °C', style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                AppStrings.t(pt, isIdeal ? 'temp_ideal' : 'temp_alert'),
                style: TextStyle(color: isIdeal ? const Color(0xFF6EE7B7) : const Color(0xFFFCD34D), fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _fridgeTemp,
                min: 2.0,
                max: 14.0,
                divisions: 24,
                activeColor: AppColors.iceAccent,
                onChanged: (v) {
                  setState(() => _fridgeTemp = v);
                  ApiService.updateFridgeTemperature(v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.t(pt, 'stored_items'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._fridgeItems.map((it) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ac_unit_rounded, color: Color(0xFF0284C7), size: 25),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        Text(it['val']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Ideal ${it['ideal']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildShopAndPlansTab() {
    final pt = widget.isPortuguese;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Escolha de Planos: harmônico com Rose e Lavanda (evita excesso de preto e branco)
        Text(AppStrings.t(pt, 'choose_plan'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(AppStrings.t(pt, 'choose_plan_sub'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        ..._plans.map((plan) {
          final bool isPrimary = plan['isPrimary'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.surfaceTint : AppColors.planSecondaryBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPrimary ? AppColors.primary : AppColors.planSecondaryBorder,
                width: isPrimary ? 2 : 1.4,
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPrimary ? AppColors.primarySoft : const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan['badge'],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isPrimary ? AppColors.primaryDark : AppColors.planSecondaryAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['title'],
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? AppColors.primaryDark : AppColors.planSecondaryAccent,
                      ),
                    ),
                    Text(
                      plan['price'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? AppColors.primary : AppColors.planSecondaryAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(plan['desc'], style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isPrimary ? AppColors.primary : AppColors.planSecondaryAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showPlanReceipt(plan),
                    child: Text(AppStrings.t(pt, 'select_plan'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
        Text(AppStrings.t(pt, 'store_title'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(AppStrings.t(pt, 'store_sub'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        ..._products.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(18)),
                    child: Icon(p['icon'] as IconData, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(p['desc'], style: const TextStyle(fontSize: 14.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${p['price'].toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary),
                            ),
                            FilledButton(
                              onPressed: () {
                                setState(() => _cart.add(p));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${p['name']} adicionado ao carrinho!'), duration: const Duration(seconds: 1)),
                                );
                              },
                              child: Text(AppStrings.t(pt, 'add_to_bag'), style: const TextStyle(fontSize: 14.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 16),
        // Seção de Aspectos Legais e Escopo Comercial (LGPD e Parcerias)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.t(pt, 'governance_title'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.t(pt, 'governance_body'),
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
