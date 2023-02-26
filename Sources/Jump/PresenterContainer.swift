import Foundation

class PresenterContainer<Path: ContextPath> {

    private var container: [ContextPresenter<Path>] = []

    var isEmpty: Bool {
        return container.isEmpty
    }

    var last: ContextPresenter<Path>? {
        return container.last
    }

    var count: Int {
        return container.count
    }

    var first: ContextPresenter<Path>? {
        return container.first
    }

    var second: ContextPresenter<Path>? {
        return container[safe: 1]
    }

    func add(_ presenter: ContextPresenter<Path>) {
        container.append(presenter)
    }

    func removeLast(path: Path) {
        guard container.contains(where: { $0.name == path }), !isEmpty else { return }
        if last?.getName() != path {
            while true {
                if container.isEmpty { break }
                if last?.getName() != path {
                    container.removeLast()
                } else {
                    container.removeLast()
                    break
                }
            }
        } else {
            container.removeLast()
        }
    }
    
    func removeTillRoot() -> [ContextPresenter<Path>] {
        var result: [ContextPresenter<Path>?] = container.suffix(from: 2).map {
            guard $0.context?.presentationMode == .fullScreen ||
                    $0.context?.presentationMode == .sheet else { return nil }
            return $0
        }
        result.insert(second, at: 0)
        return result.compactMap { $0 }
    }
}
