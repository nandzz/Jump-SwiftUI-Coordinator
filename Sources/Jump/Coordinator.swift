import Foundation
import SwiftUI
import Combine


open class Coordinator<Path: ContextPath> {

    private let presenterContainer: PresenterContainer<Path> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    private let main = DispatchQueue.main

    private let viewDisappeared: PassthroughSubject<Void, Never> = .init()
    private let viewAppeared: PassthroughSubject<Void, Never> = .init()
    private var viewDisappearedSubscriptions: AnyCancellable?
    private var viewAppearedSubscriptions: AnyCancellable?
    private var rootContext: Context?
    
    public init() {}

    //MARK: - HELP FUNCTIONS
    /// Method used to load the first context of a flow
    public func load(with path: Path, navigation: Bool) -> AnyView {
        let currentContext = Context(addNavigationView: navigation)
        self.rootContext = currentContext
        let childContext = Context()
        let presenter = ContextPresenter<Path>(with: path, current: currentContext, child: childContext)
        presenterContainer.add(presenter)
        addObservers(for: presenter)
        return buildView(presenter: presenter)
    }

    /// Method used to route a specific context with a given path
    /// - Parameter - path: the specific path to be routed
    /// - Parameter - mode: the presentation style
    /// - Parameter - addNavigation: if `true` the view will be wrapped with a navigation view
    public func present(_ path: Path, mode: Presentation, addNavigation: Bool = false) {
        guard let last = presenterContainer.last else { return }
        let presenter = ContextPresenter(with: path, current: last.childContext, child: Context())
        presenter.context?.presentationMode = mode
        presenter.context?.hasNavigationView = addNavigation
        presenterContainer.add(presenter)
        addObservers(for: presenter)
        main.async { presenter.context?.isOnScreenObserver = true }
        presenter.context?.view = buildView(presenter: presenter)
    }

    /// Dismiss view from the screen
    /// - Parameter - onComplete: called when the dismiss has finished
    public func dismiss(onComplete: (() -> Void)? = nil) {
        viewDisappearedSubscriptions = viewDisappeared
            .first()
            .delay(for: .milliseconds(550), scheduler: DispatchQueue.main)
            .sink { onComplete?() }
        self.presenterContainer.last?.close()
    }

    /// Dismiss to a specific view
    /// - Parameter - path: the specific path to return
    /// - Parameter - onComplete: called when the dismiss has finished
    public func dismiss(to path: Path, onComplete: (() -> Void)? = nil, animated: Bool = true) {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            if self.presenterContainer.isEmpty { timer.invalidate() }
            if self.presenterContainer.last?.getName() != path {
                self.presenterContainer.last?.close()
            } else {
                timer.invalidate()
                onComplete?()
            }
        }.fire()
    }

    /// Dismiss till root view
    public func showRoot(onComplete: (() -> Void)? = nil) {
        viewDisappearedSubscriptions = viewDisappeared
            .first()
            .delay(for: .milliseconds(550), scheduler: DispatchQueue.main)
            .sink { onComplete?() }
        self.presenterContainer.second?.close()
    }

    //MARK: - OBSERVER
    private func addObservers(for presenter: ContextPresenter<Path>) {

        presenter
            .onNext
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onNext(current: path)
            }
            .store(in: &subscriptions)

        presenter
            .onAppear
            .removeDuplicates()
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onAppear(context: path)
                self?.viewAppeared.send()
            }
            .store(in: &subscriptions)

        presenter
            .onDisappear
            .removeDuplicates()
            .sink { [weak self] path in
                guard let path = path else { return }
                self?.onDisappear(context: path)
                self?.viewDisappeared.send(())
            }
            .store(in: &subscriptions)

    }

    //MARK: - OPEN METHODS
    /// This method is called when a presenter is requesting the next context
    ///
    /// - Parameters:
    ///   - context: the context requesting the next context
    open func onNext(current path: Path) {}

    /// You should call super for this method to work properly
    /// This method is called when a view is appearing
    ///
    /// - Parameters:
    ///   - context: the context view appearing
    open func onAppear(context: Path) {}

    /// You should call super for this method to work properly
    /// This method is called right after a view disappears
    ///
    /// - Parameters:
    ///   - context: the context view disappearing
    open func onDisappear(context: Path) {
        print("Dismissed view")
        presenterContainer.removeLast(path: context)
    }

    /// Do not call this method on self
    /// This method is called by the coordinator to create the next view requested based in action conditions
    ///
    /// - Parameters:
    ///   - presenter: the presenter to be injected inside the view
    /// - Returns: AnyView to be placed in your flow
    open func buildView(presenter: ContextPresenter<Path>) -> AnyView {
        fatalError("Do not call this method on self")
    }
}
