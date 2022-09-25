import Foundation
import Combine

//MARK: - INTERFACE
protocol ContextIdentifier {
    associatedtype Context: ViewContext
    ///Current Context being present
    ///The view on screen
    var current: ViewContext { get }
    var childContext: ViewContext? { get }

    init(current: ViewContext)
}

protocol Routable {
    associatedtype Context: ViewContext
    var isChildPresented: Bool { get set }
    var childPresentationMode: Presentation? { get set }
    var next: CurrentValueSubject<Context?, Never> { get }
    var back: CurrentValueSubject<Context?, Never> { get }
    var root: CurrentValueSubject<Context?, Never> { get }
    var onNext: AnyPublisher<Context?, Never> { get }
    var onBack: AnyPublisher<Context?, Never> { get }
    var onRoot: AnyPublisher<Context?, Never> { get }
    func next(_ context: Context)
    func back(_ current: Context)
    func root(_ context: Context)
}

//MARK: - CONCRETE

class PresentationContext<Context: ViewContext>: ContextIdentifier, Routable {
    typealias Context = Context

    //MARK: CONCRETE CONTEXT - PROPERTIES
    var current: ViewContext
    var childContext: ViewContext?

    //MARK: CONCRETE ROUTING - SUBJECTS
    internal var next: CurrentValueSubject<Context?, Never>
    internal var back: CurrentValueSubject<Context?, Never>
    internal var root: CurrentValueSubject<Context?, Never>

    //MARK: CONCRETE ROUTING - OBSERVERS
    var next: AnyPublisher<Context?, Never> { next.eraseToAnyPublisher() }
    var back: AnyPublisher<Context?, Never> { back.eraseToAnyPublisher() }
    var root: AnyPublisher<Context?, Never> { root.eraseToAnyPublisher() }

    //MARK: CONCRETE ROUTING - ACTIONS FUNCTIONS
    func next(_ context: Context) { next.send(context) }
    func back(_ current: Context) { back.send(current) }
    func root(_ current: Context) { root.send(current) }

    //MARK: CONCRETE ROUTING - PROPERTIES
    var isChildPresented: Bool = false
    var childPresentationMode: Presentation?

    required init(current: ViewContext) {
        self.current = current
        self.next = .init(nil)
        self.back = .init(nil)
        self.root = .init(nil)
    }
}
