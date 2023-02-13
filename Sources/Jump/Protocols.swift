import Foundation
import SwiftUI

/// Conform to this protocol to create your paths
public protocol ContextPath: Equatable, Hashable {}
/// Conform to this protocol to create your actions
public protocol ContextAction: Equatable, Equatable {}

/// Views have to conform to this protocol
public protocol ContextView: View {
    associatedtype Path: ContextPath
    var presenter: ContextPresenter<Path> { get set }
}
