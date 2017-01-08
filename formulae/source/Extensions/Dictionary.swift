extension Dictionary {
    func map<T>(_ transform: (_ key: Key, _ value: Value) throws -> T) rethrows -> [Key: T] {
        var d: [Key: T] = [:]
        for (key, value) in self {
            d[key] = try transform(key, value)
        }
        return d
    }
}
