import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../domain/dashboard_models.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.radius = 22});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.92),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: child,
      ),
    ),
  );
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Bonjour, David', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text("5 tâches vous attendent aujourd'hui", style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textSecondary)),
    ])),
    Container(
      width: 48, height: 48,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.gradientPrimary),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
        alignment: Alignment.center,
        child: Text('D', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.violet)),
      ),
    ),
  ]);
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const SectionHeader(this.title, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: GoogleFonts.sora(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      if (action != null) Row(children: [
        Text(action!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.violet)),
        const SizedBox(width: 2),
        const Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.violet),
      ]),
    ],
  );
}

class HeroCard extends StatelessWidget {
  final int todo, inProgress, completed;
  const HeroCard({super.key, required this.todo, required this.inProgress, required this.completed});
  @override
  Widget build(BuildContext context) {
    final total = todo + inProgress + completed;
    final rate = total == 0 ? 0.0 : completed / total;
    return GlassCard(child: Row(children: [
      SizedBox(width: 104, height: 104, child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: rate), duration: const Duration(milliseconds: 1100), curve: Curves.easeOutCubic,
        builder: (_, value, __) => Stack(alignment: Alignment.center, children: [
          CustomPaint(size: const Size(104,104), painter: RingPainter(progress: value)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(value * 100).round()}%', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('fait', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
      )),
      const SizedBox(width: 20),
      Expanded(child: Column(children: [
        MiniStat('À faire', todo, AppColors.textSecondary),
        const SizedBox(height: 12),
        MiniStat('En cours', inProgress, AppColors.amber),
        const SizedBox(height: 12),
        MiniStat('Terminées', completed, AppColors.mint),
      ])),
    ]));
  }
}

class MiniStat extends StatelessWidget {
  final String label; final int value; final Color color;
  const MiniStat(this.label, this.value, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
    Text('$value', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);
}

class RingPainter extends CustomPainter {
  final double progress;
  RingPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 10) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()..color = const Color(0xFFE7EBF2)..style = PaintingStyle.stroke..strokeWidth = 10;
    canvas.drawCircle(center, radius, track);
    final paint = Paint()..shader = AppColors.gradientPrimary.createShader(rect)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }
  @override bool shouldRepaint(covariant RingPainter old) => old.progress != progress;
}

class FocusCarousel extends StatefulWidget {
  final List<FocusTask> tasks;
  const FocusCarousel({super.key, required this.tasks});
  @override State<FocusCarousel> createState() => _FocusCarouselState();
}
class _FocusCarouselState extends State<FocusCarousel> {
  final controller = PageController(viewportFraction: .86);
  double page = 0;
  @override void initState() { super.initState(); controller.addListener(() => setState(() => page = controller.page ?? 0)); }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 168, child: PageView.builder(controller: controller, itemCount: widget.tasks.length, itemBuilder: (_, i) {
      final scale = (1 - ((page - i).abs() * .08)).clamp(.9, 1.0);
      return Transform.scale(scale: scale, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: FocusCard(task: widget.tasks[i])));
    })),
    const SizedBox(height: 12),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.tasks.length, (i) {
      final active = page.round() == i;
      return AnimatedContainer(duration: const Duration(milliseconds: 220), margin: const EdgeInsets.symmetric(horizontal: 3), width: active ? 20 : 6, height: 6,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: active ? AppColors.violet : AppColors.textFaint.withOpacity(.4)));
    })),
  ]);
}

class FocusCard extends StatelessWidget {
  final FocusTask task;
  const FocusCard({super.key, required this.task});
  @override Widget build(BuildContext context) => GlassCard(radius: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [PriorityPill(priority: task.priority), const Spacer(), Text(task.due, style: GoogleFonts.inter(fontSize: 12, fontWeight: task.urgent ? FontWeight.w700 : FontWeight.w500, color: task.urgent ? AppColors.coral : AppColors.textSecondary))]),
    const SizedBox(height: 14),
    Text(task.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.sora(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25)),
    const Spacer(),
    Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: task.projectColor, shape: BoxShape.circle)), const SizedBox(width: 8), Text(task.project, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary))]),
  ]));
}

class PriorityPill extends StatelessWidget {
  final Priority priority;
  const PriorityPill({super.key, required this.priority});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: priority.color.withOpacity(.10), borderRadius: BorderRadius.circular(20), border: Border.all(color: priority.color.withOpacity(.35))), child: Text(priority.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: priority.color)));
}

class ProjectsRow extends StatelessWidget {
  final List<ProjectItem> projects;
  const ProjectsRow({super.key, required this.projects});
  @override Widget build(BuildContext context) => SizedBox(height: 178, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: projects.length, separatorBuilder: (_,__) => const SizedBox(width: 14), itemBuilder: (_,i) => ProjectCard(project: projects[i])));
}

