// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stokmobile/loginpage/page/login_page.dart';
import 'package:stokmobile/shared/app_colors.dart';

class NativeSplashPage extends StatefulWidget {
  const NativeSplashPage({super.key});

  static const route = '/splash';

  @override
  State<NativeSplashPage> createState() => _NativeSplashPageState();
}

class _NativeSplashPageState extends State<NativeSplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(LoginPage.route);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF34D399),
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Convert the Figma CSS angle to Flutter's box-relative endpoints.
            const angle = 114.80096498693584 * math.pi / 180;
            final dx = math.sin(angle);
            final dy = -math.cos(angle);
            final length =
                constraints.maxWidth * dx.abs() +
                constraints.maxHeight * dy.abs();
            final end = Alignment(
              dx * length / constraints.maxWidth,
              dy * length / constraints.maxHeight,
            );
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-end.x, -end.y),
                  end: end,
                  colors: const [Color(0xFF064E3B), Color(0xFF34D399)],
                  stops: const [0.25, 0.75],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 326,
                      height: 170,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/images/splash_symbol.svg',
                            width: 94,
                            height: 94,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: 33),
                          Text(
                            'StokMobile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 32,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
