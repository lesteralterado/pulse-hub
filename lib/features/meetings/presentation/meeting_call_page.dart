import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/meeting_providers.dart';
import '../domain/meeting.dart';

/// UI shell for the video call screen. **Not actually connected to
/// LiveKit** — see LiveKitService's doc comment for what's missing. The
/// participant grid uses real meeting_participants data as placeholder
/// tiles; the control bar buttons toggle local state only and surface a
/// clear "not set up yet" message rather than silently doing nothing.
class MeetingCallPage extends ConsumerStatefulWidget {
  const MeetingCallPage({super.key, required this.meeting});

  final Meeting meeting;

  @override
  ConsumerState<MeetingCallPage> createState() => _MeetingCallPageState();
}

class _MeetingCallPageState extends ConsumerState<MeetingCallPage> {
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isScreenSharing = false;
  String? _tokenError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_requestToken);
  }

  Future<void> _requestToken() async {
    final result = await ref.read(liveKitServiceProvider).getAccessToken(widget.meeting.id);
    if (!mounted) return;
    result.when(
      // A real connection would happen here once livekit_client is wired
      // up; for now a success still leaves the stub UI in place.
      success: (_) {},
      failure: (error) => setState(() => _tokenError = describeError(error)),
    );
  }

  void _notConfiguredYet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Video calling isn't set up yet — this control has no LiveKit connection to act on."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(meetingParticipantsProvider(widget.meeting.id));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.meeting.title),
      ),
      body: Column(
        children: [
          if (_tokenError != null)
            Container(
              width: double.infinity,
              color: Colors.orange.shade900,
              padding: const EdgeInsets.all(12),
              child: Text(
                "Video calling isn't set up yet. $_tokenError",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: participantsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (error, _) => Center(
                child: Text(describeError(error), style: const TextStyle(color: Colors.white)),
              ),
              data: (participants) => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final initial = participant.displayName.isNotEmpty
                      ? participant.displayName[0].toUpperCase()
                      : '?';
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 32,
                            child: Text(initial, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Text(
                            participant.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallControlButton(
                  icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                  isActive: !_isMicMuted,
                  onPressed: () {
                    setState(() => _isMicMuted = !_isMicMuted);
                    _notConfiguredYet();
                  },
                ),
                _CallControlButton(
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  isActive: !_isCameraOff,
                  onPressed: () {
                    setState(() => _isCameraOff = !_isCameraOff);
                    _notConfiguredYet();
                  },
                ),
                _CallControlButton(
                  icon: Icons.screen_share,
                  isActive: _isScreenSharing,
                  onPressed: () {
                    setState(() => _isScreenSharing = !_isScreenSharing);
                    _notConfiguredYet();
                  },
                ),
                _CallControlButton(
                  icon: Icons.call_end,
                  isActive: false,
                  backgroundColor: Colors.red,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.backgroundColor,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: backgroundColor ?? (isActive ? Colors.grey[700] : Colors.white24),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
