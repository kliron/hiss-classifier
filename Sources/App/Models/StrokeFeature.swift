import Vapor

final class StrokeFeature: Content, Queryable, RowDecodable {
    var id: Int?
    var eid: Int64
    var pid: Int
    var report_uid: Int64
    var kind: String
    var temporal: String
    var location: String
    var side: String
    var extent: String    
    
    init(id: Int? = nil,
         eid: Int64,
         pid: Int,
         report_uid: Int64,
         kind: String,
         temporal: String,
         location: String,
         side: String,
         extent: String) {
        
        self.id = id
        self.eid = eid
        self.pid = pid
        self.report_uid = report_uid
        self.kind = kind
        self.temporal = temporal
        self.location = location
        self.side = side
        self.extent = extent
    }
    
    internal static let selectSql = "SELECT * FROM stroke_features WHERE report_uid = $1 ORDER by id"
    internal static let insertSql = "INSERT INTO stroke_features (eid, pid, report_uid, kind, temporal, location, side, extent) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING id"
    internal static let updateSql = "UPDATE stroke_features SET kind = $1, temporal = $2, location = $3, side = $4, extent = $5 WHERE id = $6"
    internal static let deleteSql = "DELETE FROM stroke_features WHERE id = $1"
    
    internal func insertParameters() -> [Encodable] {
        return [eid, pid, report_uid, kind, temporal, location, side, extent,]
    }
    
    internal func updateParameters() -> [Encodable] {
        return [kind, temporal, location, side, extent, id!]
    }
}
