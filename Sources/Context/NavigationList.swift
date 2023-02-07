//import Foundation
//
//public class Node<Context: ViewContext, Status: ContextState> {
//    var previous: Node<Context, Status>?
//    var next: Node<Context, Status>?
//    var value: PresentationContext<Context, Status>
//
//    init(value: PresentationContext<Context, Status>) {
//        self.value = value
//    }
//}
//
//public class NavigationList<Context: ViewContext, Status: ContextState> {
//
//    private var head: Node<Context, Status>?
//    private var tail: Node<Context, Status>?
//    private let tracker = Tracker<Context, Status>()
//    private let dispatchGroup = DispatchGroup()
//    private var debugMode: Bool = true
//
//    var isEmpty: Bool {
//        head == nil
//    }
//
//    var isNavigating: Bool = false
//
//    var first: Node<Context, Status>? {
//        return head
//    }
//
//    var last: Node<Context, Status>?  {
//        return tail
//    }
//
//    func appendContext(_ context: PresentationContext<Context, Status>) {
//
//        dispatchGroup.enter()
//
//        defer {
//            dispatchGroup.leave()
//        }
//
//        guard !isEmpty else {
//            head = Node(value: context)
//            tail = head
//            return
//        }
//
//        let node = Node(value: context)
//        node.previous = tail
//        tail!.next = node
//        self.tail = node
//
//        tracker.trackNavigationList(head: head)
//    }
//
//    func dropLastContext() -> PresentationContext<Context, Status>? {
//
//        dispatchGroup.enter()
//
//        defer {
//            dispatchGroup.leave()
//        }
//
//        guard let tail = tail else {
//            return nil
//        }
//
//        guard tail.previous != nil else {
//            self.head?.next = nil
//            self.head = nil
//            self.tail?.previous = nil
//            self.tail = nil
//            tracker.trackNavigationList(head: head)
//            return nil
//        }
//
//        let newTail = tail.previous
//        let current = tail
//
//        newTail?.next = nil
//        current.previous = nil
//        self.tail = newTail
//
//        if debugMode {
//            tracker.trackNavigationList(head: head)
//        }
//
//        return newTail?.value
//    }
//
//    func dropTill(_ context: Context,
//                  onLast: @escaping (_ context: PresentationContext<Context, Status>?) -> Void) {
//
//        isNavigating = true
//
//        guard let tail = tail else {
//            return
//        }
//
//        var current = tail
//
//        var last: PresentationContext<Context, Status>?
//
//        while (current.previous != nil) {
//
//            // In case the child context is presented
//            // dispatchEnter
//            // dismiss context
//            // wait for callback signal
//            // free dispatch
//            let previusMode = current.previous?.value.childPresentationMode
//            if  previusMode == .fullScreen
//                    || previusMode == .sheet {
//                dispatchGroup.enter()
//                current.previous?.value.advertiseChildDidDisappear(value: false)
//                current.value.dismiss()
//                current.previous?.value.didFinishDroppingChild = { [weak self] in
//                    self?.dispatchGroup.leave()
//                }
//            }
//
//            // Dispatch waits the previous job
//            dispatchGroup.wait()
//
//            // In case the previous is the last context
//            // dismiss the child context
//            // wait 0.3 seconds for dismiss
//            // free dispatch
//            if current.previous?.value.current == context && current.previous?.value.isChildPresented == true {
//                dispatchGroup.enter()
//                DispatchQueue.main.async {
//                    current.previous?.value.advertiseChildDidDisappear(value: false)
//                    current.value.dismiss()
//                }
//                current.previous?.value.didFinishDroppingChild = { [weak self] in
//                    self?.dispatchGroup.leave()
//                }
//            } else {
//                DispatchQueue.main.async {
//                    current.previous?.value.advertiseChildDidDisappear(value: false)
//                    current.previous?.value.isChildPresented = false
//                }
//            }
//
//            // Dispatch waits the previous job
//            dispatchGroup.wait()
//
//
//            // Clean contexts
//            dispatchGroup.enter()
//
//            guard current.previous != nil else {
//                current.next = nil
//                last = current.value
//                dispatchGroup.leave()
//                break
//            }
//
//            let newTail = current.previous
//
//            newTail?.next = nil
//            current.previous = nil
//
//            self.tail = newTail
//
//            current = newTail!
//            last = newTail?.value
//
//            if newTail?.value.current == context {
//                dispatchGroup.leave()
//                break
//            }
//
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.notify(queue: .main) { [weak self, weak last] in
//            onLast(last)
//            self?.isNavigating = false
//        }
//
//        if debugMode {
//            tracker.trackNavigationList(head: head)
//        }
//    }
//    
//
//    func dropTillHead(onRoot: @escaping (PresentationContext<Context, Status>?) -> Void) {
//
//        dispatchGroup.enter()
//        isNavigating = true
//        
//        guard let tail = tail else {
//            return
//        }
//
//        var current = tail
//
//        var dismissGroup: [PresentationContext<Context, Status>?] = []
//
//        while (current.previous != nil) {
//            dispatchGroup.enter()
//            let previusMode = current.previous?.value.childPresentationMode
//            if  previusMode == .fullScreen
//                    || previusMode == .swap
//                    || previusMode == .sheet
//                    || previusMode == .top {
//                dismissGroup.append(current.previous?.value)
//            }
//            current.previous?.next = nil
//            self.tail = current.previous
//            current.previous = nil
//            current = self.tail!
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
//        dispatchGroup.notify(queue: .main) {
//            self.head?.value.presentChild(false)
//            onRoot(self.head?.value)
//            self.tracker.trackNavigationList(head: self.head)
//            self.isNavigating = false
//            self.dispatchGroup.leave()
//        }
//
//        if debugMode {
//            tracker.trackNavigationList(head: head)
//        }
//    }
//
//    /// This method clean all the context till the `context` parameter
//    /// without transitions
//    func dropContext(_ context: Context,
//                     onLast: @escaping (PresentationContext<Context, Status>?) -> Void) {
//
//        if isNavigating { return }
//
//        dispatchGroup.enter()
//
//        guard let tail = self.tail else {
//            return
//        }
//
//        var current = tail
//        var breakWhile = false
//
//        var last: PresentationContext<Context, Status>?
//
//        while (current.previous != nil) {
//            current.previous?.next = nil
//            self.tail = current.previous
//
//            if current.previous?.value.current == context {
//                last = current.previous?.value
//                breakWhile = true
//            }
//
//            current = current.previous!
//
//            if breakWhile {
//                break
//            }
//        }
//
//        dispatchGroup.leave()
//        dispatchGroup.notify(queue: .main) {
//            onLast(last)
//            self.tracker.trackNavigationList(head: self.head)
//        }
//    }
//
//}
//
