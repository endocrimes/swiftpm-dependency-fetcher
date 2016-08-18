import Redbird
import Node
import JSON

class DB {
    
    private let redbird: Redbird
    
    init(port: UInt16) throws {
        let config = RedbirdConfig(address: "127.0.0.1", port: port, password: nil)
        self.redbird = try Redbird(config: config)
    }
    
    private func packageKey(name: String, tag: Tag) -> String {
        return "package:\(name):\(tag.name)"
    }
    
    private func tagsKey(name: String) -> String {
        return "tags:\(name)"
    }
    
    func getPackage(name: String, tag: Tag) throws -> Package {
        let key = packageKey(name: name, tag: tag)
        let resp = try redbird.command("GET", params: [key])
        if resp.respType == .NullBulkString {
            //not present yet
            throw ServerError.cacheMiss
        }
        let node = try resp
            .toString()
            .json()
            .makeNode()
        let package = try Package(node: node, in: EmptyNode)
        return package
    }
    
    func savePackage(package: Package, name: String, tag: Tag) throws {
        let key = packageKey(name: name, tag: tag)
        let node = try package.makeNode()
        let json = JSON.init(node: node, in: EmptyNode)
        let contents = try json.makeBytes().string
        _ = try redbird.command("SET", params: [key, contents]).toString()
    }
    
    func getTags(name: String) throws -> ([Tag], String) {
        let key = tagsKey(name: name)
        let resp = try redbird.command("GET", params: [key])
        if resp.respType == .NullBulkString {
            //not present yet
            throw ServerError.cacheMiss
        }
        let node = try resp
            .toString()
            .json()
            .makeNode()
        let etag: String = try node.extract("etag")
        let tagNodes: [Tag] = try node.extract("tagNodes")
        return (tagNodes, etag)
    }
    
    func saveTags(tags: [Tag], name: String, etag: String) throws {
        let key = tagsKey(name: name)
        let node: Node = [
            "etag": etag.makeNode(),
            "tagNodes": try tags.makeNode()
        ]
        let json = JSON.init(node: node, in: EmptyNode)
        let contents = try json.makeBytes().string
        _ = try redbird.command("SET", params: [key, contents]).toString()
    }
}
