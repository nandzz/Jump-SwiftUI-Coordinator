import Foundation
import Combine
import SwiftUI

//MARK: - INTERFACE

protocol ContextIdentifier {
    associatedtype Context
    ///Current Context being present
    ///The view on screen
    var current: Context { get }
    var childView: AnyView? { get set }
    init(current: Context)
}

protocol Routable: ObservableObject {
    associatedtype Context: ViewContext
    associatedtype State: ContextState

    var isChildPresented: Bool { get set }
    var childPresentationMode: Presentation? { get set }

    var next: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var back: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var root: CurrentValueSubject<(context: Context, state: State)?, Never> { get }
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onBack: AnyPublisher<(context: Context, state: State)?, Never> { get }
    var onRoot: AnyPublisher<(context: Context, state: State)?, Never> { get }
    func next(emit state: State)
    func back(emit state: State)
    func root(emit state: State)
}

extension Routable {
    //MARK: CONCRETE ROUTING - OBSERVERS
    var onNext: AnyPublisher<(context: Context, state: State)?, Never> { next.eraseToAnyPublisher() }
    var onBack: AnyPublisher<(context: Context, state: State)?, Never> { back.eraseToAnyPublisher() }
    var onRoot: AnyPublisher<(context: Context, state: State)?, Never> { root.eraseToAnyPublisher() }
}

//MARK: - CONCRETE

public class PresentationContext<Context: ViewContext, State: ContextState>: ContextIdentifier, Routable {

    //MARK: CONCRETE CONTEXT - PROPERTIES
    var current: Context
    var state: State?

    //MARK: CONCRETE ROUTING - SUBJECTS
    internal var next: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var back: CurrentValueSubject<(context: Context, state: State)?, Never>
    internal var root: CurrentValueSubject<(context: Context, state: State)?, Never>

    //MARK: CONCRETE ROUTING - ACTIONS FUNCTIONS
    public func next(emit state: State) { next.send((context: current, state: state)) }
    public func back(emit state: State) { back.send((context: current, state: state)) }
    public func root(emit state: State) { root.send((context: current, state: state)) }

    //MARK: CONCRETE ROUTING - PROPERTIES
    @Published public var isChildPresented: Bool = false
    @Published public var childPresentationMode: Presentation?
    @Published public var childView: AnyView?

    public required init(current: Context) {
        self.current = current
        self.next = .init(nil)
        self.back = .init(nil)
        self.root = .init(nil)
    }
}

