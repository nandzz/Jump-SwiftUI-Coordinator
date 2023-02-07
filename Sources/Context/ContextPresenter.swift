import Foundation
import Combine
import SwiftUI

public protocol ContextIdentifier {
    associatedtype Context: ContextPath
    var name: Context? { get }
}

public protocol Routable: ObservableObject {
    var isOnScreenObserver: Bool { get set }
    var isOnScreen: Binding<Bool> { get }
    var addNavigationView: Bool { get }
    var presentationMode: Presentation { get }
    var view: AnyView? { get }
}

protocol RoutableAction: ObservableObject {
    associatedtype Path: ContextPath

    //MARK: SUBJECTS
    var didDisappear:  CurrentValueSubject<Path?, Never> { get }
    var didAppear: CurrentValueSubject<Path?, Never> { get }
    var next: CurrentValueSubject<Path?, Never> { get }

    //MARK: PUBLISHERS
    var onDisappear:  AnyPublisher<Path?, Never> { get }
    var onAppear: AnyPublisher<Path?, Never> { get }
    var onNext: AnyPublisher<Path?, Never> { get }

    /// Action responsible to call next step for this context after a given action or state
    func next(emit state: Path)
    /// Action responsible to close this context by acting on `isOnScreen` property
    func close()
}

public class Context: ObservableObject, Routable  {

    public var addNavigationView: Bool
    public var presentationMode: Presentation
    public var view: AnyView?

    @Published public var isOnScreenObserver: Bool = false

    private var subscriptions: Set<AnyCancellable> = .init()

    public var isOnScreen: Binding<Bool> {
        Binding { [weak self] in
            self?.isOnScreenObserver ?? false
        } set: { [weak self] value in
            self?.isOnScreenObserver = value
        }
    }

    public required init(
        view: AnyView? = nil,
        addNavigationView: Bool = false,
        presentationMode: Presentation = .idle
    ) {
        self.view = view
        self.addNavigationView = addNavigationView
        self.presentationMode = presentationMode
    }
}


public class ContextPresenter<Path: ContextPath>: ObservableObject, RoutableAction, ContextIdentifier {

    //MARK: - PROPERTIES
    public var name: Path?
    internal var subscriptions: Set<AnyCancellable> = .init()
    @ObservedObject public var context: Context
    @ObservedObject public var childContext: Context

    //MARK: - SUBJECTS
    internal var didDisappear: CurrentValueSubject<Path?, Never> = .init(nil)
    internal var didAppear: CurrentValueSubject<Path?, Never> = .init(nil)
    internal var next: CurrentValueSubject<Path?, Never> = .init(nil)

    //MARK: - OBSERVERS
    public var onNext: AnyPublisher<Path?, Never> {
        next.eraseToAnyPublisher()
    }

    public var onDisappear: AnyPublisher<Path?, Never> {
        didDisappear.eraseToAnyPublisher()
    }

    public var onAppear: AnyPublisher<Path?, Never> {
        didAppear.eraseToAnyPublisher()
    }

    // MARK: - INIT
    public init(with name: Path?, current context: Context, child childContext: Context) {
        self.context = context
        self.childContext = childContext
        self.name = name

        // Here we apply delays depending of Presentation
        context
            .$isOnScreenObserver
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isOnScreen in
                guard let name = self?.name else { return }
                if isOnScreen {
                    self?.didAppear.send(name)
                } else {
                    self?.didDisappear.send(name)
                }
            }
            .store(in: &subscriptions)

        childContext
            .$isOnScreenObserver
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isOnScreen in
                self?.objectWillChange.send()
                self?.childContext.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    // MARK: - ACTIONS
    public func next(emit Path: Path) {
        next.send(Path)
    }

    public func close() {
        DispatchQueue.main.async {
            self.context.isOnScreenObserver = false
        }
    }
}



//
//public class PresentationContext<Context: ViewContext, State: ContextState, Action: ContextAction>:
//        ContextIdentifier,
//        Routable,
//        RoutableAction {
//
//    typealias State = State
//    typealias Action = Action
//
//    public var current: Context
//    public var addNavigationView: Bool
//    public var presentationMode: Presentation
//    public var childView: (any ContextView)?
//
//    required init(current: Context, addNavigationView: Bool, presentationMode: Presentation) {
//        self.current = current
//        self.addNavigationView = addNavigationView
//        self.presentationMode = presentationMode
//    }
//
//    fileprivate var didDisappear: CurrentValueSubject<Context?, Never> = .init(nil)
//    fileprivate var didAppear: CurrentValueSubject<Context?, Never> = .init(nil)
//    fileprivate var nextState: CurrentValueSubject<(context: Context, state: State)?, Never> = .init(nil)
//    fileprivate var nextAction: CurrentValueSubject<(context: Context, action: Action)?, Never> = .init(nil)
//
//
//    internal var onDisappear: AnyPublisher<Context?, Never> {
//        didDisappear.eraseToAnyPublisher()
//    }
//
//    internal var onAppear: AnyPublisher<Context?, Never> {
//        didAppear.eraseToAnyPublisher()
//    }
//
//    internal var onNextAction: AnyPublisher<(context: Context, action: Action)?, Never> {
//        nextAction.eraseToAnyPublisher()
//    }
//
//    internal var onNextState: AnyPublisher<(context: Context, state: State)?, Never> {
//        nextState.eraseToAnyPublisher()
//    }
//
//    public func close() {
//        self.isOnScreenObserver = false
//    }
//
//    public func next(emit state: State) {
//        nextState.send((context: current, state: state))
//    }
//
//    public func next(emit action: Action) {
//        nextAction.send((context: current, action: action))
//    }
//
//}
