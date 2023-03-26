import XCTest
@testable import CacheLocality

final class SpatialLocalityTests: XCTestCase {
    var array: [[Int]]!
    let numRows = 10_000
    let numColumns = 10_000

    override func setUp() {
        super.setUp()
        array = Array(repeating: Array(repeating: 0, count: numColumns), count: numRows)
    }

    override func tearDown() {
        array = nil
        super.tearDown()
    }

    func accessArrayRowWise(array: inout [[Int]]) {
        for row in 0..<array.count {
            for column in 0..<array[row].count {
                array[row][column] = row * column
            }
        }
    }

    func accessArrayColumnWise(array: inout [[Int]]) {
        for column in 0..<array[0].count {
            for row in 0..<array.count {
                array[row][column] = row * column
            }
        }
    }

    func testSpatialLocality() {
        var current = CFAbsoluteTimeGetCurrent()
        accessArrayRowWise(array: &array)
        
        print("Contagious caching: ", CFAbsoluteTimeGetCurrent() - current)
        
        
        current = CFAbsoluteTimeGetCurrent()
        accessArrayColumnWise(array: &array)
        
        print("Uncontagious caching: ", CFAbsoluteTimeGetCurrent() - current)
    }
}
