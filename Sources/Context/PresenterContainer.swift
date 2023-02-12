import Foundation

class PresenterContainer<Path: ContextPath> {

    private var container: [ContextPresenter<Path>] = []

    var isEmpty: Bool {
        return container.isEmpty
    }

    var count: Int {
        return container.count
    }

    var last: ContextPresenter<Path>? {
        return container.last
    }

    var first: ContextPresenter<Path>? {
        return container.first
    }

    var second: ContextPresenter<Path>? {
        return container[1]
    }

    func add(_ presenter: ContextPresenter<Path>) {
        container.append(presenter)
    }

    func removeLast(path: Path) {
        guard !isEmpty else { return }
        if last?.getName() != path {
            while true {
                if container.isEmpty { break }
                if last?.getName() != path {
                    last?.context?.view = nil
                    container.removeLast()
                } else {
                    last?.context?.view = nil
                    container.removeLast()
                    break
                }
            }
        } else {
            container.removeLast()
        }
    }
}
