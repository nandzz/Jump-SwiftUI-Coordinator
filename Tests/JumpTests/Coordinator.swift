import XCTest
@testable import Jump
@testable import Mocks

class CoordinatorTests: XCTestCase {
    
    var sut: TestCoordinatorMock!
    
    override func setUp()  {
        sut = TestCoordinatorMock()
    }
    
    func test_root_is_loaded() throws {
        _ = sut.load(with: .root, navigation: true)
        XCTAssertEqual(sut.currentPath, .root)
    }
    
    func test_three_views_are_presented() {
        _ = sut.load(with: .root, navigation: true)
        
        sut.onNext(current: .root)
        sut.onNext(current: .viewA)
        
        XCTAssertEqual(sut.numberOfContextsPresented, 3)
    }
    
    func test_currentContext_afterDismiss() {
        _ = sut.load(with: .root, navigation: true)
        
        sut.onNext(current: .root)
        sut.onNext(current: .viewA)
        sut.onNext(current: .viewB)
        sut.onNext(current: .viewC)
        sut.dismiss {
            XCTAssertEqual(self.sut.currentPath, .viewC)
        }
    }
    
    func test_show_root() {
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
    
    func test_dismiss_to() {
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
        
        sut.dismiss(to: .viewE) {
            XCTAssertEqual(self.sut.currentPath, .viewE)
        }
    }
    
    func test_show_root_and_present_after_root_appears() {
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
        
        sut.showRoot() {
            self.sut.present(.viewD, mode: .sheet)
            XCTAssertEqual(self.sut.currentPath, .viewD)
        }
    }
    
    func test_dismiss_to_and_present_after_dismiss() {
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
        
        sut.dismiss(to: .viewE) {
            self.sut.present(.viewB, mode: .sheet)
            XCTAssertEqual(self.sut.currentPath, .viewB)
        }
    }
}
