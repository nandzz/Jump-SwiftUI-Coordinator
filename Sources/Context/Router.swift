import Foundation
import Combine

fileprivate protocol RouterProtocol {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    var root: Context { get }
    var current: Context { get }
    var list: NavigationLink<Context, State> { get }

    func next(from context: Context, state: State, mode: Presentation)
    func back(state: State)
    func dropTill(from context: Context, state: State)
    func drop(state: State)
    func dropTillRoot(state: State)

    func onNext(from context: Context, state: State)
    func onBack(from context: Context, state: State)
    func onPop(from context: Context, to: Context, state: State)
    func onRoot(from context: Context, state: State)


    init(root: Context)
}

public class Router<Context: ViewContext, State: ContextState>: RouterProtocol {

    //MARK: SUBSCRIPTIONS
    var subscriptions: [AnyCancellable] = []

    //MARK: CONTEXT
    var root: Context
    var current: Context

    //MARK: LIST
    let list: NavigationLink<Context, State> = .init()


    fileprivate func next(from context: Context, state: State, mode: Presentation) {
        let nextPresentation = PresentationContext<Context, State>(current: root)

        nextPresentation.onNext.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onNext(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onRoot.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onRoot(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onBack.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onBack(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        self.list.appendContext(nextPresentation, mode: mode)
        self.current = context
    }

    fileprivate func back(state: State) {}

    fileprivate func dropTill(from context: Context, state: State) {}

    fileprivate func dropTillRoot(state: State) {}

    fileprivate func drop(state: State) {}


    public func onNext(from context: Context, state: State) {}

    public func onBack(from context: Context, state: State) {}

    public func onPop(from context: Context, to: Context, state: State) {}

    public func onRoot(from context: Context, state: State) {}

    required init(root: Context) {
        self.root = root
        self.current = root

        let nextPresentation = PresentationContext<Context, State>(current: root)

        nextPresentation.onNext.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onNext(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onRoot.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onRoot(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onBack.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onBack(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

    }
}
