import 'package:flutter_application2/firebase_data_connect.dart';

class DefaultConnector {
  static const ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
    'default',
    'flutterapplication2',
  );

  DefaultConnector._internal({required this.dataConnect});

  static late final DefaultConnector _instance = DefaultConnector._internal(
    dataConnect: FirebaseDataConnect.instanceFor(
      connectorConfig: connectorConfig,
      sdkType: CallerSDKType.generated,
    ),
  );

  static DefaultConnector get instance => _instance;

  final FirebaseDataConnect dataConnect;
}
