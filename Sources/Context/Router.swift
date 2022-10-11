import Foundation
import SwiftUI
import Combine

fileprivate protocol RouterProtocol {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    var root: PresentationContext<Context, State>? { get }
    var rootView: AnyView? { get }
    var current: PresentationContext<Context, State>? { get }
    var list: NavigationList<Context, State> { get }
    var routingState: State? { get set }

    func get(context: Context, mode: Presentation)
    func back(state: State)
    func dropTill(from context: Context, state: State)
    func drop(state: State)
    func dropTillRoot(state: State)

    func onNext(from context: Context, state: State)
    func onPop(from context: Context, state: State)
    func onPop(from context: Context, to: Context, state: State)
    func onRoot(from context: Context, state: State)


    init(root: Context)
}

open class Router<Context: ViewContext, State: ContextState>: RouterProtocol {


    //MARK: SUBSCRIPTIONS
    var subscriptions: [AnyCancellable] = []

    //MARK: CONTEXT
    weak public var root: PresentationContext<Context, State>?
    weak public var current: PresentationContext<Context, State>?

    //MARK: ROUTING STATUS
    public var routingState: State?

    //MARK: ROOT VIEW
    var rootView: AnyView?

    //MARK: LIST
    let list: NavigationList<Context, State> = .init()

    //MARK: INIT
    required public init(root: Context) {
        get(context: root)
    }

    public func get(context: Context, mode: Presentation = .push) {

        let nextPresentation = PresentationContext<Context, State>(current: context)

        if root == nil {
            self.root = nextPresentation
            self.rootView = AnyView(context.view.environmentObject(nextPresentation))
        }

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
            self?.onPop(from: stream.context, state: stream.state)
        }.store(in: &subscriptions)

        if current == nil {
            self.current = nextPresentation
            self.list.appendContext(nextPresentation)
        } else {
            DispatchQueue.main.async {
                self.current?.childView = AnyView(context.view.environmentObject(nextPresentation))
                self.current?.isChildPresented = true
                self.current?.childPresentationMode = mode
            }
            self.list.appendContext(nextPresentation)
        }
    }

    public func back(state: State) {}

    public func dropTill(from context: Context, state: State) {}

    public func dropTillRoot(state: State) {}

    public func drop(state: State) {}

    // MARK: ROUTING OBSERVER

    open func onNext(from context: Context, state: State) {
        self.routingState = state
    }

    open func onPop(from context: Context, state: State) {}

    open func onPop(from context: Context, to: Context, state: State) {}

    open func onRoot(from context: Context, state: State) {}

}
