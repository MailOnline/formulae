import Foundation

precedencegroup Additive {
	associativity: left
}

precedencegroup Multiplicative {
	associativity: left
	higherThan: Additive
}

precedencegroup Exponentiative {
	associativity: left
	higherThan: Multiplicative
}

infix operator ^: Exponentiative
func ^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}
