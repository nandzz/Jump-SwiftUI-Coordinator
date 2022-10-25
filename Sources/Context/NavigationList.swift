import Foundation
import Combine

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
    private let tracker = Tracker<Context, Status>()
    private let dispatchGroup = DispatchGroup()
    private var debugMode: Bool = true

    var isEmpty: Bool {
        head == nil
    }

    var isNavigating: Bool = false

    var first: Node<Context, Status>? {
        return head
    }

    var last: Node<Context, Status>?  {
        return tail
    }



    func appendContext(_ context: PresentationContext<Context, Status>) {

        dispatchGroup.enter()

        defer {
            dispatchGroup.leave()
        }

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

        dispatchGroup.enter()

        defer {
            dispatchGroup.leave()
        }

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

        if debugMode {
            tracker.trackNavigationList(head: head)
        }

        return current?.value
    }

//    func dropTill(_ context: Context,
//                  onLast: @escaping (_ context: PresentationContext<Context, Status>?, _ dismissed: Bool ) -> Void) {
//
//        dispatchGroup.enter()
//        isNavigating = true
//
//        guard let tail = tail else {
//            return
//        }
//
//        var current = tail
//        var breakWhile = false
//
//        var dismissGroup: [PresentationContext<Context, Status>?] = []
//        var last: PresentationContext<Context, Status>?
//        var dismissed = false
//
//        while (current.previous != nil) {
//            dispatchGroup.enter()
//            let previusMode = current.previous?.value.childPresentationMode
//            if  previusMode == .fullScreen
//                    || previusMode == .sheet
//                    || previusMode == .swap
//                    || previusMode == .top {
//                dismissGroup.append(current.previous?.value)
//                dismissed = true
//            }
//
//            current.previous?.next = nil
//            self.tail = current.previous
//
//            if current.previous?.value.current == context {
//                breakWhile = true
//            }
//
//            last = current.previous?.value
//            current = current.previous!
//
//            if breakWhile {
//                dispatchGroup.leave()
//                break
//            }
//
//            dispatchGroup.leave()
//        }
//
//        for (index, item) in dismissGroup.enumerated() {
//            dispatchGroup.enter()
//            DispatchQueue.main.asyncAfter(
//                deadline: .now() + .milliseconds(Int(index ) * 600)) {
//                    item?.presentChild(false)
//                    self.dispatchGroup.leave()
//                }
//        }
//
//        self.dispatchGroup.leave()
//
//        dispatchGroup.notify(queue: .main) {
//            onLast(last, dismissed)
//            self.isNavigating = false
//        }
//
//        if debugMode {
//            tracker.trackNavigationList(head: head)
//        }
//    }

    func dropTill(_ context: Context,
                  onLast: @escaping (_ context: PresentationContext<Context, Status>?) -> Void) {

        dispatchGroup.enter()
        isNavigating = true

        guard let tail = tail else {
            return
        }

        var current = tail
        var breakWhile = false


        var dismissGroup: [PresentationContext<Context, Status>?] = []

        var subscriptions: [AnyCancellable] = []


        var last: PresentationContext<Context, Status>?

        while (current.previous != nil) {
            dispatchGroup.enter()
            let previusMode = current.previous?.value.childPresentationMode
            if  previusMode == .fullScreen
                    || previusMode == .sheet
                    || previusMode == .swap
                    || previusMode == .top {
//                dispatchGroup.enter()
                current.value.dismissReee()
                current.previous?.value.onChildDisappeared
                    .sink(receiveValue: { disappeared in
                    guard (disappeared != nil) else { return }
//                    self.dispatchGroup.leave()
                })
                .store(in: &subscriptions)
            }

            current.previous?.next = nil
            self.tail = current.previous

            if current.previous?.value.current == context {
                breakWhile = true
            }

            last = current.previous?.value
            current = current.previous!

            if breakWhile {
                dispatchGroup.leave()
                break
            }

            dispatchGroup.leave()
        }

        self.dispatchGroup.leave()

        dispatchGroup.notify(queue: .main) {
            onLast(last)
            self.isNavigating = false
        }

        if debugMode {
            tracker.trackNavigationList(head: head)
        }
    }

    func dropTillHead(onRoot: @escaping (PresentationContext<Context, Status>?) -> Void) {

        dispatchGroup.enter()
        isNavigating = true
        
        guard let tail = tail else {
            return
        }

        var current = tail

        var dismissGroup: [PresentationContext<Context, Status>?] = []

        while (current.previous != nil) {
            dispatchGroup.enter()
            let previusMode = current.previous?.value.childPresentationMode
            if  previusMode == .fullScreen
                    || previusMode == .swap
                    || previusMode == .sheet
                    || previusMode == .top {
                dismissGroup.append(current.previous?.value)
            }
            current.previous?.next = nil
            self.tail = current.previous
            current.previous = nil
            current = self.tail!
            dispatchGroup.leave()
        }

        for (index, item) in dismissGroup.enumerated() {
            dispatchGroup.enter()
            DispatchQueue.main.asyncAfter(
                deadline: .now() + .milliseconds(Int(index ) * 600)) {
                    item?.presentChild(false)
                    self.dispatchGroup.leave()
                }
        }

        dispatchGroup.notify(queue: .main) {
            self.head?.value.presentChild(false)
            onRoot(self.head?.value)
            self.tracker.trackNavigationList(head: self.head)
            self.isNavigating = false
            self.dispatchGroup.leave()
        }

        if debugMode {
            tracker.trackNavigationList(head: head)
        }
    }

    /// This method clean all the context till the `context` parameter
    /// without transitions
    func cleaner(_ context: Context,
                 onLast: @escaping (PresentationContext<Context, Status>?) -> Void) {

        if isNavigating { return }

        dispatchGroup.enter()

        guard let tail = self.tail else {
            return
        }

        var current = tail
        var breakWhile = false

        var last: PresentationContext<Context, Status>?

        while (current.previous != nil) {
            current.previous?.next = nil
            self.tail = current.previous

            if current.previous?.value.current == context {
                last = current.previous?.value
                breakWhile = true
            }

            current = current.previous!

            if breakWhile {
                break
            }
        }

        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main) {
            onLast(last)
            self.tracker.trackNavigationList(head: self.head)
        }
    }

}

