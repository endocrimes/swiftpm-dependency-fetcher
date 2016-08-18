import Vapor
import Environment

let drop = Droplet()
let token: String? = Env["GITHUB_BUILDA_TOKEN"]
let xserver = CrossServerFetcher(drop: drop, token: token)

//let name = "czechboy0/Redbird"
let name = "vapor/vapor"
let versions = Versions.all()

do {
    let resolved = try resolve(
                getPackage: { return try xserver.getPackage(name: $0.0, tag: $0.1) },
                getTags: { return try xserver.getTags(name: $0) },
                rootName: name,
                versions: versions
    )
    print(resolved)
    print()
} catch {
    print(error)
}



//try resolve(xserver: xserver, rootName: name)

//drop.get("/dependencies") { req in
//    print("")
//    guard
//        let q = req.query,
//        let name = q["q"].string,
//        !name.isEmpty else { throw ServerError.missingQuery }
//    
//    try xserver.getPackage(name: name)
//    
//    return ""
//}

//drop.serve()
