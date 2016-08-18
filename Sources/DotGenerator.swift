
extension DependencyGraph {
    
    func asDOT() -> String {
        let spaces = "    "
        var out = "\(spaces)digraph DependenciesGraph {\n"
        out += "\(spaces)\(spaces)node [shape = box]\n"

        //declare packages
        let all = Array(relationships.values)
        for pkg in all {
            out += "\(spaces)\(spaces)\"\(pkg.name)\"[label=\"\(pkg.name)\\n\(pkg.version.description)\"]\n"
        }
        
        //declare relationships
        for pkg in all {
            for dep in pkg.dependencies {
                out += "\(spaces)\(spaces)\"\(pkg.name)\" -> \"\(dep)\"\n"
            }
        }
        
        out += "\(spaces)}\n"
        return out
    }
    
    func saveToFile(path: String) throws {
        try asDOT().write(toFile: path, atomically: true, encoding: .utf8)
    }
}

