import Vapor
import Environment
import HTTP
import JSON


#if os(Linux)
import VaporTLS
let drop = Droplet(client: Client<TLSClientStream>.self)
#else
let drop = Droplet()
#endif

let token: String? = Env["GITHUB_TOKEN"]
print("GitHub token: \(token)")
let db = try DB(port: 6380)
let xserver = CrossServerFetcher(drop: drop, token: token)
let dataSource = ServerDataSource(local: db, server: xserver)

//let name = "czechboy0/Redbird"
//let name = "vapor/vapor"
//let versions = Versions.all()
//do {
//    let resolved = try resolve(
//                getPackage: dataSource.getPackage,
//                getTags: dataSource.getTags,
//                rootName: name,
//                versions: versions
//    )
//    print(resolved)
//    print()
//} catch {
//    print(error)
//}

drop.get("dependencies", String.self, String.self) { req, author, name in
    
    let formatString = req.query?["format"].string ?? OutputFormat.json.rawValue
    guard let format = OutputFormat(rawValue: formatString) else {
        return try Response(status: .badRequest, json: JSON(["error": "invalid format"]))
    }
    
    let repoName = [author, name].joined(separator: "/")
    let resolved = try resolve(
        getPackage: dataSource.getPackage,
        getTags: dataSource.getTags,
        rootName: repoName,
        versions: Versions.all()
    )
    
    let response = try format.format(graph: resolved)
    return response
}

drop.serve()
