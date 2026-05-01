import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _route(BuildContext context, AppState state) {
    if (!state.bootstrapped) return;
    if (state.signedIn && !state.coupleLoaded) return;
    final route = state.signedIn && state.isMember ? HomeScreen.route : LoginScreen.route;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    _route(context, state);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer,
              scheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'our-planet-logo',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Image.asset('assets/logo.png', width: 160, height: 160, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Text('Our Planet 💕',
                  style: GoogleFonts.cairo(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  )),
              const SizedBox(height: 8),
              Text('بحبك يا هدهدتي',
                  style: GoogleFonts.cairo(fontSize: 16, color: scheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 36),
              CircularProgressIndicator(color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
