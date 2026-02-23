import Foundation

enum PlateCalculatorService {

    struct PlateBreakdown {
        let plates: [(weight: Double, count: Int)]
        let perSideWeight: Double
        let remainder: Double
    }

    static let plateSizesLbs: [Double] = [45, 35, 25, 10, 5, 2.5]
    static let plateSizesKg: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]

    static func calculatePlates(
        targetWeight: Double,
        barWeight: Double,
        unit: String
    ) -> PlateBreakdown {
        guard targetWeight > barWeight, targetWeight > 0, barWeight > 0 else {
            return PlateBreakdown(plates: [], perSideWeight: 0, remainder: 0)
        }

        let plateSizes = unit == "kg" ? plateSizesKg : plateSizesLbs
        var remaining = (targetWeight - barWeight) / 2.0
        let perSideWeight = remaining
        var plates: [(weight: Double, count: Int)] = []

        for plateWeight in plateSizes {
            let count = Int(remaining / plateWeight)
            if count > 0 {
                plates.append((weight: plateWeight, count: count))
                remaining -= Double(count) * plateWeight
            }
        }

        // Round remainder to avoid floating-point noise
        let remainder = (remaining * 100).rounded() / 100

        return PlateBreakdown(
            plates: plates,
            perSideWeight: perSideWeight - remainder,
            remainder: remainder
        )
    }
}
