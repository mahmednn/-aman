class SelectedLocation {
  final double latitude;
  final double longitude;
  final String? name;
  final String? address;

  SelectedLocation({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
  });
}
