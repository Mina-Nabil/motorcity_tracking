
class TruckRequest {
  String id;
  String from;
  String to;
  String reqDate;
  String startDate;
  String chassis;
  String model;
  String km;
  String status;
  String comment;
  //Request In Progress additional data
  String driverName;
  double startLong;
  double startLatt;
  double endLong;
  double endLatt;
  String driverID;


  TruckRequest({id, from, to, reqDate, startDate, chassis, model, km, status, comment, startLong, startLatt, endLong, endLatt,driverName}) {
    this.id = id ?? "0";
    this.from = from ?? "N/A";
    this.to = to ?? "N/A";
    this.reqDate = reqDate ?? "N/A";
    this.startDate = startDate ?? "N/A";
    this.chassis = chassis ?? "N/A";
    this.model = model ?? "N/A";
    this.km = km ?? "N/A";
    this.status = status ?? "N/A";
    this.comment = comment ?? "N/A";
    this.startLong =  (startLong != null) ? double.parse(startLong) : 0;
    this.startLatt =  (startLatt != null) ? double.parse(startLatt) : 0;
    this.endLong =    (endLong != null)   ? double.parse(endLong)   : 0;
    this.endLatt =    (endLatt != null)   ? double.parse(endLatt)   : 0;
    this.driverID = driverID ?? "N/A";
    this.driverName = driverName ?? "N/A";
  }

  TruckRequest.fromJson(Map<String, dynamic> response) {
    try{
    this.id = response['TKRQ_ID'];
    this.from = response['TKRQ_STRT_LOC'] ?? "N/A";
    this.to = response['TKRQ_END_LOC'] ?? "N/A";
    this.reqDate = response['TKRQ_INSR_DATE'] ?? "N/A";
    this.startDate = response['TKRQ_STRT_DATE'] ?? "N/A";
    this.chassis = response['TKRQ_CHSS'] ?? "N/A";
    this.model = response['TRMD_NAME'] ?? "N/A";
    this.km = response['TKRQ_KM'] ?? "N/A";
    this.comment = response['TKRQ_CMNT'] ?? "N/A";
    this.status = response['TKRQ_STTS'] ?? "N/A";
    this.driverName = response['DRVR_NAME'] ?? "N/A";
    this.driverID = response['DRVR_ID'] ?? "N/A";
    this.startLong = double.parse(response['TKRQ_STRT_LONG']) ?? 0;
    this.startLatt = double.parse(response['TKRQ_STRT_LATT']) ?? 0;
    this.endLong = double.parse(response['TKRQ_END_LONG']) ?? 0;
    this.endLatt = double.parse(response['TKRQ_END_LATT']) ?? 0;
    } catch (e){
      return;
    }
  }
}
