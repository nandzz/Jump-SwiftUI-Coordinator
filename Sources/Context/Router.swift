import Foundation
import SwiftUI
import Combine

fileprivate protocol RouterProtocol {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    var rootPresentation: PresentationContext<Context, State>! { get }
    var currentPresentation: PresentationContext<Context, State>! { get }
    var currentContext: Context { get }
    var rootView: AnyView? { get }
    var list: NavigationList<Context, State> { get }
    var routingState: State? { get set }

    func show(context: Context, mode: Presentation)
    func drop()
    func drop(to context: Context)
    func showRoot()

    func onNext(state: State)
    func onPop(state: State)
    func onPop(to: Context, state: State)
    func onRoot(state: State)


    init(root: Context)
}

open class Router<Context: ViewContext, State: ContextState>: RouterProtocol {

    //MARK: SUBSCRIPTIONS
    var subscriptions: [AnyCancellable] = []

    //MARK: CONTEXT
    weak internal var rootPresentation: PresentationContext<Context, State>!
    weak internal var currentPresentation: PresentationContext<Context, State>!

    public var currentContext: Context {
        assert(rootPresentation != nil)
        assert(currentPresentation != nil)
        return currentPresentation.current
    }

    //MARK: ROUTING STATUS
    public var routingState: State?

    //MARK: ROOT VIEW
    var rootView: AnyView?

    //MARK: LIST
    let list: NavigationList<Context, State> = .init()

    //MARK: INIT
    required public init(root: Context) {
        show(context: root)
    }

    public func show(context: Context, mode: Presentation = .push) {
        let nextPresentation = PresentationContext<Context, State>(current: context)

        if rootPresentation == nil {
            self.rootPresentation = nextPresentation
            self.rootView = AnyView(context.view.environmentObject(nextPresentation))
        }

        nextPresentation.onNext.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onNext(state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onRoot.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onRoot(state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onBack.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.onPop(state: stream.state)
        }.store(in: &subscriptions)

        if currentPresentation == nil {
            self.currentPresentation = nextPresentation
            self.list.appendContext(nextPresentation)
        } else {
            DispatchQueue.main.async {
                self.currentPresentation?.childView = AnyView(context.view.environmentObject(nextPresentation))
                self.currentPresentation?.isChildPresented = true
                self.currentPresentation?.childPresentationMode = mode
            }
            self.currentPresentation = nextPresentation
            self.list.appendContext(nextPresentation)
        }
    }

    public func drop(to context: Context) {
        list.dropTill(context) { [weak self] current in
            self?.currentPresentation = current
        }
        DispatchQueue.main.async {
            self.currentPresentation?.isChildPresented = false
        }
    }

    public func showRoot() {
        list.dropTillHead { [weak self] root in
            self?.currentPresentation = root
        }
    }

    public func drop() {
        let last = list.dropLastContext()
        self.currentPresentation = last
        DispatchQueue.main.async {
            self.currentPresentation?.isChildPresented = false
        }
    }

    // MARK: ROUTING OBSERVER

    open func onNext(state: State) {
        self.routingState = state
    }

    open func onPop(state: State) {
        self.routingState = state
    }

    open func onPop(to context: Context, state: State) {
        self.routingState = state
    }

    open func onRoot(state: State) {
        self.routingState = state
    }

}
