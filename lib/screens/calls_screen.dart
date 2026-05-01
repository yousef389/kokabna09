import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/call_service.dart';
import '../widgets/love_widgets.dart';

class CallsScreen extends StatelessWidget {
  static const route = '/calls';
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'المكالمات',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LoveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('المكالمات الصوتية والفيديو', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('تم تجهيز واجهة المكالمات وسجل الإشارات داخل قاعدة البيانات. لتشغيل مكالمات حقيقية على الإنترنت اربط WebRTC مع خادم STUN/TURN.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(onPressed: () => CallService.instance.startCall('voice'), icon: const Icon(Icons.call), label: const Text('بدء مكالمة صوتية')),
                  const SizedBox(height: 8),
                  FilledButton.icon(onPressed: () => CallService.instance.startCall('video'), icon: const Icon(Icons.video_call), label: const Text('بدء مكالمة فيديو')),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: CallService.instance.calls(),
              builder: (_, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.call, title: 'لا توجد مكالمات بعد', subtitle: 'بحبك يا هدهدتي');
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data();
                    return ListTile(
                      leading: Icon(d['kind'] == 'video' ? Icons.videocam : Icons.call),
                      title: Text(_callTitle(d['kind'])),
                      subtitle: Text(_callStatus(d['status'])),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) => CallService.instance.updateStatus(docs[i].id, v),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'accepted', child: Text('تمييز كمقبولة')),
                          PopupMenuItem(value: 'ended', child: Text('إنهاء')),
                          PopupMenuItem(value: 'missed', child: Text('فائتة')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


String _callTitle(dynamic kind) {
  switch ((kind ?? '').toString()) {
    case 'video':
      return 'مكالمة فيديو';
    case 'voice':
      return 'مكالمة صوتية';
    default:
      return 'مكالمة';
  }
}

String _callStatus(dynamic status) {
  switch ((status ?? '').toString()) {
    case 'ringing':
      return 'يرن الآن';
    case 'accepted':
      return 'تم القبول';
    case 'ended':
      return 'انتهت';
    case 'missed':
      return 'فائتة';
    default:
      return 'غير معروف';
  }
}
