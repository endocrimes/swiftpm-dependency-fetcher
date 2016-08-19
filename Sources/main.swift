import Vapor
import Environment
import HTTP
import JSON
import Foundation

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
    
    let tag = req.query?["tag"].string
    let formatString = req.query?["format"].string ?? OutputFormat.json.rawValue
    guard let format = OutputFormat(rawValue: formatString) else {
        return try Response(status: .badRequest, json: JSON(["error": "invalid format"]))
    }
    
    //use passed-in version or use the latest tag
    var versions = Versions.all()
    if let tag = tag {
        do {
            let v = try Version(tag)
            versions = Versions(from: v, to: v)
        } catch {
            return try Response(status: .badRequest, json: JSON(["error": "invalid tag"]))
        }
    }
    
    let repoName = [author, name].joined(separator: "/")
    print("-> \(repoName) : \(format) : \(tag)")
    let resolved = try resolve(
        getPackage: dataSource.getPackage,
        getTags: dataSource.getTags,
        rootName: repoName,
        versions: versions
    )
    
    try! resolved.asDOT().write(toFile: "/Users/honzadvorsky/Documents/swiftpm-dependency-fetcher/v2.gv", atomically: true, encoding: .utf8)
    
    let response = try format.format(graph: resolved)
    return response
}

drop.serve()
