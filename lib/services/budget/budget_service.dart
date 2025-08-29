import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _budgetCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('budget');
  }

  // Save entire budget data
  Future<void> saveBudgetData({
    required int wholeBudget,
    required List<Map<String, dynamic>> budgetItems,
  }) async {
    try {
      // Save the whole budget
      await _budgetCollection.doc('settings').set({
        'wholeBudget': wholeBudget,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Get existing items to avoid duplicates
      final existingItems =
          await _budgetCollection.doc('items').collection('list').get();

      // Create a map of existing items by name
      final Map<String, DocumentSnapshot> existingItemsMap = {};
      for (var doc in existingItems.docs) {
        final data = doc.data();
        existingItemsMap[data['name']] = doc;
      }

      // Process each budget item
      for (var item in budgetItems) {
        final String name = item['name'];
        final int amount = item['amount'];
        final bool isPaid = item['isPaid'] ?? false;

        if (existingItemsMap.containsKey(name)) {
          // Update existing item
          final existingDoc = existingItemsMap[name]!;
          final existingData = existingDoc.data() as Map<String, dynamic>;

          if (existingData['amount'] != amount ||
              existingData['isPaid'] != isPaid) {
            await _budgetCollection
                .doc('items')
                .collection('list')
                .doc(existingDoc.id)
                .update({
              'amount': amount,
              'isPaid': isPaid,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        } else {
          // Add new item
          await _budgetCollection.doc('items').collection('list').add({
            'name': name,
            'amount': amount,
            'isPaid': isPaid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error saving budget data: $e');
      throw e;
    }
  }

  // Load budget data
  Future<Map<String, dynamic>> loadBudgetData() async {
    try {
      // Get whole budget
      final settingsDoc = await _budgetCollection.doc('settings').get();
      int wholeBudget = 0;

      if (settingsDoc.exists) {
        final data = settingsDoc.data() as Map<String, dynamic>?;
        wholeBudget = data?['wholeBudget'] as int? ?? 0;
      }

      // Get budget items
      final itemsQuery = await _budgetCollection
          .doc('items')
          .collection('list')
          .orderBy('createdAt')
          .get();

      final budgetItems = itemsQuery.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? '';
        final amount = data['amount'] ?? 0;
        final isPaid = data['isPaid'] ?? false;

        return [
          name.toString(),
          (amount is int) ? amount : int.tryParse(amount.toString()) ?? 0,
          isPaid, // Store paid status as the third element
          doc.id // Store the document ID as the fourth element
        ];
      }).toList();

      return {
        'wholeBudget': wholeBudget,
        'budgetItems': budgetItems,
      };
    } catch (e) {
      print('Error loading budget data: $e');
      return {
        'wholeBudget': 0,
        'budgetItems': [],
      };
    }
  }

  // Delete a budget item
  Future<void> deleteBudgetItem(String docId) async {
    try {
      await _budgetCollection
          .doc('items')
          .collection('list')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting budget item: $e');
      throw e;
    }
  }
}
