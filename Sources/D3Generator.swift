
import JSON

extension DependencyGraph {
    
    func asD3() throws -> String {
        
        struct Arrow: NodeRepresentable {
            let source: String
            let target: String
            
            private func makeNode() throws -> Node {
                return [
                    "source": source.makeNode(),
                    "target": target.makeNode(),
                    "value": String(1.0).makeNode()
                ]
            }
        }
        
        var arrows: [Arrow] = []
        for (name, pkg) in relationships {
            for dep in pkg.dependencies {
                arrows.append(Arrow(source: name, target: dep))
            }
        }
        
        let node = try arrows.makeNode()
        return try node.jsonString()
    }
}

