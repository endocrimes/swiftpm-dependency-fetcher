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

enum ConditionalResponse<T> {
    case notModified
    case newData(T)
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

    private func getPackageContents(name: String, tag: Tag) throws -> String {
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
        guard var node = resp.json?.makeNode() else { throw ServerError.convertFailed }
        node["githubName"] = .string(name)
        return try Package(node: node, in: EmptyNode)
    }
    
    //TODO: automatically delete the key after a certain time
    //so that we don't have to wait for 304 on every single fetch for tags
    func getTags(name: String, etag: String?) throws -> ConditionalResponse<([Tag], String)> {
        let tagsUrl = "https://api.github.com/repos/\(name)/tags"
        //TODO: etag for request & response
        var headers = self.headers
        if let etag = etag {
            headers["If-None-Match"] = etag
        }
        let resp = try drop.getWithRedirect(tagsUrl, headers: headers)
        if resp.status == .notModified {
            return .notModified
        }
        guard let nodes = resp.json?.makeNode().nodeArray else { throw ServerError.failedTags }
        let tags: [Tag] = try nodes.converted()
        let newEtag: String = resp.headers["Etag"]!.string!
        return .newData(tags, newEtag)
    }
}
