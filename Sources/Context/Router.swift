import Foundation
import SwiftUI
import Combine



fileprivate protocol RouterProtocol {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    typealias SequentialNavigation = (context: Context, Presentation)

    var rootPresentation: PresentationContext<Context, State>! { get }
    var currentPresentation: PresentationContext<Context, State>! { get }
    var currentContext: Context { get }
    var contextSequential: [SequentialNavigation]? { get }
    var rootView: AnyView? { get }
    var list: NavigationList<Context, State> { get }
    var state: State? { get set }

    func show(context: Context, mode: Presentation, addNavigationView: Bool)
    func show(contexts: [SequentialNavigation])
    func drop() async
    func drop(to context: Context, completion: (() -> Void)?)
    func showRoot()

    func requestForNext(state: State) async
    func requestForDisappear(state: State) async

    init(root: Context)
}

open class Router<Context: ViewContext, State: ContextState>: RouterProtocol {

    public typealias SequentialNavigation = (context: Context, Presentation)

    let main = DispatchQueue(
        label: "main-context-thread",
        qos: .userInteractive,
        attributes: .initiallyInactive,
        autoreleaseFrequency: .workItem,
        target: .main
    )

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

    ///Context sequential is used in case you need to route to a specific place given an specific condition
    fileprivate var contextSequential: [SequentialNavigation]?

    ///Represents the current State of the Router
    ///This property is set by the View in Wich has the responsibility to set the state of the router
    public var state: State?

    ///The root view controller
    ///The view usually is used when initing the router
    public var rootView: AnyView?

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
        show(context: root, addNavigationView: true)
        main.activate()
    }

    ///This init is used when you want to start the router with sequencial presentation
    /// - Parameters:
    ///    - contexts It takes an array of contexts to be initialized
    convenience public init(routes: [SequentialNavigation]) {
        guard let first = routes.first else {
            fatalError("It has to contain at least one context for the routes")
        }
        self.init(root: first.0)
        self.show(contexts: Array(routes.dropFirst()))
    }

    //MARK: ROUTING FUNCTIONS
    ///This method is called to show a list of contexts in sequence
    ///
    /// - Parameters:
    ///    - contexts It takes an array of contexts to be initialized
    ///    - mode The mode of presentation for the contexts
    public func show(contexts: [SequentialNavigation]) {
//        UIView.setAnimationsEnabled(false)
//        for (index, context) in contexts.enumerated() {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100 * index), execute: {
//                self.show(context: context as! Context, mode: mode)
//            })
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//              UIView.setAnimationsEnabled(true)
//          }
    }

    ///This method is called to show a list of contexts in sequence
    ///
    /// - Parameters:
    ///    - context It takes the context to be shown
    ///    - mode The mode of presentation for the contexts
    public func show(context: Context, mode: Presentation = .push, addNavigationView: Bool = false) {
        let nextPresentation = PresentationContext<Context, State>(current: context, hasNavigation: addNavigationView)

        if rootPresentation == nil {
            self.rootPresentation = nextPresentation
            self.rootView = AnyView(context.view.environmentObject(nextPresentation))
        }

        nextPresentation.onNext.sink { [weak self] stream in
            guard let stream = stream else { return }
            self?.requestForNext(state: stream.state)
        }.store(in: &subscriptions)

        nextPresentation.onDisappear.sink { [weak self] stream in
            guard let stream = stream else { return }
            Task { [weak self] in
                await self?.requestForDisappear(state: stream.state)
            }
        }.store(in: &subscriptions)

        nextPresentation.onCleanStack.sink { [weak self] context in
            guard let stream = context else { return }
            self?.cleanStack(context: stream)
        }.store(in: &subscriptions)

//        nextPresentation.onSequencial.sink { [weak self] stream in
//            guard let state = stream else { return }
//        }.store(in: &subscriptions)

        if currentPresentation == nil {
            self.currentPresentation = nextPresentation
            self.list.appendContext(nextPresentation)
        } else {
            self.list.appendContext(nextPresentation)
            main.async {
                self.currentPresentation?.childView = AnyView(context.view.environmentObject(nextPresentation))
                self.currentPresentation?.childPresentationMode = mode
                self.currentPresentation?.presentChild(true)
                self.currentPresentation = nextPresentation
            }
        }
    }

    ///This method is called to drop to a specific context
    ///
    /// - Parameters:
    ///    - to the specif context you want to drop to
    public func drop(to context: Context, completion: (() -> Void)? = nil) {
        main.async {
            self.list.dropTill(context) { [weak self] current, dismissed  in
                self?.currentPresentation = current
                self?.currentPresentation?.presentChild(false)
                guard let completion = completion else { return }
                if dismissed {
                    self?.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        completion()
                    })
                } else {
                    self?.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        completion()
                    })
                }
            }
        }
    }

    ///This method is called to drop the last context being presented
    public func drop() async {
        await MainActor.run {
                let last = self.list.dropLastContext()
                self.currentPresentation = last
                last?.presentChild(false)

        }
        try! await Task.sleep(nanoseconds: 500_000_000)
    }

    ///This method is called to drop till the root of the router
    public func showRoot() {
        main.async {
            self.list.dropTillHead { [weak self] root in
                self?.currentPresentation = root
            }
        }
    }

    //MARK: CLEAN CONTEXT
    ///These next methods are used in case a view is dismissed without using our API
    ///In this case we have to clean the stack by dropping the last context
    private func cleanStack(context: Context) {
        if currentContext != context {
            cleanDrop(current: context)
        }
    }

    private func cleanDrop(current context: Context) {
        main.async {
            self.list.cleaner(context) { [weak self] context in
                self?.currentPresentation = context
            }
        }
    }

    // MARK: REQUESTS
    
    open func requestForNext(state: State) {
        self.state = state
    }

    open func requestForDisappear(state: State) async {
        self.state = state
    }

    open func requestPop(to context: Context, state: State) {
        self.state = state
    }

    open func requestRoot(state: State) {
        self.state = state
    }

}


public extension Router {

    func onState(_ state: State, do task: () -> Void)  {
        if state == self.state {
            task()
        }
    }

    func after(
        dropTill context: Context,
        goto destionation: Context,
        with presentation: Presentation,
        addNavigationView: Bool = false) {
        drop(to: context) { [weak self] in
            self?.show(
                context: destionation,
                mode: presentation,
                addNavigationView: addNavigationView
            )
        }
    }
}
