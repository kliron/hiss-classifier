import Vapor
import PostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register services first
    try services.register(PostgreSQLProvider())

    // Configure the database
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                              port: 5432,
                                              username: "kliron",
                                              database: "hiss",
                                              //password: "",
                                              transport: .cleartext)
    services.register(psqlConfig)    
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // By default serves from `Public` directory
    //middlewares.use(FileMiddleware(publicDirectory: "/Users/kliron/Projects/hiss/classifier/static")) // Needs absolute path
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
