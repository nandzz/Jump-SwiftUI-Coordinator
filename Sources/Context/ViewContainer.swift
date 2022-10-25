import Foundation
import SwiftUI
import Combine

public protocol ViewContainer: View {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get set }
}

public extension View {
    func routing(mode: Presentation, isChildAppearing: Binding<Bool>, childView: AnyView?, addNavigationView: Bool ) -> some View {
        modifier(PresentationModifier(
            mode: mode,
            isActive: isChildAppearing,
            childView: childView,
            addNavigationView: addNavigationView)
        )
    }
}

public struct PresentationModifier: ViewModifier {

    let mode: Presentation
    var childView: AnyView?
    var isSheetPresented: Binding<Bool>?
    var isFullScreenCover: Binding<Bool>?
    var isNavigating: Binding<Bool>?
    var isAlertPresented: Binding<Bool>?
    var isSwaped: Binding<Bool>?
    let addNavigationView: Bool

    init(mode: Presentation, isActive: Binding<Bool>, childView: AnyView?, addNavigationView: Bool) {
        self.mode = mode
        self.addNavigationView = addNavigationView
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
        if addNavigationView {
            NavigationView {
                ZStack {
                    if (isNavigating != nil) {
                        NavigationLink(
                            String.init(),
                            destination: childView,
                            isActive: isNavigating ?? .constant(false))
                        .isDetailLink(false)
                    }
                    
                    content
                }
            }
            .sheet(isPresented: isSheetPresented ?? .constant(false)) { childView }
            .fullScreenCover(isPresented: isFullScreenCover ?? .constant(false)) { childView }

        } else {
            ZStack {
                content
                    .sheet(isPresented: isSheetPresented ?? .constant(false)) { childView }
                    .fullScreenCover(isPresented: isFullScreenCover ?? .constant(false)) { childView }

                if (isNavigating != nil) {
                    NavigationLink("", destination: childView, isActive: isNavigating ?? .constant(false))
                        .isDetailLink(false)
                }
            }
        }
    }
}
