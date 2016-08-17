extension Array {
    typealias X = Array.Iterator.Element
    typealias Y = Array.Iterator.Element
    typealias XS = Array

    func deconstructed() -> (X, Y, XS) {

        var a = self
        let x = a.removeFirst()
        let y = a.removeFirst()

        return (x, y, a)
    }
}
