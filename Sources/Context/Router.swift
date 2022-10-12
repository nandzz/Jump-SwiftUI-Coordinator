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
    var state: State? { get set }

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


    /// The store of all subscriptions, each context presented has observers of events
    ///
    ///                onNext()
    ///                onRoot()
    ///                onPop()
    ///
    ///This are the observer of each context
    var subscriptions: [AnyCancellable] = []

    /// This property has the rootPresentation Context
    weak internal var rootPresentation: PresentationContext<Context, State>!
    ///This property has the current Presentation Context
    ///instead use the  `currentContext` to know which context the router is presenting
    weak internal var currentPresentation: PresentationContext<Context, State>!

    ///Store the current Context being presented
    ///This property is updated automatically
    ///Use this property to decide the next routing decision
    ///This property is an enum and has to be switched
    ///
    ///             switch currentContext {
    ///                 case .viewA:
    ///                 case .viewB:
    ///                 case .viewD:
    ///             }
    ///
    public var currentContext: Context {
        assert(rootPresentation != nil)
        assert(currentPresentation != nil)
        return currentPresentation.current
    }

    ///Represents the current State of the Router
    ///This property is set by the View in Wich has the responsibility to set the state of the router
    public var state: State?

    ///The root view controller
    ///The view usually is used when initing the router
    var rootView: AnyView?

    //MARK: LIST

    ///The routes are store in the list
    ///This property can't be called from outside, instead use the public properties
    ///
    ///    - show
    ///    - drop (to:)
    ///    - drop
    ///    - showRoot
    ///
    ///By calling these methods the context are automatically added or removed from the list
    internal let list: NavigationList<Context, State> = .init()

    //MARK: INIT

    required public init(root: Context) {
        show(context: root)
    }

    //MARK: HELP FUNCTIONS

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
        self.state = state
    }

    open func onPop(state: State) {
        self.state = state
    }

    open func onPop(to context: Context, state: State) {
        self.state = state
    }

    open func onRoot(state: State) {
        self.state = state
        
    }

}
