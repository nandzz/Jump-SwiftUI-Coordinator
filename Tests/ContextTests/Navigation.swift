import XCTest
@testable import Context
@testable import Mocks

class NavigationTest: XCTestCase {

    var sut: ExampleRouter!

    override func setUpWithError() throws {
        sut = ExampleRouter(root: .root)
    }

    override func tearDownWithError() throws {}

    func test_root_is_presented() throws {
        XCTAssertNotNil(sut.rootView)
        XCTAssert(sut.currentPresentation?.current == .root)
    }

    func test_two_presentations() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        XCTAssert(sut.currentPresentation?.current == .viewB)
    }

    func test_five_presentations() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        XCTAssert(sut.currentPresentation?.current == .viewE)
    }

    func test_drop_last_context() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        XCTAssertEqual(sut.currentContext, .viewD)
    }

    func test_drop_two_contexts() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        XCTAssertEqual(sut.currentContext, .viewC)
    }

    func test_drop_single_till_root() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_drop_single_till_root_drop_root() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        XCTAssertEqual(sut.currentPresentation?.current, nil)
    }

    func test_drop_till_head_context() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(to: .root, state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_drop_till_middle_context() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(to: .viewA, state: .idle)
        XCTAssertEqual(sut.currentContext, .viewA)
    }

    func test_drop_till_one_context() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(to: .viewD, state: .idle)
        XCTAssertEqual(sut.currentContext, .viewD)
    }


    func test_show_root() throws {
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onRoot(state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_pop_present_cycle() throws {

        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)

        sut.onNext(state: .idle)
        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        sut.onPop(state: .idle)
        sut.onPop(state: .idle)
        sut.onPop(state: .idle)

        sut.onNext(state: .idle)
        sut.onNext(state: .idle)

        XCTAssertEqual(sut.currentContext, .viewC)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
