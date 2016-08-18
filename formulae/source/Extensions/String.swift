extension String {
    func tokenized() -> [Token] {
        return tokenize(self.components(separatedBy: " "))
    }
}
