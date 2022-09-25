import Foundation

protocol ViewContainer {
    associatedtype Context
    var presentationContext: PresentationContextProtocol { get }
}
