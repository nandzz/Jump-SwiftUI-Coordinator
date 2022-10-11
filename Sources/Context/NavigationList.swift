import Foundation

public class Node<Context: ViewContext, Status: ContextState> {
    var previous: Node<Context, Status>?
    var next: Node<Context, Status>?
    var value: PresentationContext<Context, Status>

    init(value: PresentationContext<Context, Status>) {
        self.value = value
    }
}

public class NavigationList<Context: ViewContext, Status: ContextState> {

    private var head: Node<Context, Status>?
    private var tail: Node<Context, Status>?

    let tracker = Tracker<Context, Status>()

    var isEmpty: Bool {
        head == nil
    }

    var first: Node<Context, Status>? {
        return head
    }

    var last: Node<Context, Status>?  {
        return tail
    }

    private func push(_ context: PresentationContext<Context, Status>) {
        head = Node(value: context)
        if tail == nil {
            tail = head
        }
    }

    private func pop() -> PresentationContext<Context, Status>? {
        defer {
            head = head?.next
            if isEmpty {
                tail = nil
            }
        }
        return head?.value
    }

    func appendContext(_ context: PresentationContext<Context, Status>) {
        guard !isEmpty else {
            push(context)
            return
        }
        
        tail!.next = Node(value: context)
        tail = tail?.next

        tracker.trackNavigationList(head: head)
    }

    func dropLastContext(_ context: Context) -> PresentationContext<Context, Status>? {
        guard let head = head else {
            return nil
        }

        guard head.next != nil else {
            return pop()
        }

        var prev = head
        var current = head

        while let next = current.next {
            prev = current
            current = next
        }

        prev.next = nil
        tail = prev

        tracker.trackNavigationList(head: head)
        
        return current.previous?.value
    }


    func dropTill(_ context: Context,
                  onLast: @escaping (PresentationContext<Context, Status>?) -> Void) {

        guard let tail = tail else {
            return
        }

        var current = tail
        var breakWhile = false

        while (current.previous != nil) {

            DispatchQueue.main.async {
                current.previous?.value.isChildPresented = false
            }

            current.previous?.next = nil
            self.tail = current.previous

            if current.previous?.value.current == context {
                onLast(current.previous?.value)
                breakWhile = true
            }

            current = current.previous!

            if breakWhile {
                break
            }
        }

        tracker.trackNavigationList(head: head)
    }

    func dropTillHead(_ context: Context, onRoot: @escaping (PresentationContext<Context, Status>?) -> Void) {

        guard let tail = tail else {
            return
        }

        var current = tail

        while (current.previous != nil) {

            DispatchQueue.main.async {
                current.previous?.value.isChildPresented = false
            }

            current.previous?.next = nil
            self.tail = current.previous
            current = tail
        }

        DispatchQueue.main.async {
            self.head?.value.isChildPresented = false
        }

        onRoot(head?.value)

        tracker.trackNavigationList(head: head)
    }

    func addContextList(_ context: [Context] ) {}

}

