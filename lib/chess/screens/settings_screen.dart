import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/simple_sound_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    print('DEBUG: SettingsScreen initState called');
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
              Colors.brown[50]!,
              Colors.brown[100]!,
              Colors.brown[200]!,
              Colors.brown[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(child: _buildHeader()),
                    Expanded(
                      child: SingleChildScrollView(child: _buildSettingsContent()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.brown[700]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.brown[700],
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.settings,
              color: Colors.brown[700],
              size: 28.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          _buildAudioSection(),
          SizedBox(height: 30.h),
          _buildGameSection(),
          SizedBox(height: 30.h),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return _buildSectionCard(
      title: 'Audio Settings',
      icon: Icons.volume_up,
      children: [
        _buildToggleTile(
          title: 'Background Music',
          subtitle: 'Play ambient music during gameplay',
          icon: Icons.music_note,
          value: SimpleSoundManager().isMusicEnabled,
          onChanged: (value) {
            setState(() {
              if (value) {
                SimpleSoundManager().enableMusic();
                SimpleSoundManager().playBackgroundMusic();
              } else {
                SimpleSoundManager().disableMusic();
              }
            });
          },
        ),
        SizedBox(height: 16.h),
        _buildToggleTile(
          title: 'Sound Effects',
          subtitle: 'Play sounds for moves and captures',
          icon: Icons.speaker,
          value: SimpleSoundManager().isSoundEnabled,
          onChanged: (value) {
            setState(() {
              if (value) {
                SimpleSoundManager().enableSound();
              } else {
                SimpleSoundManager().disableSound();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildGameSection() {
    return _buildSectionCard(
      title: 'Game Settings',
      icon: Icons.sports_esports,
      children: [
        _buildInfoTile(
          title: 'AI Difficulty',
          subtitle: 'Adaptive difficulty based on your skill',
          icon: Icons.psychology,
        ),
        SizedBox(height: 16.h),
        _buildInfoTile(
          title: 'Game Progress',
          subtitle: '100 levels with progressive difficulty',
          icon: Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'About',
      icon: Icons.info_outline,
      children: [
        _buildInfoTile(
          title: 'Classic Chess',
          subtitle: 'Version 1.0.0',
          icon: Icons.king_bed,
        ),
        SizedBox(height: 16.h),
        _buildInfoTile(
          title: 'Developed with Flutter',
          subtitle: 'Cross-platform chess experience',
          icon: Icons.code,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.brown[300]!.withOpacity(0.3),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.brown[700]!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.brown[700],
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.brown[200]!,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.brown[600],
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.brown[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.brown[600],
            activeTrackColor: Colors.brown[200],
            inactiveThumbColor: Colors.brown[300],
            inactiveTrackColor: Colors.brown[100],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.brown[200]!,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.brown[600],
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.brown[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
