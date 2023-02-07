import Foundation
import SwiftUI
import Combine





class PresenterContainer<Path: ContextPath> {

    private var container: [ContextPresenter<Path>] = []

    var isEmpty: Bool {
        return container.isEmpty
    }

    var last: ContextPresenter<Path>? {
        return container.last
    }

    var first: ContextPresenter<Path>? {
        return container.first
    }

    func add(_ presenter: ContextPresenter<Path>) {
        container.append(presenter)
    }

    func remove(_ presenter: ContextPresenter<Path>) {
        container.removeLast()
    }

    func removeLast() {
        container.removeLast()
    }
}


open class Coordinator<Path: ContextPath> {

    private let presenterContainer: PresenterContainer<Path> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    private let main = DispatchQueue.main


    public init() {}


    //MARK: - HELP FUNCTIONS
    /// Use this method to load the first context of a flow
    public func load(with path: Path, navigation: Bool) -> AnyView {
        let currentContext = Context(addNavigationView: navigation)
        let childContext = Context()
        let presenter = ContextPresenter<Path>(with: path, current: currentContext, child: childContext)
        presenterContainer.add(presenter)
        addObservers(for: presenter)
        return path.buildView(presenter: presenter)
    }

    public func present(view path: Path, mode: Presentation, addNavigation: Bool = false) {
        guard let last = presenterContainer.last else { return }
        let presenter = ContextPresenter(with: path, current: last.childContext, child: Context())
        presenter.context.view = path.buildView(presenter: presenter)
        presenter.context.presentationMode = mode
        presenter.context.addNavigationView = addNavigation
        presenterContainer.add(presenter)
        addObservers(for: presenter)
        last.objectWillChange.send()
        main.asyncAfter(deadline: .now() + 0.1) { presenter.context.isOnScreenObserver = true }
    }

    public func dismiss() {
        main.async { self.presenterContainer.last?.context.isOnScreenObserver = false }
    }

    private func addObservers(for presenter: ContextPresenter<Path>) {

        presenter
            .onNext
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onNext(context: path)
            }
            .store(in: &subscriptions)

        presenter
            .onAppear
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onAppear(context: path)
            }
            .store(in: &subscriptions)

        presenter
            .onDisappear
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onDisappear(context: path)
            }
            .store(in: &subscriptions)

    }

    //MARK: - OBSERVER

    open func onNext(context: Path) {
        print("requesting next")
    }

    open func onAppear(context: Path) {
        print("context \(context) Appeared")
    }

    open func onDisappear(context: Path) {
        presenterContainer.removeLast()
        print("Context \(context) Disappeared")
    }
}



