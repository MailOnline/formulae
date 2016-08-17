extension String {
    public func tokenized() -> [Token] {
        return tokenize(self.components(separatedBy: " "))
    }
}
