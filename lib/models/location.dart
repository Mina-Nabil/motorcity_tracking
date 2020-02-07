class Location {
  String name;
  String id;
  String long;
  String latt;

  Location({id, name, latt, long}) {
    this.id = (id) ?? "N/A";
    this.name = (name) ?? "N/A";
    this.latt = (latt) ?? "N/A";
    this.long = (long) ?? "N/A";
  }
}
