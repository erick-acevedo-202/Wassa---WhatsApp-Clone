class StateContent {
  final String type; // "text" | "photo" | "video" | "audio"
  final String data; // texto o URL
  final String? caption; // opcional, solo para foto/video
  final int? duration; // opcional, solo para audio/video en segundos

  StateContent({
    required this.type,
    required this.data,
    this.caption,
    this.duration,
  });

  factory StateContent.fromMap(Map<String, dynamic> map) {
    return StateContent(
      type: map['type'] ?? 'text',
      data: map['data'] ?? '',
      caption: map['caption'],
      duration: map['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
      if (caption != null) 'caption': caption,
      if (duration != null) 'duration': duration,
    };
  }
}
