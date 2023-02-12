import Foundation
import SwiftUI

public extension View {

    @ViewBuilder
    /// Extension to swap the view with the content
    func swap<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        if isPresented.wrappedValue {
            content()
        } else {
            self
        }
    }

    @ViewBuilder
    /// Extension used to put a view on top of the another view
    func onTop<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        if isPresented.wrappedValue {
            ZStack {
                self
                content()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        } else {
            self
        }
    }

    @ViewBuilder
    /// Extension to add a navigation link to the view
    func navigationLink<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .background(NavigationLink(
                String.init(),
                destination: content(),
                isActive: isPresented)
                .isDetailLink(false))
    }

    @ViewBuilder
    /// Extension to add a navigation view for the content
    func with(navigation: Bool) -> some View {
        if navigation {
            NavigationView {
                self
            }
        } else {
            self
        }
    }
}
