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

    //MARK: SUBJECTS
    var next: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var dismiss: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var cleanStack: CurrentValueSubject<Context?, Never> { get }
    var childDisappeared: CurrentValueSubject<Void?, Never> { get }

    //MARK: OBSERVERS
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onDismissRequested: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onCleanStack: AnyPublisher<Context?, Never> { get }
    var onChildDisappeared: AnyPublisher<Void?, Never> { get }


    func next(emit state: State)
    func dismissRequested(emit state: State)
}

extension Routable {
    //MARK: CONCRETE ROUTING - OBSERVERS
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { next.eraseToAnyPublisher() }
    var onDismissRequested: AnyPublisher<(context: Context, state: State)?, Never> { dismiss.eraseToAnyPublisher() }
    var onCleanStack: AnyPublisher<Context?, Never> { cleanStack.eraseToAnyPublisher() }
    var onChildDisappeared: AnyPublisher<Void?, Never> { childDisappeared.eraseToAnyPublisher() }
}

//MARK: - CONCRETE

public class PresentationContext<Context: ViewContext, State: ContextState>: ContextIdentifier, Routable {

    //MARK: CONCRETE CONTEXT - PROPERTIES
    public var current: Context
    public var addNavigationView: Bool = false

    //MARK: CONCRETE ROUTING - SUBJECTS
    internal var next: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var dismiss: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var cleanStack: CurrentValueSubject<Context?, Never>
    internal var childDisappeared: CurrentValueSubject<Void?, Never>

    //MARK: CONCRETE ROUTING - ACTIONS FUNCTIONS
    public func next(emit state: State) { next.send((context: current, state: state)) }
    public func dismissRequested(emit state: State) { dismiss.send((context: current, state: state)) }

    public func removeChild() {
        if requestedDismiss { return }
        childDisappeared.send(())
    }


    //MARK: CONCRETE ROUTING - PROPERTIES
    @Published public var isChildPresented: Bool = false
    @Published public var requestedDismiss = false

    public var childPresentationMode: Presentation = .push
    public var childView: AnyView?

    func presentChild(_ present: Bool) {
        isChildPresented = present
    }

    func dismissReee() {
        print("Requested Dismiss")
        requestedDismiss = true
    }
    

    public required init(current: Context, hasNavigation: Bool) {
        self.current = current
        self.addNavigationView = hasNavigation
        self.next = .init(nil)
        self.dismiss = .init(nil)
        self.cleanStack = .init(nil)
        self.childDisappeared = .init(nil)
    }
}

