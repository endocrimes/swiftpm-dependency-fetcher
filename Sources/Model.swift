import Vapor
import JSON
import Foundation

struct Version: CustomStringConvertible, NodeInitializable, NodeConvertible {
    let major: Int
    let minor: Int
    let patch: Int
    
    static func fromString(_ string: String) throws -> Version {
        let comps = try string.components(separatedBy: ".").flatMap(Int.init)
        guard comps.count == 3 else { throw ServerError.invalidVersion(string) }
        return Version(major: comps[0], minor: comps[1], patch: comps[2])
    }
    
    init(_ string: String) throws {
        self = try Version.fromString(string)
    }
    
    init(major: Int = 0, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init(node: Node, in context: Context) throws {
        guard let str = node.string else {
            throw ServerError.invalidVersion("")
        }
        self = try Version(str)
    }
    
    init(_ tag: Tag) throws {
        self = try Version(tag.name)
    }
    
    var components: [Int] {
        return [major, minor, patch]
    }
    
    var description: String {
        return components.map(String.init).joined(separator: ".")
    }
    
    static func max() -> Version {
        return Version(major: Int.max, minor: Int.max, patch: Int.max)
    }
    
    static func min() -> Version {
        return Version(major: 0, minor: 0, patch: 0)
    }
    
    func makeNode() throws -> Node {
        return .string(description)
    }
}

extension Version: Comparable {
    
    static func ==(lhs: Version, rhs: Version) -> Bool {
        return lhs.description == rhs.description
    }
    
    static func <(lhs: Version, rhs: Version) -> Bool {
        guard lhs.major == rhs.major else {
            return lhs.major < rhs.major
        }
        guard lhs.minor == rhs.minor else {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
}

struct Versions: NodeInitializable, NodeConvertible {
    let from: Version
    let to: Version
    
    init(from: Version, to: Version) {
        self.from = from
        self.to = to
    }
    
    init(node: Node, in context: Context) throws {
        self.from = try node.extract("lowerBound")
        self.to = try node.extract("upperBound")
    }
    
    func contains(version: Version) -> Bool {
        return from <= version && version <= to
    }
    
    static func all() -> Versions {
        return Versions(from: Version.min(), to: Version.max())
    }
    
    static func range(major: Int, minor: Int) -> Versions {
        return Versions(from: Version(major: major, minor: minor, patch: 0), to: Version(major: major, minor: minor, patch: Int.max))
    }
    
    func makeNode() throws -> Node {
        return [
            "lowerBound": try from.makeNode(),
            "upperBound": try to.makeNode()
        ]
    }
}

struct Dependency: NodeInitializable, NodeConvertible {
    let url: String
    let versions: Versions
    
    init(node: Node, in context: Context) throws {
        self.url = try node.extract("url")
        self.versions = try node.extract("version")
    }
    
    func githubName() -> String {
        let comps = URLComponents(string: url.lowercased())!
        #if os(Linux)
        let path = comps.path!
        #else
        let path = comps.path
        #endif
        let pathComps = path
            .characters
            .split(separator: "/", maxSplits: Int.max, omittingEmptySubsequences: true)
            .map(String.init)
        var name = pathComps.joined(separator: "/")
        if name.hasSuffix(".git") {
            name = name.substring(to: name.index(name.endIndex, offsetBy: -4))
        }
        return name
    }
    
    func makeNode() throws -> Node {
        return [
            "url": url.makeNode(),
            "version": try versions.makeNode()
        ]
    }
}

struct Package: NodeInitializable, NodeConvertible {
    let name: String
    let githubName: String
    let dependencies: [Dependency]
    
    init(node: Node, in context: Context) throws {
        self.name = try node.extract("name")
        self.githubName = try node.extract("githubName")
        self.dependencies = try node.extract("dependencies")
    }
    
    func makeNode() throws -> Node {
        return [
            "name": name.makeNode(),
            "githubName": githubName.makeNode(),
            "dependencies": try dependencies.makeNode()
        ]
    }
}

struct Tag: NodeInitializable, NodeConvertible {
    let name: String
    
    init(node: Node, in context: Context) throws {
        self.name = try node.extract("name")
    }
    
    init(name: String) {
        self.name = name
    }
    
    func makeNode() throws -> Node {
        return [
            "name": name.makeNode()
        ]
    }
}

struct ResolvedPackage: NodeConvertible {
    let name: String
    let version: Version
    let dependencies: [String]
    
    init(name: String, version: Version, dependencies: [String]) {
        self.name = name
        self.version = version
        self.dependencies = dependencies
    }
    
    init(node: Node, in context: Context) throws {
        fatalError("Not implemented")
    }
    
    func makeNode() throws -> Node {
        return [
            "name": name.makeNode(),
            "version": try version.makeNode(),
            "dependencies": try dependencies.makeNode()
        ]
    }
}

extension ResolvedPackage: Hashable {
    var hashValue: Int {
        return name.hashValue
    }
    
    static func ==(lhs: ResolvedPackage, rhs: ResolvedPackage) -> Bool {
        return lhs.name == rhs.name
    }
}

extension String {
    
    func json() throws -> JSON {
        return try JSON.init(bytes: Array(self.utf8))
    }
}
