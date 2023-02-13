import Jump
import SwiftUI

class TestCoordinatorMock: Coordinator<TestContextPaths> {

    override func onNext(current path: TestContextPaths) {
        super.onNext(current: path)

        switch path {
        case .root:
            present(.viewA, mode: .push)
        case .viewA:
            present(.viewB, mode: .push)
        case .viewB:
            present(.viewC, mode: .push)
        case .viewC:
            present(.viewD, mode: .push)
        case .viewD:
            present(.viewE, mode: .push)
        case .viewE:
            present(.viewF, mode: .push)
        case .viewF:
            present(.viewG, mode: .push)
        case .viewG:
            present(.viewH, mode: .push)
        case .viewH:
            present(.viewI, mode: .push)
        case .viewI:
            present(.viewJ, mode: .sheet)
        case .viewJ:
            showRoot()
        }
    }

    override func buildView(presenter: ContextPresenter<TestContextPaths>) -> AnyView {
        switch presenter.name {
        case .root,
                .viewA,
                .viewB,
                .viewC,
                .viewD,
                .viewE,
                .viewF,
                .viewG,
                .viewH,
                .viewI,
                .viewJ,
                .none:
            return AnyView(EmptyView())
        }
    }
}
