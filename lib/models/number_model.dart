import 'package:cloud_firestore/cloud_firestore.dart';

class NumberModel {
  int number;
  bool selected;
  String? selectedBy;
  DateTime? reserveTimestamp;
  String? idFirebase;

  NumberModel(this.number, {this.selected = false, this.selectedBy, this.idFirebase, this.reserveTimestamp});

  Map<String, dynamic> toMap() {
    return {
      'idFirebase': idFirebase,
      'number': number,
      'selected': selected,
      'selectedBy': selectedBy,
      'reserveTimestamp': reserveTimestamp?.millisecondsSinceEpoch,
    };
  }

  factory NumberModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return NumberModel(
      data['number'],
      selected: data['selected'] ?? false,
      selectedBy: data['selectedBy'],
      idFirebase: snapshot.id,
      reserveTimestamp: data['reserveTimestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(data['reserveTimestamp']) : null,
    );
  }
}
