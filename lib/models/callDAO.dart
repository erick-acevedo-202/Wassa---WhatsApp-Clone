class CallDAO {
  String? id;

  DateTime fecha;
  DateTime horaInicio;

  String status;
  String callerId;
  List<String> calleeIds;
  String? roomId;
  String? authToken;

  CallDAO({
    this.id,
    required this.fecha,
    required this.horaInicio,
    required this.status,
    required this.callerId,
    required this.calleeIds,
    this.roomId,
    this.authToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'horaInicio': horaInicio.toIso8601String(),
      'status': status,
      'callerId': callerId,
      'calleeIds': calleeIds,
      'roomId': roomId,
      'authToken': authToken,
    };
  }

  factory CallDAO.fromMap(Map<String, dynamic> map, {String? id}) {
    return CallDAO(
      id: id,
      fecha: DateTime.parse(map['fecha']),
      horaInicio: DateTime.parse(map['horaInicio']),
      status: map['status'],
      callerId: map['callerId'],
      calleeIds: List<String>.from(map['calleeIds'] ?? []),
      roomId: map['roomId'],
      authToken: map['authToken'],
    );
  }
}
