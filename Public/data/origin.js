var dependencies = {
    "links": [
        {
            "source": "ConditionalResponse",
            "dest": "< CrossServerFetching >"
        },
        {
            "source": "CrossServerFetcher",
            "dest": "< CrossServerFetching >"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "HeaderKey"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "Tag"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "CustomStringConvertible"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "EmptyNode"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "Body"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "Response"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "Package"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "Droplet"
        },
        {
            "source": "< CrossServerFetching >",
            "dest": "ServerError"
        },
        {
            "source": "DB",
            "dest": "Package"
        },
        {
            "source": "DB",
            "dest": "JSON"
        },
        {
            "source": "DB",
            "dest": "Node"
        },
        {
            "source": "DB",
            "dest": "RedbirdConfig"
        },
        {
            "source": "DB",
            "dest": "Tag"
        },
        {
            "source": "DB",
            "dest": "DependencyGraph"
        },
        {
            "source": "DB",
            "dest": "Redbird"
        },
        {
            "source": "DB",
            "dest": "ServerError"
        },
        {
            "source": "DB",
            "dest": "EmptyNode"
        },
        {
            "source": "DependencyGraph",
            "dest": "< DependencyResolution >"
        },
        {
            "source": "resolve",
            "dest": "< DependencyResolution >"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "Versions"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "ResolvedPackage"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "Context"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "Package"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "Tag"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "Node"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "ServerError"
        },
        {
            "source": "< DependencyResolution >",
            "dest": "NodeConvertible"
        },
        {
            "source": "ServerError",
            "dest": "Dependency"
        },
        {
            "source": "ServerError",
            "dest": "Tag"
        },
        {
            "source": "ServerError",
            "dest": "Error"
        },
        {
            "source": "ServerError",
            "dest": "Versions"
        },
        {
            "source": "Image",
            "dest": "< ImageGenerator >"
        },
        {
            "source": "loadImage",
            "dest": "< ImageGenerator >"
        },
        {
            "source": "< ImageGenerator >",
            "dest": "ResponseRepresentable"
        },
        {
            "source": "< ImageGenerator >",
            "dest": "URL"
        },
        {
            "source": "< ImageGenerator >",
            "dest": "Response"
        },
        {
            "source": "< ImageGenerator >",
            "dest": "Data"
        },
        {
            "source": "providers",
            "dest": "< main >"
        },
        {
            "source": "drop",
            "dest": "< main >"
        },
        {
            "source": "token",
            "dest": "< main >"
        },
        {
            "source": "secretToken",
            "dest": "< main >"
        },
        {
            "source": "db",
            "dest": "< main >"
        },
        {
            "source": "xserver",
            "dest": "< main >"
        },
        {
            "source": "dataSource",
            "dest": "< main >"
        },
        {
            "source": "< main >",
            "dest": "DB"
        },
        {
            "source": "< main >",
            "dest": "CrossServerFetcher"
        },
        {
            "source": "< main >",
            "dest": "resolve"
        },
        {
            "source": "< main >",
            "dest": "ServerDataSource"
        },
        {
            "source": "< main >",
            "dest": "DependencyGraph"
        },
        {
            "source": "< main >",
            "dest": "Tag"
        },
        {
            "source": "< main >",
            "dest": "Env"
        },
        {
            "source": "< main >",
            "dest": "Versions"
        },
        {
            "source": "< main >",
            "dest": "Response"
        },
        {
            "source": "< main >",
            "dest": "Vapor"
        },
        {
            "source": "< main >",
            "dest": "VaporMustache"
        },
        {
            "source": "< main >",
            "dest": "Droplet"
        },
        {
            "source": "< main >",
            "dest": "OutputFormat"
        },
        {
            "source": "< main >",
            "dest": "JSON"
        },
        {
            "source": "< main >",
            "dest": "Version"
        },
        {
            "source": "Version",
            "dest": "< Model >"
        },
        {
            "source": "Versions",
            "dest": "< Model >"
        },
        {
            "source": "Dependency",
            "dest": "< Model >"
        },
        {
            "source": "Package",
            "dest": "< Model >"
        },
        {
            "source": "Tag",
            "dest": "< Model >"
        },
        {
            "source": "ResolvedPackage",
            "dest": "< Model >"
        },
        {
            "source": "< Model >",
            "dest": "JSON"
        },
        {
            "source": "< Model >",
            "dest": "NodeConvertible"
        },
        {
            "source": "< Model >",
            "dest": "ServerError"
        },
        {
            "source": "< Model >",
            "dest": "URLComponents"
        },
        {
            "source": "< Model >",
            "dest": "CustomStringConvertible"
        },
        {
            "source": "< Model >",
            "dest": "Comparable"
        },
        {
            "source": "< Model >",
            "dest": "NodeInitializable"
        },
        {
            "source": "< Model >",
            "dest": "Context"
        },
        {
            "source": "< Model >",
            "dest": "Collection"
        },
        {
            "source": "< Model >",
            "dest": "Node"
        },
        {
            "source": "< Model >",
            "dest": "Hashable"
        },
        {
            "source": "OutputFormat",
            "dest": "Task"
        },
        {
            "source": "OutputFormat",
            "dest": "ServerError"
        },
        {
            "source": "OutputFormat",
            "dest": "Response"
        },
        {
            "source": "OutputFormat",
            "dest": "JSON"
        },
        {
            "source": "OutputFormat",
            "dest": "Image"
        },
        {
            "source": "OutputFormat",
            "dest": "DependencyGraph"
        },
        {
            "source": "TaskResult",
            "dest": "< Scripts >"
        },
        {
            "source": "Task",
            "dest": "< Scripts >"
        },
        {
            "source": "which",
            "dest": "< Scripts >"
        },
        {
            "source": "TaskError",
            "dest": "< Scripts >"
        },
        {
            "source": "< Scripts >",
            "dest": "Data"
        },
        {
            "source": "< Scripts >",
            "dest": "Pipe"
        },
        {
            "source": "< Scripts >",
            "dest": "ProcessInfo"
        },
        {
            "source": "< Scripts >",
            "dest": "Error"
        },
        {
            "source": "< Scripts >",
            "dest": "Foundation"
        },
        {
            "source": "ServerDataSource",
            "dest": "DB"
        },
        {
            "source": "ServerDataSource",
            "dest": "Tag"
        },
        {
            "source": "ServerDataSource",
            "dest": "ServerError"
        },
        {
            "source": "ServerDataSource",
            "dest": "CrossServerFetcher"
        },
        {
            "source": "ServerDataSource",
            "dest": "Package"
        }
    ]
}