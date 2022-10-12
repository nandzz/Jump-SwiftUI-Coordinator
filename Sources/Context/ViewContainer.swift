import Foundation
import SwiftUI

public protocol ViewContainer: View {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get set }
}

public extension View {
    func routing(mode: Presentation, isChildAppearing: Binding<Bool>, childView: AnyView? ) -> some View {
        modifier(PresentationModifier(mode: mode, isActive: isChildAppearing, childView: childView))
    }
}

public struct PresentationModifier: ViewModifier {

    let mode: Presentation
    var childView: AnyView?
    var isSheetPresented: Binding<Bool> = .constant(false)
    var isFullScreenCover: Binding<Bool> = .constant(false)
    var isNavigating: Binding<Bool> = .constant(false)
    var isAlertPresented: Binding<Bool> = .constant(false)
    var isSwaped: Binding<Bool> = .constant(false)


    init(mode: Presentation, isActive: Binding<Bool>, childView: AnyView?) {
        self.mode = mode
        self.childView = childView
        switch mode {
        case .push:
            isNavigating = isActive
        case .fullScreen:
            isFullScreenCover = isActive
        case .sheet:
            isSheetPresented = isActive
        case .swap:
            isSwaped = isActive
        default:
            break
        }
    }

    public func body(content: Content) -> some View {
        NavigationLink(destination: childView, isActive: isNavigating) {
            content
                .sheet(isPresented: isSheetPresented) { childView }
                .fullScreenCover(isPresented: isFullScreenCover) { childView }
        }
    }
}
