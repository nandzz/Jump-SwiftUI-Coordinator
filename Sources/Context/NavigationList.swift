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
            head = Node(value: context)
            tail = head
            return
        }

        let node = Node(value: context)
        node.previous = tail
        tail!.next = node
        self.tail = node
        
        tracker.trackNavigationList(head: head)
    }

    func dropLastContext() -> PresentationContext<Context, Status>? {
        guard let tail = tail else {
            return nil
        }

        guard tail.previous != nil else {
            self.head?.next = nil
            self.head = nil
            self.tail?.previous = nil
            self.tail = nil
            tracker.trackNavigationList(head: head)
            return nil
        }

        let prev = tail.previous
        let current = tail.previous

        prev?.next = nil
        self.tail = prev

        tracker.trackNavigationList(head: head)
        
        return current?.value
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

    func dropTillHead(onRoot: @escaping (PresentationContext<Context, Status>?) -> Void) {

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
            current.previous = nil
            current = self.tail!
        }

        DispatchQueue.main.async {
            self.head?.value.isChildPresented = false
        }

        onRoot(head?.value)

        tracker.trackNavigationList(head: head)
    }

    func addContextList(_ context: [Context] ) {}

}

