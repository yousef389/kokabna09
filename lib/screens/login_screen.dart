import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../widgets/love_widgets.dart';

class LoginScreen extends StatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final email      = TextEditingController();
  final password   = TextEditingController();
  final nickname   = TextEditingController();
  final coupleName = TextEditingController(text: 'Our Planet');
  final invite     = TextEditingController();
  bool busy  = false;
  bool _obscure = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose(); email.dispose(); password.dispose();
    nickname.dispose(); coupleName.dispose(); invite.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() { busy = true; error = null; });
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [scheme.primaryContainer, scheme.surface],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              // لوجو
              Center(
                child: Hero(
                  tag: 'our-planet-logo',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/logo.png', width: 110, height: 110, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Our Planet 💕',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w800, color: scheme.primary)),
              Text('بحبك يا هدهدتي',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 14, color: scheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 20),
              // تبويبات
              Card(
                child: TabBar(
                  controller: _tab,
                  tabs: const [Tab(text: 'دخول'), Tab(text: 'أدمن جديد'), Tab(text: 'انضمام')],
                ),
              ),
              const SizedBox(height: 14),
              if (error != null)
                LoveCard(
                  color: scheme.errorContainer,
                  child: Text(error!, style: TextStyle(color: scheme.onErrorContainer)),
                ),
              SizedBox(
                height: 500,
                child: TabBarView(controller: _tab, children: [
                  _loginTab(),
                  _adminTab(),
                  _partnerTab(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fields({bool nick = false, bool couple = false, bool code = false}) {
    return Column(children: [
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'البريد الإلكتروني'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: _obscure,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          labelText: 'كلمة المرور',
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      if (nick) ...[
        const SizedBox(height: 12),
        TextField(
          controller: nickname,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'اسمك المستعار'),
        ),
      ],
      if (couple) ...[
        const SizedBox(height: 12),
        TextField(
          controller: coupleName,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.favorite), labelText: 'اسم مساحتكم'),
        ),
      ],
      if (code) ...[
        const SizedBox(height: 12),
        TextField(
          controller: invite,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_lock), labelText: 'كود الدعوة'),
        ),
      ],
    ]);
  }

  Widget _loginTab() => LoveCard(child: Column(children: [
    _fields(),
    const SizedBox(height: 18),
    ProgressButton(busy: busy, label: 'دخول', icon: Icons.lock_open,
        onPressed: () => run(() => AuthService.instance.login(email.text, password.text))),
  ]));

  Widget _adminTab() => LoveCard(child: Column(children: [
    _fields(nick: true, couple: true),
    const SizedBox(height: 18),
    ProgressButton(busy: busy, label: 'إنشاء مساحتنا', icon: Icons.favorite,
        onPressed: () => run(() => AuthService.instance.createAdmin(
          email: email.text, password: password.text,
          nickname: nickname.text, coupleName: coupleName.text,
        ))),
  ]));

  Widget _partnerTab() => LoveCard(child: Column(children: [
    _fields(nick: true, code: true),
    const SizedBox(height: 18),
    ProgressButton(busy: busy, label: 'انضمام كشريك', icon: Icons.mail_lock,
        onPressed: () => run(() => AuthService.instance.joinAsPartner(
          email: email.text, password: password.text,
          nickname: nickname.text, inviteCode: invite.text,
        ))),
  ]));
}
