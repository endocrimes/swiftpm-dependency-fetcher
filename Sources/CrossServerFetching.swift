import HTTP
import JSON
import Vapor
import Foundation
import Transport

extension Droplet {
    func getWithRedirect(_ path: String, headers: [HeaderKey : String] = [:], query: [String : CustomStringConvertible] = [:], body: Body = Body.data([])) throws -> Response {
        let response = try client.get(path, headers: headers, query: query, body: body)
        guard response.status == .movedPermanently else { return response }
        guard let location = response.headers["Location"]?.string else {
            throw ServerError.locationHeaderMissing
        }
        return try client.get(location, headers: headers, query: query, body: body)
    }
}

struct CrossServerFetcher {

    let drop: Droplet
    let token: String?
    
    var headers: [HeaderKey: String] {
        var headers: [HeaderKey: String] = [
            "User-Agent": "swift-dependency-fetcher"
        ]
        if let token = token {
            headers["Authorization"] = "Basic " + Array(":\(token)".utf8).base64String
        }
        return headers
    }

    func getPackageContents(name: String, tag: Tag) throws -> String {
        //fetch the package
        let packageUrl = "https://api.github.com/repos/\(name)/contents/Package.swift?ref=\(tag.name)"
        let packageResp = try drop.getWithRedirect(packageUrl, headers: headers)
        guard let json = packageResp.json else { throw ServerError.nonexistentRepo(name) }
        guard let packageContents = json["content"]?.string else {
            throw ServerError.unparsablePackageContents
        }
        
        //decode github's weird newline-separated base64
        let contents = packageContents
            .components(separatedBy: "\n")
            .joined(separator: "")
            .base64DecodedString
        return contents
    }
    
    func getPackage(name: String, tag: Tag) throws -> Package {
        
        let contents = try getPackageContents(name: name, tag: tag)
        
        //get json representation from converter
        let converterUrl = "http://swiftpm.honza.tech/to-json"
        let body: Body = .data(contents.bytes)
        let resp = try drop.client.post(converterUrl, headers: headers, body: body)
        guard let node = resp.json?.makeNode() else { throw ServerError.convertFailed }
        return try Package(node: node, in: Node.object(["githubName": .string(name)]))
    }
    
    func getTags(name: String) throws -> [Tag] {
        let tagsUrl = "https://api.github.com/repos/\(name)/tags"
        let resp = try drop.getWithRedirect(tagsUrl, headers: headers)
        guard let nodes = resp.json?.makeNode().nodeArray else { throw ServerError.failedTags }
        let tags: [Tag] = try nodes.map { try Tag(node: $0, in: EmptyNode) }
        return tags
    }
}
