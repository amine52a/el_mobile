import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/course_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/course.dart';
import 'course_detail_screen.dart';
import 'course_form_screen.dart';

/// Screen displaying list of courses with modern, innovative UI
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  late AnimationController _fabController;
  late AnimationController _headerController;
  final ScrollController _scrollController = ScrollController();
  bool _showHeaderShadow = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_showHeaderShadow) {
        setState(() => _showHeaderShadow = true);
      } else if (_scrollController.offset <= 20 && _showHeaderShadow) {
        setState(() => _showHeaderShadow = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Consumer<CourseProvider>(
          builder: (context, provider, _) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Filtres Avancés',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Level Filter
                _buildFilterSection(
                  'Niveau',
                  Icons.signal_cellular_alt,
                  [
                    _buildModernChip('Tous', provider.selectedLevel == null,
                            () => provider.setLevelFilter(null), const Color(0xFF4CAF50)),
                    ...AppConstants.courseLevels.map((level) => _buildModernChip(
                        level, provider.selectedLevel == level,
                            () => provider.setLevelFilter(level), const Color(0xFF4CAF50))),
                  ],
                ),
                const SizedBox(height: 24),

                // Subject Filter
                _buildFilterSection(
                  'Matière',
                  Icons.category,
                  [
                    _buildModernChip('Tous', provider.selectedSubject == null,
                            () => provider.setSubjectFilter(null), const Color(0xFF667EEA)),
                    ...AppConstants.courseSubjects.map((subject) => _buildModernChip(
                        subject, provider.selectedSubject == subject,
                            () => provider.setSubjectFilter(subject), const Color(0xFF667EEA))),
                  ],
                ),
                const SizedBox(height: 24),

                // Language Filter
                _buildFilterSection(
                  'Langue',
                  Icons.language,
                  [
                    _buildModernChip('Tous', provider.selectedLanguage == null,
                            () => provider.setLanguageFilter(null), const Color(0xFFE57373)),
                    ...AppConstants.courseLanguages.map((lang) => _buildModernChip(
                        lang, provider.selectedLanguage == lang,
                            () => provider.setLanguageFilter(lang), const Color(0xFFE57373))),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réinitialiser'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Appliquer', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildModernChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50),
              const Color(0xFF45A049),
              const Color(0xFFE57373).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      _buildActiveFilters(),
                      _buildCoursesContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CourseFormScreen()),
            );
            if (result == true && context.mounted) {
              Provider.of<CourseProvider>(context, listen: false).loadCourses();
            }
          },
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 8,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nouveau Cours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      )),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow: _showHeaderShadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Consumer<CourseProvider>(
            builder: (context, provider, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                      tooltip: 'Changer la vue',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => provider.loadCourses(),
                      tooltip: 'Actualiser',
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () => _showFilterBottomSheet(context),
                          tooltip: 'Filtres',
                        ),
                        if (provider.hasActiveFilters)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE57373),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Explorez',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vos Cours',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.courses.length} cours disponibles',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            Provider.of<CourseProvider>(context, listen: false)
                .setSearchQuery(value.isEmpty ? null : value);
          },
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Rechercher un cours, un instructeur...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
              onPressed: () {
                _searchController.clear();
                Provider.of<CourseProvider>(context, listen: false)
                    .setSearchQuery(null);
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        if (!provider.hasActiveFilters) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (provider.selectedLevel != null)
                _buildActiveFilterChip(
                  provider.selectedLevel!,
                      () => provider.setLevelFilter(null),
                  const Color(0xFF4CAF50),
                ),
              if (provider.selectedSubject != null)
                _buildActiveFilterChip(
                  provider.selectedSubject!,
                      () => provider.setSubjectFilter(null),
                  const Color(0xFF667EEA),
                ),
              if (provider.selectedLanguage != null)
                _buildActiveFilterChip(
                  provider.selectedLanguage!,
                      () => provider.setLanguageFilter(null),
                  const Color(0xFFE57373),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDelete, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    _fabController.forward();

    return Expanded(
      child: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Oups !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadCourses(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun cours trouvé',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez d\'ajuster vos filtres de recherche',
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadCourses,
            color: const Color(0xFF4CAF50),
            child: _isGridView
                ? GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.courses.length,
              itemBuilder: (context, index) {
                final course = provider.courses[index];
                return _CourseGridCard(course: course);
              },
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: provider.courses.length,
              itemBuilder: (context, index) {
                final course = provider.courses[index];
                return _ModernCourseCard(course: course, index: index);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Modern Course Card for List View
class _ModernCourseCard extends StatelessWidget {
  final Course course;
  final int index;

  const _ModernCourseCard({required this.course, required this.index});

  Color _getLevelColor() {
    switch (course.level) {
      case 'Débutant':
        return const Color(0xFF4CAF50);
      case 'Intermédiaire':
        return const Color(0xFFFF9800);
      case 'Avancé':
        return const Color(0xFFE57373);
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForSubject() {
    switch (course.subject?.toLowerCase() ?? '') {
      case 'programmation':
        return Icons.code;
      case 'mathématiques':
        return Icons.functions;
      case 'physique':
        return Icons.science;
      case 'chimie':
        return Icons.biotech;
      case 'langues':
        return Icons.language;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _getLevelColor().withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(courseId: course.id!),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Image avec effet glassmorphism
                  _buildCourseImage(),
                  const SizedBox(width: 20),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges avec nouveau design
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF45A049),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                course.subject ?? 'Cours',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getLevelColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getLevelColor().withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                course.level,
                                style: TextStyle(
                                  color: _getLevelColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title avec meilleur style
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.3,
                            color: Colors.grey[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Instructor avec icône améliorée
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                course.instructorName ?? 'Instructeur',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Rating seulement
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              const Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Excellent',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow avec animation
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: course.imageUrl != null && course.imageUrl!.isNotEmpty
            ? Image.file(
          File(course.imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        )
            : _buildDefaultIcon(),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getLevelColor().withOpacity(0.2),
            _getLevelColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        _getIconForSubject(),
        color: _getLevelColor(),
        size: 40,
      ),
    );
  }
}

/// Modern Course Card for Grid View
class _CourseGridCard extends StatelessWidget {
  final Course course;

  const _CourseGridCard({required this.course});

  Color _getLevelColor() {
    switch (course.level) {
      case 'Débutant':
        return const Color(0xFF4CAF50);
      case 'Intermédiaire':
        return const Color(0xFFFF9800);
      case 'Avancé':
        return const Color(0xFFE57373);
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForSubject() {
    switch (course.subject?.toLowerCase() ?? '') {
      case 'programmation':
        return Icons.code;
      case 'mathématiques':
        return Icons.functions;
      case 'physique':
        return Icons.science;
      case 'chimie':
        return Icons.biotech;
      case 'langues':
        return Icons.language;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor().withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailScreen(courseId: course.id!),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container avec overlay gradient
              _buildGridCourseImage(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge niveau avec nouveau design
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getLevelColor(),
                            _getLevelColor().withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getLevelColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        course.level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.3,
                        color: Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Subject badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        course.subject ?? 'Cours',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),

                    // Rating uniquement
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCourseImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 140,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                ? Image.file(
              File(course.imageUrl!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultGridIcon();
              },
            )
                : _buildDefaultGridIcon(),
          ),
        ),
        // Gradient overlay pour meilleur contraste
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultGridIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getLevelColor().withOpacity(0.2),
            _getLevelColor().withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Icon(
        _getIconForSubject(),
        color: _getLevelColor(),
        size: 56,
      ),
    );
  }
}