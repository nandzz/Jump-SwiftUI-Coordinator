import Foundation
import Combine
import SwiftUI

public class Context: ObservableObject  {

    public var hasNavigationView: Bool
    public var presentationMode: Presentation = .push
    public var view: AnyView?

    @Published public var isOnScreenObserver: Bool = false {
        didSet { 
            self.objectWillChange.send()
        }
    }

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
        presentationMode: Presentation = .push
    ) {
        self.view = view
        self.hasNavigationView = addNavigationView
        self.presentationMode = presentationMode
    }
}


public class ContextPresenter<Path: ContextPath>: ObservableObject {

    //MARK: - PROPERTIES
    private (set) public var name: Path?
    internal var subscriptions: Set<AnyCancellable> = .init()
    public weak var context: Context?
    public var childContext: Context

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
                if !isOnScreen { self?.childContext.view = nil }
                self?.objectWillChange.send()
                self?.childContext.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    // MARK: - ACTIONS
    public func next(emit Path: Path) {
        next.send(Path)
    }

    // MARK: - HELP FUNCTION

    public func getName() -> Path? {
        return name
    }

    public func close() {
        DispatchQueue.main.async {
            self.context?.isOnScreenObserver = false
            self.objectWillChange.send()
        }
    }
}


