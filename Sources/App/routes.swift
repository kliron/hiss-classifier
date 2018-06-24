import Vapor

public func routes(_ router: Router) throws {
    router.get("values") { req -> [String: [String]] in
        return Values.Values
    }

    // About using params: https://docs.vapor.codes/3.0/getting-started/routing/
    router.get("radiology", "rows") { req -> Future<Int64> in
        try Radiology.getPageCount(on: req)
    }

    router.get("radiology", "rows", "for", Int.parameter) { req -> Future<Int64> in
        try Radiology.getPageCountFor(patientId: try req.parameters.next(Int.self), on: req)
    }

    router.get("radiology", "records", Int.parameter, Int.parameter) { req -> Future<[Radiology]> in
        try Radiology.getPaged(on: req)
    }
    
    router.get("radiology", "records", "for", Int.parameter, Int.parameter, Int.parameter) { req -> Future<[Radiology]> in
        try Radiology.getPagedFor(patientId: try req.parameters.next(Int.self), on: req)
    }
    
    router.get("features", "for", Int.parameter) { req -> Future<RadiologyFeatures> in
        try Radiology.getFeaturesFor(reportUid: try req.parameters.next(Int.self), on: req)
    }
    
    router.get("features", "stroke", "for", Int.parameter) { req -> Future<[StrokeFeature]> in
        try StrokeFeature.getFor(reportUid: try req.parameters.next(Int.self), on: req)
    }
    
    router.get("features", "angio", "for", Int.parameter) { req -> Future<[AngioFeature]> in
        try AngioFeature.getFor(reportUid: try req.parameters.next(Int.self), on: req)
    }
    
    router.get("features", "degenerative", "for", Int.parameter) { req -> Future<[DegenerativeFeature]> in
        try DegenerativeFeature.getFor(reportUid: try req.parameters.next(Int.self), on: req)
    }
    
    /**
     * INSERT
     */
    
    router.post("features", "stroke") { req throws -> Future<RequestResult> in
        try req.content.decode(StrokeFeature.self).flatMap { feature in
            feature.insert(on: req)
        }
    }
    
    router.post("features", "angio") { req throws -> Future<RequestResult> in
        try req.content.decode(AngioFeature.self).flatMap { feature in
            feature.insert(on: req)
        }
    }
    
    router.post("features", "degenerative") { req throws -> Future<RequestResult> in
        try req.content.decode(DegenerativeFeature.self).flatMap { feature in
            feature.insert(on: req)
        }
    }

    /**
     * UPDATE
     */

    router.put("features", "stroke") { req throws -> Future<RequestResult> in
        try req.content.decode(StrokeFeature.self).flatMap { feature in
            feature.update(on: req)
        }
    }
    
    router.put("features", "angio") { req throws -> Future<RequestResult> in
        try req.content.decode(AngioFeature.self).flatMap { feature in
            feature.update(on: req)
        }
    }
    
    router.put("features", "degenerative") { req throws -> Future<RequestResult> in
        try req.content.decode(DegenerativeFeature.self).flatMap { feature in
            feature.update(on: req)
        }
    }
    
    /**
     * DELETE
     */
    router.delete("features", "stroke", Int.parameter) { req throws -> Future<RequestResult> in
        try StrokeFeature.delete(on: req)
    }
    
    router.delete("features", "angio", Int.parameter) { req throws -> Future<RequestResult> in
        try AngioFeature.delete(on: req)
    }
    
    router.delete("features", "degenerative", Int.parameter) { req throws -> Future<RequestResult> in
        try DegenerativeFeature.delete(on: req)
    }
}
