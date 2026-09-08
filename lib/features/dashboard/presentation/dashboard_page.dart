import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../data/dashboard_mock_data.dart';
import 'dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late final AnimationController entrance;
  final Set<int> checked = {};

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { entrance.dispose(); super.dispose(); }

  Widget reveal(int index, Widget child) {
    final start = (index / 6).clamp(0.0, 1.0);
    final end = ((index + 2) / 6).clamp(0.0, 1.0);
    final animation = CurvedAnimation(parent: entrance, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(animation: animation, builder: (_,__) => Opacity(opacity: animation.value, child: Transform.translate(offset: Offset(0, (1-animation.value)*14), child: child)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Stack(children: [
      SafeArea(bottom:false, child: ListView(padding:const EdgeInsets.fromLTRB(20,12,20,120),children:[
        reveal(0,const DashboardHeader()), const SizedBox(height:24),
        reveal(1,const HeroCard(todo:DashboardMockData.todo,inProgress:DashboardMockData.inProgress,completed:DashboardMockData.completed)), const SizedBox(height:28),
        reveal(2,const SectionHeader('À l\'ordre du jour')), const SizedBox(height:14),
        reveal(2,const FocusCarousel(tasks:DashboardMockData.focusTasks)), const SizedBox(height:28),
        reveal(3,const SectionHeader('Projets récents',action:'Tout voir')), const SizedBox(height:14),
        reveal(3,const ProjectsRow(projects:DashboardMockData.projects)), const SizedBox(height:28),
        reveal(4,const SectionHeader('Tâches importantes',action:'Tout voir')), const SizedBox(height:14),
        reveal(4,TaskList(tasks:DashboardMockData.importantTasks,checked:checked,onToggle:(i)=>setState(()=>checked.contains(i)?checked.remove(i):checked.add(i)))),
      ])),
      const Align(alignment:Alignment.bottomCenter,child:FloatingNavBar()),
    ]),
  );
}
