class CovidData {
  int id;
  String province;
  String district;
  String address;
  double latitude;
  double longitude;
  String createdAt;
  String updatedAt;
  int status;
  double distance;

  CovidData(
      {this.id,
        this.province,
        this.district,
        this.address,
        this.latitude,
        this.longitude,
        this.createdAt,
        this.updatedAt,
        this.status, this.distance});

  static List<CovidData> parsePlacesList(map) {
    var list = map['data'] as List;
    return list.map((product) => CovidData.fromJson(product)).toList();
  }

  CovidData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    province = json['province'];
    district = json['district'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['province'] = this.province;
    data['district'] = this.district;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['status'] = this.status;
    return data;
  }
}