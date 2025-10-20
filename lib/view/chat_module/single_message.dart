import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleMessage extends StatelessWidget {
  final String? message;
  final bool? isMe;
  final String? type;
  final String? friendName;
  final String? myName;
  final Timestamp? date;

  const SingleMessage({
    super.key,
    this.message,
    this.isMe,
    this.type,
    this.friendName,
    this.myName,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final DateTime d = date?.toDate() ?? DateTime.now();
    final String formattedTime =
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

    final alignment = (isMe ?? false) ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = (isMe ?? false) ? Colors.pink : Colors.black87;
    final borderRadius = (isMe ?? false)
        ? const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          );

    if (type == "text") {
      return _buildMessageBubble(
        size,
        alignment,
        bubbleColor,
        borderRadius,
        Column(
          crossAxisAlignment: (isMe ?? false)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isMe == true ? myName ?? "" : friendName ?? "",
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const Divider(color: Colors.transparent, height: 4),
            Text(
              message ?? "",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
            const Divider(color: Colors.transparent, height: 6),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      );
    } else if (type == "img") {
      return _buildMessageBubble(
        size,
        alignment,
        bubbleColor,
        borderRadius,
        Column(
          crossAxisAlignment: (isMe ?? false)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isMe == true ? myName ?? "" : friendName ?? "",
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            CachedNetworkImage(
              imageUrl: message ?? '',
              fit: BoxFit.cover,
              height: size.height / 3.2,
              width: size.width / 1.5,
              placeholder: (context, url) =>
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      );
    } else {
      return _buildMessageBubble(
        size,
        alignment,
        bubbleColor,
        borderRadius,
        Column(
          crossAxisAlignment: (isMe ?? false)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isMe == true ? myName ?? "" : friendName ?? "",
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const Divider(color: Colors.transparent, height: 4),
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(message ?? "");
                if (uri != null) await launchUrl(uri);
              },
              child: Text(
                message ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Divider(color: Colors.transparent, height: 6),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageBubble(Size size, Alignment alignment, Color color,
      BorderRadius borderRadius, Widget child) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: size.width * 0.7),
        child: child,
      ),
    );
  }
}
