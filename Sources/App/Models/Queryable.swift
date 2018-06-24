import Vapor
import PostgreSQL

struct RequestResult: Content {
    let id: Int?
    let error: String?
    
    init(id: Int? = nil,
         error: String? = nil) {
        self.id = id
        self.error = error
    }
}

protocol RowDecodable {}

extension RowDecodable where Self: Decodable {
    static func from(rows: [[PostgreSQLColumn: PostgreSQLData]]) throws -> [Self] {
        let decoder = PostgreSQLRowDecoder()
        return try rows.map { row in try decoder.decode(Self.self, from: row) }
    }
}

protocol Pageable : class {
    static var selectPagedSql: String { get }
    static var selectPagedForSql: String { get }
}

extension Pageable where Self: Decodable, Self: RowDecodable {
    static func getPaged(on req: Request) throws -> Future<[Self]> {
        let limit = try req.parameters.next(Int.self)
        let offset = try req.parameters.next(Int.self)
        
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(selectPagedSql, [limit, offset])
                .map(to: [Self].self) { rows in
                    return try Self.from(rows: rows)
                }
        }
    }
    
    static func getPagedFor(patientId pid: Int, on req: Request) throws -> Future<[Self]> {
        let limit = try req.parameters.next(Int.self)
        let offset = try req.parameters.next(Int.self)
        
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(selectPagedForSql, [pid, limit, offset,]).map(to: [Self].self) { rows in
                try Self.from(rows: rows)
            }
        }
    }
    
    static func getPageCount(on req: Request) throws -> Future<Int64> {
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            return conn.query("SELECT COUNT(*) AS count FROM radiology").map(to: Int64.self) { rows in
                return try rows[0].firstValue(name: "count")?.decode(Int64.self) ?? -1
            }
        }
    }
    
    static func getPageCountFor(patientId: Int, on req: Request) throws -> Future<Int64> {
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            return conn.query("SELECT COUNT(*) AS count FROM radiology WHERE pid = $1", [patientId]).map(to: Int64.self) { rows in
                return try rows[0].firstValue(name: "count")?.decode(Int64.self) ?? -1
            }
        }
    }
}

protocol Selectable : class {
    static var selectSql: String { get }
}

extension Selectable where Self: Decodable, Self: RowDecodable{
    static func getFor(reportUid rid: Int, on req: Request) throws -> Future<[Self]> {
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(Self.selectSql, [rid]).map(to: [Self].self) { rows in
                try Self.from(rows: rows)
            }
        }
    }
}

protocol Insertable : class {
    static var insertSql: String { get }
    func insertParameters() throws -> [Encodable]
}

extension Insertable where Self: Encodable {
    func insert(on req: Request) -> Future<RequestResult> {
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(Self.insertSql, try self.insertParameters()).map { rows in
                RequestResult(id: try rows[0].firstValue(name: "id")?.decode(Int.self))
            }
        }
    }
}

protocol Updateable : class {
    var id: Int? { get set }
    static var updateSql: String { get }
    func updateParameters() throws -> [Encodable]
}

extension Updateable {
    func update(on req: Request) -> Future<RequestResult> {
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(Self.updateSql, try self.updateParameters()).map { rows in
                RequestResult(id: self.id)
            }
        }
    }
}

protocol Deletable : class {
    static var deleteSql: String { get }
}

extension Deletable {
    static func delete(on req: Request) throws -> Future<RequestResult> {
        let id = try req.parameters.next(Int.self)
        return req.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            return conn.query(Self.deleteSql, [id]).map { _ in
                RequestResult(id: id)
            }
        }
    }
}

typealias Queryable = Selectable & Insertable & Updateable & Deletable
