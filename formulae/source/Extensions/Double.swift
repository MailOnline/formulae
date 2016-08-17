import Foundation

infix operator ^ { associativity left precedence 160 }
func ^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}
