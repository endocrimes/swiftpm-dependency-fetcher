import Vapor
import Environment
import HTTP
import JSON
import Foundation

let drop = Droplet()

drop.middleware.append(LoggingMiddleware(app: drop))
drop.middleware.append(TimerMiddleware())

let token: String? = Env["GITHUB_TOKEN"]
let secretToken = token == nil ? "nil" : Array(repeating: "*", count: token!.count).joined(separator: "")
print("GitHub token: \(secretToken)")
let db = try DB(port: 6380)
let xserver = CrossServerFetcher(drop: drop, token: token)
let dataSource = ServerDataSource(local: db, server: xserver)

drop.get("/") { _ in
    return Response(redirect: "/web")
}

drop.get("web") { _ in
    return try drop.view.make("web.html")
}

drop.get("dependencies", String.self, String.self) { req, author, projectName in
    
    let tagString = req.query?["tag"]?.string
    let formatString = req.query?["format"]?.string ?? OutputFormat.json.rawValue
    guard let format = OutputFormat(rawValue: formatString) else {
        return try Response(status: .badRequest, json: JSON(["error": "invalid format"]))
    }
    let repoName = [author, projectName].joined(separator: "/").lowercased()

    switch format {
    case .d3graph:
        return try drop.view.make("d3-graph.leaf", [
            "source_link": "/dependencies/\(repoName)?format=d3graphjson".makeNode()
            ])
    case .d3tree:
        return try drop.view.make("d3-tree.leaf", [
            "source_link": "/dependencies/\(repoName)?format=d3treejson".makeNode()
            ])
    case .d3deps:
        return try drop.view.make("d3-deps.leaf", [
            "source_link": "/dependencies/\(repoName)?format=d3depsjs".makeNode()
            ])
    default: break
    }
    
    //use passed-in version or use the latest tag
    var versions = Versions.all()
    if let tagString = tagString {
        do {
            let v = try Version(tagString)
            versions = Versions(from: v, to: v)
        } catch {
            return try Response(status: .badRequest, json: JSON(["error": "invalid tag"]))
        }
    }
    
    let tags = try dataSource.getTags(name: repoName)
    let version = try tags.latestWithConstraints(versions: versions)
    
    print("-> \(repoName) : \(format) : \(version.description)")
    
    //try cached graph first
    let graph: DependencyGraph
    let tag = Tag(name: version.description)
    if let cached = try db.getResolved(name: repoName, tag: tag) {
        graph = cached
        print("Cache hit")
    } else {
        let resolved = try resolve(
            getPackage: dataSource.getPackage,
            getTags: dataSource.getTags,
            rootName: repoName,
            versions: versions
        )
        try db.saveResolved(name: repoName, tag: tag, graph: resolved)
        graph = resolved
        print("Cache miss")
    }
    
    let response = try format.format(graph: graph)
    return response
}

drop.serve()
