import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

class SubscriptionDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid; // Add a uid variable

  SubscriptionDbService(this.uid);

  Future<void> saveSubcriptionsDetails(PurchaseDetails purchaseDetails) async {
    try{
      GooglePlayPurchaseDetails gpp =
      purchaseDetails as GooglePlayPurchaseDetails;
      _firestore.collection('users').doc(uid).set({
        "Purchase Wrapper": {
          'developerPayload': gpp.billingClientPurchase.developerPayload,
          'isAcknowledged': gpp.billingClientPurchase.isAcknowledged,
          'isAutoRenewing': gpp.billingClientPurchase.isAutoRenewing,
          'obfuscatedAccountId': gpp.billingClientPurchase.obfuscatedAccountId,
          'obfuscatedProfileId': gpp.billingClientPurchase.obfuscatedProfileId,
          'orderId': gpp.billingClientPurchase.orderId,
          'originalJson': gpp.billingClientPurchase.originalJson,
          'packageName': gpp.billingClientPurchase.packageName,
          'purchaseTime': gpp.billingClientPurchase.purchaseTime,
          'purchaseToken': gpp.billingClientPurchase.purchaseToken,
          'signature': gpp.billingClientPurchase.signature,
          'sku': gpp.billingClientPurchase.sku
        }
      }, SetOptions(merge: true));
    }catch(e){
      print(e);
    }
  }

  Stream<UserData> get featchUserDataFromDb {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => userDataFromSnapshot(event));
  }

  UserData userDataFromSnapshot(DocumentSnapshot ds) {
    GooglePlayPurchaseDetails? oldPd;

    try {
      var pw = ds.get('Purchase Wrapper');
      oldPd = GooglePlayPurchaseDetails.fromPurchase(PurchaseWrapper(
        isAcknowledged: pw['isAcknowledged'],
        isAutoRenewing: pw['isAutoRenewing'],
        orderId: pw['orderId'],
        originalJson: pw['originalJson'],
        packageName: pw['packageName'],
        purchaseState: PurchaseStateWrapper.purchased,
        purchaseTime: pw['purchaseTime'],
        purchaseToken: pw['purchaseToken'],
        signature: pw['signature'],
        sku: pw['sku'],
        developerPayload: pw['developerPayload'],
        obfuscatedAccountId: pw['obfuscatedAccountId'],
        obfuscatedProfileId: pw['obfuscatedProfileId'],
      ));
    } catch (e) {}

    return UserData(oldPdFromDb: oldPd, username: ds.get('username'));
  }

  Future<bool> checkUserSubscriptionStatus() async {
    String userUid = uid;

    // Create a reference to the Purchase Collection
    var purchaseRef = _firestore.collection("purchases");

    // Create a query against the userid.
    Query<Map<String, dynamic>> query =
        purchaseRef.where(userUid, isEqualTo: userUid);

    QuerySnapshot querySnapshot = await query.get();

    bool subStatus = false;
    for (QueryDocumentSnapshot ds in querySnapshot.docs) {
      String status = ds.get('status');
      // "ACTIVE", // Payment received
      // "ACTIVE", // Free trial
      // "EXPIRED", // Expired or cancelled
      if (status == "ACTIVE") {
        subStatus = true;
      }
    }

    return subStatus;
  }
}

class UserData {
  String username;
  GooglePlayPurchaseDetails? oldPdFromDb;
  UserData({required this.username, required this.oldPdFromDb});
}
