import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _info;

  // TODO: replace with actual URL before release
  static const _privacyPolicyUrl = '';
  // TODO: replace with official support email before release
  static const _contactEmail = 'ks9275ks9275@gmail.com';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  String get _version =>
      _info != null ? '${_info!.version} (${_info!.buildNumber})' : '—';

  // ── Actions ───────────────────────────────────────────────

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  void _onPrivacyPolicy() {
    if (_privacyPolicyUrl.isEmpty) {
      _showDialog(
        title: '개인정보처리방침',
        content: '개인정보처리방침 페이지는 현재 준비 중입니다.\n'
            '출시 전 업데이트될 예정입니다.',
      );
    } else {
      _launch(_privacyPolicyUrl);
    }
  }

  void _onAdInfo() {
    _showDialog(
      title: '광고 안내',
      content: 'Smart Calculator Plus는 Google AdMob을 통해 '
          '배너 광고를 제공합니다.\n\n'
          '광고 수익은 앱의 무료 서비스 유지에 사용됩니다.\n\n'
          '광고 관련 문의는 문의하기를 이용해 주세요.',
    );
  }

  void _onContact() {
    _launch(
      'mailto:$_contactEmail'
      '?subject=Smart%20Calculator%20Plus%20%EB%AC%B8%EC%9D%98',
    );
  }

  void _onLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Smart Calculator Plus',
      applicationVersion: _info?.version ?? '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          Icons.calculate_rounded,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showDialog({required String title, required String content}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('설정 / 정보'),
      ),
      body: ListView(
        children: [
          _AppHeader(cs: cs, version: _version),
          const SizedBox(height: 8),

          _SectionLabel('법적 정보'),
          _Tile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            subtitle: '개인정보 수집 및 이용 안내',
            onTap: _onPrivacyPolicy,
          ),
          _Tile(
            icon: Icons.campaign_outlined,
            title: '광고 안내',
            subtitle: 'Google AdMob 배너 광고 사용',
            onTap: _onAdInfo,
          ),
          const _Divider(),

          _SectionLabel('지원'),
          _Tile(
            icon: Icons.mail_outline_rounded,
            title: '문의하기',
            subtitle: _contactEmail,
            onTap: _onContact,
          ),
          const _Divider(),

          _SectionLabel('앱 정보'),
          _Tile(
            icon: Icons.code_rounded,
            title: '오픈소스 라이선스',
            subtitle: '사용된 오픈소스 패키지 목록',
            onTap: _onLicenses,
          ),
          _Tile(
            icon: Icons.info_outline_rounded,
            title: '버전',
            subtitle: _version,
            onTap: null,
            trailing: null,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final ColorScheme cs;
  final String version;
  const _AppHeader({required this.cs, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.calculate_rounded,
                size: 40, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Calculator Plus',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v$version',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = const Icon(Icons.chevron_right_rounded, size: 20),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onSurfaceVariant),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: onTap != null ? trailing : null,
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 16, endIndent: 16);
}
