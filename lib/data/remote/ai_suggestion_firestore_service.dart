import 'package:act_for_earth/domain/model/ai_suggestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AISuggestionFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'ai_suggestions';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  Stream<List<AISuggestion>> watchSuggestions(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(AISuggestion.fromFirestore)
          .toList(growable: false);
    });
  }

  Future<List<AISuggestion>> getSuggestions(String userId) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map(AISuggestion.fromFirestore)
        .toList(growable: false);
  }

  Future<void> createSuggestion(AISuggestion suggestion) async {
    await _collection.add(suggestion.toFirestore());
  }

  Future<void> updateSuggestionStatus(String suggestionId, String status) async {
    await _collection.doc(suggestionId).update({'status': status});
  }

  Future<void> deleteSuggestion(String suggestionId) async {
    await _collection.doc(suggestionId).delete();
  }
}
