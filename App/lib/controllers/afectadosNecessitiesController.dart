class AfectadosNecessitiesController {
  final List<NeedItem> needs = [
    NeedItem(label: 'Comida'),
    NeedItem(label: 'Productos farmacéuticos'),
    NeedItem(label: 'Limpieza'),
    NeedItem(label: 'Transporte y movilidad'),
    NeedItem(label: 'Apoyo psicológico'),
    NeedItem(label: 'Acogida'),
    NeedItem(label: 'Necesidades especiales'),
    NeedItem(label: 'Ropa'),
    NeedItem(label: 'Higiene Personal'),
  ];

  List<String> getSelectedNeeds() {
    return needs.where((item) => item.selected).map((e) => e.label).toList();
  }

  void submit() {
    final selected = getSelectedNeeds();
    print("Necesidades seleccionadas: $selected");
    // Aquí podrías enviarlas al backend, guardarlas, etc.
  }
}

class NeedItem {
  String label;
  bool selected;

  NeedItem({required this.label, this.selected = true});
}
