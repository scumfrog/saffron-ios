import Foundation

struct Ingredient: Codable, Hashable {
    var quantity: Double
    var unit: String
    var name: String

    /// Formatted quantity scaled by `ratio`.
    func formattedQuantity(ratio: Double = 1) -> String {
        let v = quantity * ratio
        if v == 0 { return "" }
        if v >= 10 { return "\(Int(v.rounded()))" }
        let rounded = (v * 10).rounded() / 10
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(rounded))"
            : String(format: "%.1f", rounded)
    }

    /// Human-readable line: "300 g harina de fuerza"
    func displayLine(ratio: Double = 1) -> String {
        let qty = formattedQuantity(ratio: ratio)
        let parts = [qty, unit.isEmpty ? nil : unit, name].compactMap { s -> String? in
            guard let s else { return nil }
            return s.isEmpty ? nil : s
        }
        return parts.joined(separator: " ")
    }
}
