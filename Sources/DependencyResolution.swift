
struct DependencyGraph {
    let root: String
    let relationships: [String: ResolvedPackage]
}

func resolve(
        getPackage: (String, Tag) throws -> Package,
        getTags: (String) throws -> [Tag],
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
        guard let version = tags
            .flatMap({ return try? Version($0) })
            .filter(versions.contains)
            .sorted()
            .last else {
                throw ServerError.dependencyGraphCannotBeSatisfied(versions, tags)
        }
        
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
        print("Resolving \(pkg)")
        resolved[name] = pkg
    }
    
    try visit(name: rootName, versions: versions)
    
    return DependencyGraph(root: rootName, relationships: resolved)
}


