extension Dictionary {
    func map<T>(_ transform: @noescape (key: Key, value: Value) throws -> T) rethrows -> [Key: T] {
        var d: [Key: T] = [:]
        for (key, value) in self {
            d[key] = try transform(key: key, value: value)
        }
        return d
    }
}
