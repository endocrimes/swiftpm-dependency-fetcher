import Vapor
import VaporMustache
import Environment
import HTTP
import JSON
import Foundation

let providers: [Vapor.Provider.Type] = [VaporMustache.Provider.self]

#if os(Linux)
import VaporTLS
let drop = Droplet(client: Client<TLSClientStream>.self, providers: providers)
#else
let drop = Droplet(providers: providers)
#endif

let token: String? = Env["GITHUB_TOKEN"]
let secretToken = token == nil ? "nil" : Array(repeating: "*", count: token!.count).joined(separator: "")
print("GitHub token: \(secretToken)")
let db = try DB(port: 6380)
let xserver = CrossServerFetcher(drop: drop, token: token)
let dataSource = ServerDataSource(local: db, server: xserver)

drop.get("/") { _ in
    let css = "<style>body { padding: 50px; font: 14px \"Lucida Grande\", Helvetica, Arial, sans-serif; } a {color: #00B7FF;}</style>"
    let body = "<html><head>\(css)</head><body><h1>swiftpm-deps.honza.tech</h1><p>See documentation at <a href=\"https://github.com/czechboy0/swiftpm-dependency-fetcher\">github.com/czechboy0/swiftpm-dependency-fetcher</p></h1></body></html>"
    return Response(headers: ["Content-Type":"text/html"], body: body)
}

drop.get("dependencies", String.self, String.self) { req, author, projectName in
    
    let tagString = req.query?["tag"].string
    let formatString = req.query?["format"].string ?? OutputFormat.json.rawValue
    guard let format = OutputFormat(rawValue: formatString) else {
        return try Response(status: .badRequest, json: JSON(["error": "invalid format"]))
    }
    let repoName = [author, projectName].joined(separator: "/").lowercased()

    if .d3 == format {
        //redirect and render
        return try drop.view("d3.mustache", context: [
            "source_link": "/dependencies/\(repoName)?format=d3json"
        ])
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
