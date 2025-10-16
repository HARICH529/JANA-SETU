import 'package:audioplayers/audioplayers.dart';
import 'package:jana_setu/api/database_service.dart';
import 'package:jana_setu/models/issue_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IssueCard extends StatefulWidget {
  final Issue issue;
  const IssueCard({super.key, required this.issue});

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.issue.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) => Container(height: 200, child: Icon(Icons.broken_image, size: 48)),
            ),
            const SizedBox(height: 10),
            Text(widget.issue.description ?? 'No description provided.',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            if (widget.issue.voiceNoteUrl != null)
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play(UrlSource(widget.issue.voiceNoteUrl!));
                      }
                    },
                  ),
                  const Text('Play voice note'),
                ],
              ),
            Text(
                'Reported on: ${DateFormat.yMMMd().add_jm().format(widget.issue.timestamp.toDate())}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(widget.issue.status),
                  backgroundColor: widget.issue.status == 'Resolved'
                      ? Colors.green[100]
                      : widget.issue.status == 'In Progress'
                          ? Colors.orange[100]
                          : Colors.grey[200],
                ),
                if (widget.issue.status == 'Resolved' && !widget.issue.isAcknowledged)
                  ElevatedButton(
                    onPressed: () async {
                      await dbService.acknowledgeResolution(widget.issue.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Thank you for your feedback!')),
                      );
                    },
                    child: const Text('Acknowledge'),
                  ),
                if (widget.issue.status == 'Resolved' && widget.issue.isAcknowledged)
                  const Chip(
                    avatar: Icon(Icons.check_circle, color: Colors.green),
                    label: Text('Acknowledged'),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
