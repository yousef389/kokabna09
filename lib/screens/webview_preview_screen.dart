import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/page_service.dart';
import '../widgets/love_widgets.dart';

class WebViewPreviewScreen extends StatefulWidget {
  static const route = '/web-preview';
  const WebViewPreviewScreen({super.key});

  @override
  State<WebViewPreviewScreen> createState() => _WebViewPreviewScreenState();
}

class _WebViewPreviewScreenState extends State<WebViewPreviewScreen> {
  WebViewController? controller;
  bool loading = true;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller != null || error != null) return;
    final pageId = ModalRoute.of(context)!.settings.arguments as String;
    PageService.instance.buildPreviewHtml(pageId).then((html) {
      final c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'data' || uri.scheme == 'about') return NavigationDecision.navigate;
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) => setState(() => loading = false),
        ))
        ..loadHtmlString(html);
      setState(() => controller = c);
    }).catchError((e) => setState(() { error = e.toString(); loading = false; }));
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'معاينة آمنة',
      body: Stack(
        children: [
          if (error != null) Center(child: LoveCard(child: Text(error!))),
          if (controller != null) WebViewWidget(controller: controller!),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
