import Vapor

final class AngioFeature: Content, Queryable, RowDecodable {
    var id: Int?
    var eid: Int64
    var pid: Int
    var report_uid: Int64
    var vessel: String
    var side: String
    var finding: String
    
    init(id: Int? = nil,
         eid: Int64,
         pid: Int,
         report_uid: Int64,
         vessel: String,
         side: String,
         finding: String) {
        
        self.id = id
        self.pid = pid
        self.eid = eid
        self.report_uid = report_uid
        self.vessel = vessel
        self.side = side
        self.finding = finding
    }
    
    internal static let selectSql = "SELECT * FROM angio_features WHERE report_uid = $1 ORDER by id"
    internal static let insertSql = "INSERT INTO angio_features (eid, pid, report_uid, vessel, side, finding) VALUES ($1,$2,$3,$4,$5,$6)  RETURNING id"
    internal static let updateSql = "UPDATE angio_features SET vessel = $1, side = $2, finding = $3 WHERE id = $4"
    internal static let deleteSql = "DELETE FROM angio_features WHERE id = $1"
    
    internal func insertParameters() -> [Encodable] {
        return [eid, pid, report_uid, vessel, side, finding,]
    }
    
    internal func updateParameters() -> [Encodable] {
        return [vessel, side, finding,]
    }
}
