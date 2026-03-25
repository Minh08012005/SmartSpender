import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/strings.dart';
import '../shared/utils/smooth_navigation.dart';
import '../theme/colors.dart';
import '../theme/text_style.dart';
import 'login.dart';
import 'register.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ApiConstants.onboardingSeenKey, true);
  }

  Future<void> _goToLogin(BuildContext context) async {
    await _markOnboardingSeen();
    if (!context.mounted) return;
    SmoothNavigation.push(context, const LoginScreen());
  }

  Future<void> _goToRegister(BuildContext context) async {
    await _markOnboardingSeen();
    if (!context.mounted) return;
    SmoothNavigation.push(context, const RegisterScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffECEDEE),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 414),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE7E8EA)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.53,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xffEAF2F1),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                          ),
                          for (final size in [430.0, 320.0, 240.0])
                            Align(
                              alignment: const Alignment(0, -0.1),
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          const _HeroIllustration(),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipPath(
                              clipper: _DiagonalTopClipper(),
                              child: Container(height: 62, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.onboardingTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.welcomeTitle.copyWith(
                                fontSize: 54 / 2,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff69AEA9),
                                      Color(0xff3F8782),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xff3F8782,
                                      ).withValues(alpha: 0.24),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(40),
                                    onTap: () => _goToRegister(context),
                                    child: Center(
                                      child: Text(
                                        AppStrings.onboardingGetStarted,
                                        style: AppTextStyle.buttonText.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  AppStrings.onboardingAlreadyHaveAccount,
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _goToLogin(context),
                                  child: Text(
                                    AppStrings.signIn,
                                    style: AppTextStyle.link.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 44,
          top: 80,
          child: _bubble(
            icon: Icons.attach_money,
            color: const Color(0xff63B3FF),
          ),
        ),
        Positioned(
          right: 42,
          top: 114,
          child: _bubble(icon: Icons.pie_chart, color: const Color(0xffFF81C8)),
        ),
        Align(
          alignment: const Alignment(0, 0.02),
          child: Container(
            width: 220,
            height: 248,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff6AB9B2), Color(0xff4B938D)],
              ),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff4B938D).withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: _FinanceCardsGraphic(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble({required IconData icon, required Color color}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

class _FinanceCardsGraphic extends StatelessWidget {
  const _FinanceCardsGraphic();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(-0.55, 0.35),
          child: _miniCard(
            icon: Icons.trending_down_rounded,
            background: const Color(0xffFFE8F5),
            iconColor: const Color(0xffD5529B),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, -0.55),
          child: _miniCard(
            icon: Icons.savings_rounded,
            background: const Color(0xffE2F3FF),
            iconColor: const Color(0xff2A8AC8),
          ),
        ),
        Align(
          alignment: const Alignment(0.55, 0.35),
          child: _miniCard(
            icon: Icons.trending_up_rounded,
            background: const Color(0xffFFF1D9),
            iconColor: const Color(0xffD88B15),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.1),
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniCard({
    required IconData icon,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 34),
    );
  }
}

class _DiagonalTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
