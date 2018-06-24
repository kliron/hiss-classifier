import NIO
import Vapor
import PostgreSQL

final class RadiologyFeatures : Content {
    var StrokeFeatures: [StrokeFeature]?
    var AngioFeatures: [AngioFeature]?
    var DegenerativeFeatures: [DegenerativeFeature]?
    
    init(strokeFeatures: [StrokeFeature]? = nil,
         angioFeatures: [AngioFeature]? = nil,
         degenerativeFeatures: [DegenerativeFeature]? = nil) {
        self.StrokeFeatures = strokeFeatures
        self.AngioFeatures = angioFeatures
        self.DegenerativeFeatures = degenerativeFeatures
    }
}

final class Radiology: Content, Pageable, RowDecodable {
    var id: Int?
    var pid: Int
    var eid: Int64
    var order_uid: Int64
    var examination: String?
    var request: String?
    var ordered_at: Date
    var discipline: String
    var report_uid: Int64
    var comment: String
    var examination_started_at: Date?
    var report_type: String
    var report: String
    
    init(id: Int? = nil,
        pid: Int,
        eid: Int64,
        order_uid: Int64,
        examination: String?,
        request: String?,
        ordered_at: Date,
        discipline: String,
        report_uid: Int64,
        comment: String,
        examination_started_at: Date?,
        report_type: String,
        report: String) {
        self.id = id
        self.pid = pid
        self.eid = eid
        self.order_uid = order_uid
        self.examination = examination
        self.request = request
        self.ordered_at = ordered_at
        self.discipline = discipline
        self.report_uid = report_uid
        self.comment = comment
        self.examination_started_at = examination_started_at
        self.report_type = report_type
        self.report = report
    }
    
    internal static let selectPagedSql = "SELECT * FROM radiology ORDER BY id ASC LIMIT $1 OFFSET $2"
    internal static let selectPagedForSql = "SELECT * FROM radiology WHERE pid = $1 ORDER BY id ASC LIMIT $2 OFFSET $3"
    
    public static func getFeaturesFor(reportUid rid: Int, on req: Request) throws -> Future<RadiologyFeatures> {
        let future1 = try StrokeFeature.getFor(reportUid: rid, on: req)
                .map(to: RadiologyFeatures.self) { features in
                    RadiologyFeatures(strokeFeatures: features)
                }
        
        let future2 = try AngioFeature.getFor(reportUid: rid, on: req)
                .map(to: RadiologyFeatures.self) { features in
                    RadiologyFeatures(angioFeatures: features)
                }
        
        let future3 = try DegenerativeFeature.getFor(reportUid: rid, on: req)
                .map(to: RadiologyFeatures.self) { features in
                    RadiologyFeatures(degenerativeFeatures: features)
                }
            
        return future1.fold([future2, future3]) { (feat1: RadiologyFeatures, feat2: RadiologyFeatures) -> Future<RadiologyFeatures> in
            req.eventLoop.newSucceededFuture(
                result: RadiologyFeatures(strokeFeatures: feat1.StrokeFeatures ?? feat2.StrokeFeatures,
                                        angioFeatures: feat1.AngioFeatures ?? feat2.AngioFeatures,
                                        degenerativeFeatures: feat1.DegenerativeFeatures ?? feat2.DegenerativeFeatures)
            )
        }
    }
}
