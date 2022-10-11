import Foundation

protocol ViewContainer {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get }
}
