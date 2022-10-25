import Foundation
import Combine
import SwiftUI

//MARK: - INTERFACE

protocol ContextIdentifier {
    associatedtype Context: ViewContext
    ///Current Context being present
    ///The view on screen
    var current: Context { get }
    var childView: AnyView? { get set }
    ///This property is true in case the view is a rootView or Presented View
    var addNavigationView: Bool { get }
    init(current: Context, hasNavigation: Bool)
}

protocol Routable: ObservableObject {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    var isChildPresented: Bool { get set }
    var childPresentationMode: Presentation { get set }

    var next: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var disappear: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var sequential: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var cleanStack: CurrentValueSubject<Context?, Never> { get }
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onDisappear: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onCleanStack: AnyPublisher<Context?, Never> { get }
    func next(emit state: State)
    func disappear(emit state: State)

    /// This Method should be called in onAppear
    func proceedSequencialIfNeeded(emit state: State)
}

extension Routable {
    //MARK: CONCRETE ROUTING - OBSERVERS
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { next.eraseToAnyPublisher() }
    var onDisappear: AnyPublisher<(context: Context, state: State)?, Never> { disappear.eraseToAnyPublisher() }
    var onSequencial: AnyPublisher<(context: Context, state: State)?, Never> { sequential.eraseToAnyPublisher() }
    var onCleanStack: AnyPublisher<Context?, Never> {
        cleanStack.eraseToAnyPublisher()
    }
}

//MARK: - CONCRETE

public class PresentationContext<Context: ViewContext, State: ContextState>: ContextIdentifier, Routable {

    //MARK: CONCRETE CONTEXT - PROPERTIES
    public var current: Context
    public var addNavigationView: Bool = false

    //MARK: CONCRETE ROUTING - SUBJECTS
    internal var next: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var disappear: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var sequential: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var cleanStack: CurrentValueSubject<Context?, Never>

    //MARK: CONCRETE ROUTING - ACTIONS FUNCTIONS
    public func next(emit state: State) { next.send((context: current, state: state)) }
    public func disappear(emit state: State) { disappear.send((context: current, state: state)) }
    public func proceedSequencialIfNeeded(emit state: State) { sequential.send((context: current, state: state)) }


    //MARK: CONCRETE ROUTING - PROPERTIES
    let lock = NSLock()
    @Published public var isChildPresented: Bool = false {
        didSet {
            if !isChildPresented {
                cleanStack.send(current)
            }
            lock.unlock()
        }
    }

    public var childPresentationMode: Presentation = .push
    public var childView: AnyView?

    func presentChild(_ present: Bool) {
        lock.lock()
        isChildPresented = present
    }

    
    public required init(current: Context, hasNavigation: Bool) {
        self.current = current
        self.addNavigationView = hasNavigation
        self.next = .init(nil)
        self.disappear = .init(nil)
        self.sequential = .init(nil)
        self.cleanStack = .init(nil)
    }
}

