import Vapor

final class DegenerativeFeature: Content, Queryable, RowDecodable {
    var id: Int?
    var eid: Int64
    var pid: Int
    var report_uid: Int64
    var cortical_atrophy: String
    var cortical_atrophy_description: String
    var central_atrophy: String
    var microangiopathy: String
    
    init(id: Int? = nil,
         eid: Int64,
         pid: Int,
         report_uid: Int64,
         cortical_atrophy: String,
         cortical_atrophy_description: String,
         central_atrophy: String,
         microangiopathy: String) {
        
        self.id = id
        self.pid = pid
        self.eid = eid
        self.report_uid = report_uid
        self.cortical_atrophy = cortical_atrophy
        self.cortical_atrophy_description = cortical_atrophy_description
        self.central_atrophy = central_atrophy
        self.microangiopathy = microangiopathy
    }
    
    internal static let selectSql = "SELECT * FROM degenerative_features WHERE report_uid = $1 ORDER by id"
    internal static let insertSql = "INSERT INTO degenerative_features (eid, pid, report_uid, cortical_atrophy, cortical_atrophy_description, central_atrophy, microangiopathy) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id"
    internal static let updateSql = "UPDATE degenerative_features SET cortical_atrophy = $1, cortical_atrophy_description = $2, central_atrophy = $3, microangiopathy = $4 WHERE id = $5"
    internal static let deleteSql = "DELETE FROM degenerative_features WHERE id = $1"
    
    internal func insertParameters() -> [Encodable] {
        return [eid, pid, report_uid, cortical_atrophy, cortical_atrophy_description, central_atrophy, microangiopathy,]
    }
    
    public func updateParameters() -> [Encodable] {
        return [cortical_atrophy, cortical_atrophy_description, central_atrophy, microangiopathy, id!]
    }
}
