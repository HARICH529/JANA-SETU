import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  Function(String, String)? onStatusUpdate;

  void connect() {
    _socket = IO.io('http://10.1.50.236:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Connected to server');
    });

    _socket!.on('report-status-update', (data) {
      print('Status update received: $data');
      if (onStatusUpdate != null) {
        onStatusUpdate!(data['reportId'], data['status']);
      }
    });

    _socket!.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void joinReport(String reportId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join-report', reportId);
      print('Joined report room: $reportId');
    }
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
