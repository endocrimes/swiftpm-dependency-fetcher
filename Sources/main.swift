import Vapor
import Environment

let drop = Droplet()
let token: String? = Env["GITHUB_BUILDA_TOKEN"]
let db = try DB(port: 6380)
let xserver = CrossServerFetcher(drop: drop, token: token)
let dataSource = ServerDataSource(local: db, server: xserver)

//let name = "czechboy0/Redbird"
let name = "vapor/vapor"
let versions = Versions.all()

do {
    let resolved = try resolve(
                getPackage: dataSource.getPackage,
                getTags: dataSource.getTags,
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
