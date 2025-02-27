import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataConnect {
  final FirebaseFirestore firestore;

  FirebaseDataConnect._internal({required this.firestore});

  static late final FirebaseDataConnect _instance = FirebaseDataConnect._internal(
    firestore: FirebaseFirestore.instance,
  );

  static FirebaseDataConnect get instance => _instance;

  static FirebaseDataConnect instanceFor({
    required ConnectorConfig connectorConfig,
    required CallerSDKType sdkType,
  }) {
    // Burada connectorConfig ve sdkType parametrelerini kullanarak özel yapılandırmalar yapabilirsiniz.
    return _instance;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    return await firestore.collection(collectionPath).doc(documentId).get();
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    SetOptions? options,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).set(data, options);
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).update(data);
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    await firestore.collection(collectionPath).doc(documentId).delete();
  }
}

class ConnectorConfig {
  final String region;
  final String connectorName;
  final String projectId;

  const ConnectorConfig(this.region, this.connectorName, this.projectId);
}

enum CallerSDKType {
  generated,
  custom,
}