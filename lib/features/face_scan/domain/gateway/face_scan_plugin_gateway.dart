/// Opens the native IntelliProve plug-in and returns a face-scan id.
abstract class FaceScanPluginGateway {
  Future<String> openScan(String url);
}