//fileprivate protocol RouterProtocol {
//    associatedtype Context: ViewContext
//    associatedtype State: ContextState
//
//    typealias SequentialNavigation = (context: Context, Presentation)
//
//    var rootPresentation: PresentationContext<Context, State>! { get }
//    var currentPresentation: PresentationContext<Context, State>! { get }
//    var currentContext: Context { get }
//    var contextSequential: [SequentialNavigation]? { get }
//    var rootView: AnyView? { get }
//    var list: NavigationList<Context, State> { get }
//    var state: State? { get set }
//
//    func show(_ context: Context, _ mode: Presentation, addNavigationView: Bool)
//    func show(contexts: [SequentialNavigation])
//    func drop(to context: Context) async
//    func removeChildContextFromList(current context: Context, child: Context)
//
//    func requestForNext(state: State) async
//    func contextDidDisappear(context: Context) async
//
//    init(root: Context)
//}
//
//open class Router<Context: ViewContext, State: ContextState>: RouterProtocol {
//
//    public typealias SequentialNavigation = (context: Context, Presentation)
//
//    let main = DispatchQueue(
//        label: "main-context-thread",
//        qos: .userInteractive,
//        attributes: .initiallyInactive,
//        autoreleaseFrequency: .inherit,
//        target: .main
//    )
//
//    /// The store of all subscriptions, each context presented has observers of events
//    ///
//    ///                onNext()
//    ///                onRoot()
//    ///                onPop()
//    ///
//    ///This are the observer of each context
//    var subscriptions: [AnyCancellable] = []
//
//    /// This property has the rootPresentation Context
//    weak internal var rootPresentation: PresentationContext<Context, State>!
//    ///This property has the current Presentation Context
//    ///instead use the  `currentContext` to know which context the router is presenting
//    weak internal var currentPresentation: PresentationContext<Context, State>!
//
//    ///Store the current Context being presented
//    ///This property is updated automatically
//    ///Use this property to decide the next routing decision
//    ///This property is an enum and has to be switched
//    ///
//    ///             switch currentContext {
//    ///                 case .viewA:
//    ///                 case .viewB:
//    ///                 case .viewD:
//    ///             }
//    ///
//    public var currentContext: Context {
//        assert(rootPresentation != nil)
//        assert(currentPresentation != nil)
//        return currentPresentation.current
//    }
//
//    ///Context sequential is used in case you need to route to a specific place given an specific condition
//    fileprivate var contextSequential: [SequentialNavigation]?
//
//    ///Represents the current State of the Router
//    ///This property is set by the View in Wich has the responsibility to set the state of the router
//    public var state: State?
//
//    ///The root view controller
//    ///The view usually is used when initing the router
//    public var rootView: AnyView?
//
//    //MARK: LIST
//
//    ///The routes are store in the list
//    ///This property can't be called from outside, instead use the public properties
//    ///
//    ///    - show
//    ///    - drop (to:)
//    ///    - drop
//    ///    - showRoot
//    ///
//    ///By calling these methods the context are automatically added or removed from the list
//    internal let list: NavigationList<Context, State> = .init()
//
//    //MARK: INIT
//
//    required public init(root: Context) {
//        show(root, addNavigationView: true)
//        main.activate()
//    }
//
//    ///This init is used when you want to start the router with sequencial presentation
//    /// - Parameters:
//    ///    - contexts It takes an array of contexts to be initialized
//    convenience public init(routes: [SequentialNavigation]) {
//        guard let first = routes.first else {
//            fatalError("It has to contain at least one context for the routes")
//        }
//        self.init(root: first.0)
//        self.show(contexts: Array(routes.dropFirst()))
//    }
//
//    //MARK: ROUTING FUNCTIONS
//    ///This method is called to show a list of contexts in sequence
//    ///
//    /// - Parameters:
//    ///    - contexts It takes an array of contexts to be initialized
//    ///    - mode The mode of presentation for the contexts
//    public func show(contexts: [SequentialNavigation]) {
//
//    }
//
//    ///This method is called to show a list of contexts in sequence
//    ///
//    /// - Parameters:
//    ///    - context It takes the context to be shown
//    ///    - mode The mode of presentation for the contexts
//    public func show(_ context: Context, _ mode: Presentation = .push, addNavigationView: Bool = false)  {
//        let nextPresentation = PresentationContext<Context, State>(current: context, hasNavigation: addNavigationView)
//
//        if rootPresentation == nil {
//            self.rootPresentation = nextPresentation
//            self.rootView = AnyView(context.view.environmentObject(nextPresentation))
//        }
//
//        nextPresentation.onNext.sink { [weak self] stream in
//            guard let stream = stream else { return }
//            Task { [weak self] in
//                await self?.requestForNext(state: stream.state)
//            }
//        }.store(in: &subscriptions)
//
//        nextPresentation.onWillDisappear.sink { [weak self] stream in
//            guard let stream = stream else { return }
//            self?.state = stream
//            Task { [weak self] in
//                await self?.drop()
//            }
//        }.store(in: &subscriptions)
//
//        nextPresentation.onChildContextDidDisappear.sink { [weak self] context in
//            guard let context = context else { return }
//            self?.removeChildContextFromList(
//                current: context.current,
//                child: context.child
//            )
//        }.store(in: &subscriptions)
//
//        if currentPresentation == nil {
//            self.currentPresentation = nextPresentation
//            self.list.appendContext(nextPresentation)
//        } else {
//            self.list.appendContext(nextPresentation)
//            main.async {
//                self.currentPresentation?.childView = AnyView(context.view.environmentObject(nextPresentation))
//                self.currentPresentation?.childContext = context
//                self.currentPresentation?.childPresentationMode = mode
//                self.currentPresentation?.presentChild(true)
//                self.currentPresentation = nextPresentation
//            }
//        }
//    }
//
//    ///This method is called to drop to a specific context
//    ///
//    /// - Parameters:
//    ///    - to the specif context you want to drop to
//    public func drop(to context: Context) async {
//        await withCheckedContinuation {(continuation: CheckedContinuation<Void, Never>) in
//            self.list.dropTill(context) { [weak self] lastContext  in
//                guard let child = lastContext?.childContext else { return }
//                self?.currentPresentation = lastContext
//                Task { [weak self] in
//                    await self?.contextDidDisappear(context: child)
//                }
//                continuation.resume()
//            }
//        }
//    }
//
//    public func drop() async {
//        await MainActor.run {
//            guard let childMode =  list.last?.previous?.value.childPresentationMode else {
//                return
//            }
//            if childMode == .swap || childMode == .top {
//                main.async {
//                    self.list.last?.previous?.value.isChildPresented = false
//                }
//            } else {
//                main.async {
//                    self.list.last?.value.shouldDismiss = true
//                }
//            }
//        }
//    }
//
//    //MARK: CHILD CONTEXT
//    ///These next methods are used in case a view is dismissed without using our API
//    ///In this case we have to clean the stack by dropping the last context
//    fileprivate func removeChildContextFromList(current context: Context, child: Context) {
//        while currentContext != context {
//            let newContext = self.list.dropLastContext()
//            newContext?.childView = nil
//            newContext?.childPresentationMode = .push
//            currentPresentation = newContext
//        }
//        Task {
//            await contextDidDisappear(context: child)
//        }
//    }
//
//    // MARK: REQUESTS
//    open func requestForNext(state: State) async {
//        self.state = state
//    }
//
//    open func contextDidDisappear(context: Context) async {}
//
//}
//
//
//public extension Router {
//
//    func onState(_ state: State, do task: () -> Void)  {
//        if state == self.state {
//            task()
//        }
//    }
//}
