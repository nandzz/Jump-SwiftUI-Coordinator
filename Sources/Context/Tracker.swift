import Foundation

protocol NavigationTrackerProtocol {
    associatedtype Context: ViewContext
    associatedtype State: ContextState
    func trackNavigationList(head: Node<Context, State>?)
    func trackPresentationContext()
    func trackDeallocation()
}

struct Tracker<Context: ViewContext, State: ContextState>: NavigationTrackerProtocol {

    func trackNavigationList(head: Node<Context, State>?) {
        let description: String = {
            var text = "["
            var node = head

            while node != nil {
                text += "\(node!.value.current)"
                node = node!.next
                if node != nil {
                    text += " --> "
                }
            }
            return text + "]"
        }()
        print(description)
    }

    func trackPresentationContext() {}

    func trackDeallocation() {}

}
