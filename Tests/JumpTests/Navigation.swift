import XCTest
@testable import Jump
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
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        XCTAssert(sut.currentPresentation?.current == .viewB)
    }

    func test_five_presentations() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        XCTAssert(sut.currentPresentation?.current == .viewE)
    }

    func test_drop_last_context() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        XCTAssertEqual(sut.currentContext, .viewD)
    }

    func test_drop_two_contexts() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        XCTAssertEqual(sut.currentContext, .viewC)
    }

    func test_drop_single_till_root() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_drop_single_till_root_drop_root() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        XCTAssertEqual(sut.currentPresentation?.current, nil)
    }

    func test_drop_till_head_context() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.requestPop(to: .root, state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_drop_till_middle_context() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.requestPop(to: .viewA, state: .idle)
        XCTAssertEqual(sut.currentContext, .viewA)
    }

    func test_drop_till_one_context() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.requestPop(to: .viewD, state: .idle)
        XCTAssertEqual(sut.currentContext, .viewD)
    }


    func test_show_root() throws {
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.requestRoot(state: .idle)
        XCTAssertEqual(sut.currentContext, .root)
    }

    func test_pop_present_cycle() throws {

        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)

        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)
        sut.contextRequestDismiss(state: .idle)

        sut.contextRequestNext(state: .idle)
        sut.contextRequestNext(state: .idle)

        XCTAssertEqual(sut.currentContext, .viewC)

    }

    func test_small_stack_navigation() throws {
        sut = ExampleRouter(routes: [.root, .viewJ, .viewH, .viewF])
        XCTAssertEqual(sut.currentContext, .viewF)
    }

    func test_large_stack_navigation() throws {

        sut = ExampleRouter(routes: [
            .root,
            .viewJ,
            .viewH,
            .viewF,
            .viewJ,
            .viewJ,
            .viewG,
            .viewH,
            .viewA,
            .viewF,
            .viewJ,
            .viewH,
            .viewE,
            .viewF
        ])

        XCTAssertEqual(sut.currentContext, .viewF)
    }
}
