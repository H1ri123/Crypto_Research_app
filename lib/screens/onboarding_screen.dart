import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      title: 'The Card That\nWorks Anywhere',
      description:
          'Create your account to trade, store, and grow your digital assets securely',
      imagePath: 'assets/onboard1.jpg',
    ),
    OnboardingItem(
      title: 'Your Assets Are\nAlways Protected',
      description:
          'Store and manage your crypto with cutting-edge security technologies',
      imagePath: 'assets/onboard2.gif',
    ),
    OnboardingItem(
      title: 'Your Entire Crypto\nLife In One App',
      description:
          'All your wallets and transactions in one place — easy to access, easier to control',
      imagePath: 'assets/onboard3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 3400), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onNext() {
    _startAutoScroll(); // Reset auto-scroll timer on user tap
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    _autoScrollTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const LoginScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // PageView containing edge-to-edge slide images and text
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _startAutoScroll(); // restart auto-scroll timer after swipe
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                final isActive = _currentPage == index;
                return Column(
                  children: [
                    // Full Display Hero Image (Edge-to-edge, full width, no clipping side margins)
                    Expanded(
                      flex: 58,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            slide.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/onboard2.jpg',
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.secondary,
                                    child: const Center(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedAnalytics01,
                                        size: 80,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Subtle bottom gradient fade to seamlessly blend into background
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.background,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Information Section with Fast Animated One-By-One Text
                    Expanded(
                      flex: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _AnimatedOnboardingText(
                          key: ValueKey('slide_text_$index'),
                          title: slide.title,
                          description: slide.description,
                          isActive: isActive,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Skip Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: isLastPage
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: _navigateToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),

            // Static Indicator Dots (Fixed on screen, does NOT slide horizontally with page)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 104,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == dotIndex ? 26 : 7,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == dotIndex
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Button with Center Big Font
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 26,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _onNext,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // #B4DE01
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedOnboardingText extends StatefulWidget {
  final String title;
  final String description;
  final bool isActive;

  const _AnimatedOnboardingText({
    super.key,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  State<_AnimatedOnboardingText> createState() => _AnimatedOnboardingTextState();
}

class _AnimatedOnboardingTextState extends State<_AnimatedOnboardingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _line1Fade;
  late Animation<Offset> _line1Slide;
  late Animation<double> _line2Fade;
  late Animation<Offset> _line2Slide;
  late Animation<double> _descFade;
  late Animation<Offset> _descSlide;

  late List<String> _titleLines;

  @override
  void initState() {
    super.initState();
    _titleLines = widget.title.split('\n');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _setupAnimations();

    if (widget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  void _setupAnimations() {
    _line1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.48, curve: Curves.easeOutCubic),
      ),
    );
    _line1Slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.48, curve: Curves.easeOutCubic),
      ),
    );

    _line2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _line2Slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _descFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedOnboardingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title) {
      _titleLines = widget.title.split('\n');
    }
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Title Line 1
        SlideTransition(
          position: _line1Slide,
          child: FadeTransition(
            opacity: _line1Fade,
            child: Text(
              _titleLines.isNotEmpty ? _titleLines[0] : widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        // Title Line 2 (if present)
        if (_titleLines.length > 1) ...[
          SlideTransition(
            position: _line2Slide,
            child: FadeTransition(
              opacity: _line2Fade,
              child: Text(
                _titleLines[1],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        // Subtitle / Description
        SlideTransition(
          position: _descSlide,
          child: FadeTransition(
            opacity: _descFade,
            child: Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

