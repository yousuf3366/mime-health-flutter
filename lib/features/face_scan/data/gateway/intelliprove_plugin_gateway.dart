import '../../domain/gateway/face_scan_plugin_gateway.dart';
import '../bridge/intelliprove_webview_bridge.dart';

class IntelliProvePluginGateway implements FaceScanPluginGateway {
  IntelliProvePluginGateway(this._bridge);

  final IntelliProveWebViewBridge _bridge;

  @override
  Future<String> openScan(String url) => _bridge.runScan(url);
}
