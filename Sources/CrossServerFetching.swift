import HTTP
import JSON
import Vapor
import Foundation
import Transport
import TLS

extension Droplet {
    
    func makeClient(scheme: String, host: String) throws -> ClientProtocol {
        let httpClient: ClientProtocol
        if scheme == "https" {
            //TODO: reference file properly
            let certFile = "/Users/honzadvorsky/Documents/swiftpm-dependency-fetcher/Packages/TLS-0.7.0/Certs/mozilla_certs.pem"
            let config: TLS.Config = try Config(
                context: Context(mode: .client),
                certificates: .certificateAuthority(signature: .signedFile(caCertificateFile: certFile))
            )
            let security: SecurityLayer = .tls(config)
            httpClient = try client.init(host: host, port: 443, securityLayer: security)
        } else {
            httpClient = try client.init(host: host, port: 80, securityLayer: .none)
        }
        return httpClient
    }
    
    func getWithRedirect(scheme: String, host: String, path: String, headers: [HeaderKey : String] = [:], query: [String : CustomStringConvertible] = [:], body: Body = Body.data([])) throws -> Response {
        
        let httpClient = try makeClient(scheme: scheme, host: host)
        let response = try httpClient.get(path: path, headers: headers, query: query, body: body)
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
        let host = "api.github.com"
        let path = "/repos/\(name)/contents/Package.swift?ref=\(tag.name)"
        let packageResp = try drop.getWithRedirect(
            scheme: "https",
            host: host,
            path: path,
            headers: headers
        )
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
        let host = "swiftpm.honza.tech"
        let path = "/to-json"
        let body: Body = .data(contents.bytes)
        let resp = try drop
            .makeClient(scheme: "http", host: host)
            .post(path: path, headers: headers, body: body)
        guard var node = resp.json?.makeNode() else { throw ServerError.convertFailed }
        node["githubName"] = .string(name)
        return try Package(node: node, in: EmptyNode)
    }
    
    //TODO: automatically delete the key after a certain time
    //so that we don't have to wait for 304 on every single fetch for tags
    func getTags(name: String, etag: String?) throws -> ConditionalResponse<([Tag], String)> {
        var headers = self.headers
        if let etag = etag {
            headers["If-None-Match"] = etag
        }
        let resp = try drop.getWithRedirect(
            scheme: "https",
            host: "api.github.com",
            path: "/repos/\(name)/tags",
            headers: headers
        )
        if resp.status == .notModified {
            return .notModified
        }
        guard let nodes = resp.json?.makeNode().nodeArray else { throw ServerError.failedTags }
        let tags: [Tag] = try nodes.converted()
        let newEtag: String = resp.headers["Etag"]!.string!
        return .newData(tags, newEtag)
    }
}
