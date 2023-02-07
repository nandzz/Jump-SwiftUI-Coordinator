import Foundation
import SwiftUI

public protocol ContextPath: Equatable, Hashable {
    func buildView(presenter: ContextPresenter<Self>) -> AnyView
}
public protocol ContextState: Equatable, Equatable {}
public protocol ContextAction: Equatable, Equatable {}
public protocol ContextData: Equatable, Hashable {}
