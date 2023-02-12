import Foundation

final class ProfileViewModel {
    var firstRow: [String] = []
    var secondRow: [String] = []
    var thirdRow: [String] = []
    
    init() {
        firstRow = getRandomArray()
        secondRow = getRandomArray()
        thirdRow = getRandomArray()
    }
    
    func getRandomArray() -> [String] {
        var array: [String] = []
        var i = 0
        while i < 100 {
            array.append(String(Int.random(in: 1..<100)))
            i += 1
        }
        return array
    }
}
