import Context

class ExampleRouter: Router<HomeContext, HomeContextState> {

    override func onNext(state: HomeContextState) {
        super.onNext(state: state)
        switch currentContext {
        case .root:
            show(context: .viewA, mode: .push)
        case .viewA:
            show(context: .viewB, mode: .push)
        case .viewB:
            show(context: .viewC, mode: .push)
        case .viewC:
            show(context: .viewD, mode: .push)
        case .viewD:
            show(context: .viewE, mode: .push)
        case .viewE:
            show(context: .viewF, mode: .push)
        case .viewF:
            show(context: .viewG, mode: .push)
        case .viewG:
            show(context: .viewG, mode: .push)
        case .viewH:
            show(context: .viewI, mode: .push)
        case .viewI:
            show(context: .viewJ, mode: .push)
        case .viewJ:
            show(context: .viewH, mode: .push)
        }
    }

    override func onRoot(state: HomeContextState) {
        super.onRoot(state: state)
        showRoot()
    }

    override func onPop(state: HomeContextState) {
        super.onPop(state: state)
        drop()
    }

    override func onPop(to context: HomeContext, state: HomeContextState) {
        super.onPop(to: context, state: state)
        drop(to: context)
    }

    required init(root: HomeContext) {
        super.init(root: root)
    }
}
