import Redbird
import Node
import JSON

extension Node {
    
    func jsonString() throws -> String {
        let json = try JSON.init(node: self, in: EmptyNode)
        let contents = try json.makeBytes().string
        return contents
    }
}

class DB {
    
    private let redbird: Redbird
    
    init(address: String = "127.0.0.1", port: UInt16, password: String? = nil) throws {
        let config = RedbirdConfig(address: address, port: port, password: password)
        self.redbird = try Redbird(config: config)
    }
    
    private func packageKey(name: String, tag: Tag) -> String {
        return "package:\(name):\(tag.name)"
    }
    
    private func tagsKey(name: String) -> String {
        return "tags:\(name)"
    }
    
    private func graphKey(name: String, tag: Tag) -> String {
        return "graph:\(name):\(tag.name)"
    }
    
    private let graphCacheDuration = 60 * 60 * 24 //one day in seconds
    
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
        let contents = try node.jsonString()
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
        let contents = try node.jsonString()
        _ = try redbird.command("SET", params: [key, contents]).toString()
    }
    
    func getResolved(name: String, tag: Tag) throws -> DependencyGraph? {
        let key = graphKey(name: name, tag: tag)
        let resp = try redbird.command("GET", params: [key])
        if resp.respType == .NullBulkString {
            return nil
        }
        let node = try resp
            .toString()
            .json()
            .makeNode()
        let graph: DependencyGraph = try node.converted()
        return graph
    }
    
    func saveResolved(name: String, tag: Tag, graph: DependencyGraph) throws {
        let key = graphKey(name: name, tag: tag)
        let contents = try graph.makeNode().jsonString()
        _ = try redbird.command("SETEX", params: [key, String(graphCacheDuration), contents]).toString()
    }
}