class ProjectCard extends StatelessWidget {
  final ProjectItem project;
  const ProjectCard({super.key, required this.project});
  @override Widget build(BuildContext context) => Container(width: 200, padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: LinearGradient(colors: project.gradient), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: project.gradient.first.withOpacity(.18), blurRadius: 18, offset: const Offset(0,8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 34,height:34, decoration: BoxDecoration(color: Colors.white.withOpacity(.22), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(project.name.substring(0,1), style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white))),
    const Spacer(), Text(project.name, maxLines: 2, style: GoogleFonts.sora(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)), const SizedBox(height: 12),
    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: project.progress, minHeight: 5, backgroundColor: Colors.white.withOpacity(.22), color: Colors.white)),
    const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${project.tasks} tâches', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white.withOpacity(.85))), Text('${(project.progress*100).round()}%', style: GoogleFonts.sora(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white))]),
  ]));
}

class TaskList extends StatelessWidget {
  final List<ImportantTask> tasks; final Set<int> checked; final ValueChanged<int> onToggle;
  const TaskList({super.key, required this.tasks, required this.checked, required this.onToggle});
  @override Widget build(BuildContext context) => Column(children: List.generate(tasks.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskTile(task: tasks[i], checked: checked.contains(i), onToggle: () { HapticFeedback.lightImpact(); onToggle(i); }))));
}

class TaskTile extends StatelessWidget {
  final ImportantTask task; final bool checked; final VoidCallback onToggle;
  const TaskTile({super.key, required this.task, required this.checked, required this.onToggle});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onToggle, child: AnimatedOpacity(opacity: checked ? .5 : 1, duration: const Duration(milliseconds: 220), child: GlassCard(radius: 18, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
    AnimatedContainer(duration: const Duration(milliseconds: 220), width: 24,height:24, decoration: BoxDecoration(shape: BoxShape.circle, gradient: checked ? AppColors.gradientPrimary : null, border: Border.all(color: checked ? Colors.transparent : AppColors.textFaint, width: 1.6)), child: checked ? const Icon(Icons.check,size:15,color:Colors.white) : null),
    const SizedBox(width:14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.name, style: GoogleFonts.inter(fontSize:14.5,fontWeight:FontWeight.w600,color:checked?AppColors.textFaint:AppColors.textPrimary,decoration:checked?TextDecoration.lineThrough:null)), const SizedBox(height:4), Row(children:[Container(width:5,height:5,decoration:BoxDecoration(color:task.projectColor,shape:BoxShape.circle)),const SizedBox(width:6),Text(task.project,style:GoogleFonts.inter(fontSize:12,color:AppColors.textSecondary))])])), const SizedBox(width:10), Column(crossAxisAlignment:CrossAxisAlignment.end,children:[PriorityPill(priority:task.priority),const SizedBox(height:6),Text(task.due,style:GoogleFonts.inter(fontSize:11.5,color:AppColors.textSecondary))]),
  ]))));
}

class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({super.key});
  @override State<FloatingNavBar> createState() => _FloatingNavBarState();
}
class _FloatingNavBarState extends State<FloatingNavBar> {
  int index = 0;
  static const items = [(icon: Icons.grid_view_rounded, label: 'Accueil'),(icon: Icons.checklist_rounded,label:'Tâches'),(icon:Icons.folder_copy_rounded,label:'Projets'),(icon:Icons.person_rounded,label:'Profil')];
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20,0,20,24), child: ClipRRect(borderRadius:BorderRadius.circular(28),child: BackdropFilter(filter:ImageFilter.blur(sigmaX:18,sigmaY:18),child:Container(height:68,decoration:BoxDecoration(color:Colors.white.withOpacity(.94),borderRadius:BorderRadius.circular(28),border:Border.all(color:AppColors.surfaceBorder),boxShadow:[BoxShadow(color:Colors.black.withOpacity(.08),blurRadius:20,offset:const Offset(0,6))]),child:Row(children:List.generate(items.length,(i){final active=i==index;final item=items[i];return Expanded(child:GestureDetector(behavior:HitTestBehavior.opaque,onTap:(){setState(()=>index=i);HapticFeedback.selectionClick();},child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(item.icon,size:22,color:active?AppColors.violet:AppColors.textFaint),const SizedBox(height:3),Text(item.label,style:GoogleFonts.inter(fontSize:10.5,fontWeight:FontWeight.w600,color:active?AppColors.violet:AppColors.textFaint))])));}))))));
}
