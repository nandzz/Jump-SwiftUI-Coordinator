import XCTest
@testable import Jump
@testable import Mocks

class CoordinatorTests: XCTestCase {

    var sut: TestCoordinatorMock!

    override func setUpWithError() throws {
        sut = TestCoordinatorMock()
    }

    override func tearDownWithError() throws {}

    func test_root_is_loaded() throws {
        _ = sut.load(with: .root, navigation: true)
        XCTAssertEqual(sut.currentPath, .root)
    }

    func test_three_views_are_presented() throws {
        _ = sut.load(with: .root, navigation: true)

        sut.onNext(current: .root)
        sut.onNext(current: .viewA)

        XCTAssertEqual(sut.numberOfContextsPresented, 3)
    }

    func test_currentContext_afterDismiss() throws {
        _ = sut.load(with: .root, navigation: true)

        sut.onNext(current: .root)
        sut.onNext(current: .viewA)
        sut.onNext(current: .viewB)
        sut.onNext(current: .viewC)
        sut.dismiss {
            XCTAssertEqual(self.sut.currentPath, .viewC)
        }
    }

    func test_show_root() throws {
        _ = sut.load(with: .root, navigation: true)

        sut.onNext(current: .root)
        sut.onNext(current: .viewA)
        sut.onNext(current: .viewB)
        sut.onNext(current: .viewC)
        sut.onNext(current: .viewD)
        sut.onNext(current: .viewE)
        sut.onNext(current: .viewF)
        sut.onNext(current: .viewG)
        sut.onNext(current: .viewH)

        sut.showRoot {
            XCTAssertEqual(self.sut.currentPath, .root)
        }
    }
}
