import Node

struct DependencyGraph: NodeConvertible {
    let root: String
    let relationships: [String: ResolvedPackage]
    
    init(root: String, relationships: [String: ResolvedPackage]) {
        self.root = root
        self.relationships = relationships
    }
    
    init(node: Node, in context: Context) throws {
        self.root = try node.extract("root")
        self.relationships = try node.extract("relationships")
    }
    
    func makeNode() throws -> Node {
        return [
            "root": root.makeNode(),
            "relationships": try relationships.makeNode()
        ]
    }
}

func resolve(
        getPackage: @escaping (String, Tag) throws -> Package,
        getTags: @escaping (String) throws -> [Tag],
        rootName: String,
        versions: Versions = Versions.all()
    ) throws -> DependencyGraph {
    
    var resolved: [String: ResolvedPackage] = [:]
    
    func visit(name: String, versions: Versions) throws {
        
        guard resolved[name] == nil else {
            //already visited, skip
            return
        }
        
        //get version
        let tags = try getTags(name)
        let version = try tags.latestWithConstraints(versions: versions)
        
        //get package
        let package = try getPackage(name, Tag(name: version.description))
        
        //iterate over its dependencies
        var deps: Set<String> = []
        try package.dependencies.forEach { dep in
            //add and visit
            let name = dep.githubName()
            deps.insert(name)
            
            //check if it's in the resolved list
            if let resolvedDep = resolved[name] {
                //ensure it matches our requirements
                guard dep.versions.contains(version: resolvedDep.version) else {
                    throw ServerError.dependencyGraphConflict(dep, resolvedDep.version.description)
                }
                return
            }
            
            //visit
            try visit(name: name, versions: dep.versions)
        }
        
        //create a new resolved package
        let pkg = ResolvedPackage(name: name, version: version, dependencies: Array(deps))
        resolved[name] = pkg
    }
    
    try visit(name: rootName, versions: versions)
    
    return DependencyGraph(root: rootName, relationships: resolved)
}


