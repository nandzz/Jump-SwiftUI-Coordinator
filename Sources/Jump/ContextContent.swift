import Foundation
import SwiftUI
import Combine

public struct ContextContent<Path: ContextPath>: View {
    
    @ObservedObject var presenter: ContextPresenter<Path>
    
    public var view: AnyView
    
    public var body: some View {
        presentation.with(navigation: presenter.context?.hasNavigationView ?? false)
    }
    
    private var mode: Presentation {
        presenter.childContext.presentationMode
    }
    
    private var isActive: Bool {
        presenter.childContext.isOnScreenObserver
    }
    
    public init(_ presenter: ContextPresenter<Path>, @ViewBuilder content: ( @escaping (_ path: Path) -> Void) -> some View) {
        self.presenter = presenter
        self.view = AnyView(content({ [weak presenter] path in
            presenter?.next(emit: path)
        }))
    }
    
    @ViewBuilder
    var presentation: some View {
        ZStack {
            view
                .navigationLink(isPresented: Binding(get: {
                    isActive && mode == .push
                }, set: { value in
                    presenter.childContext.isOnScreenObserver = value
                }), content: {
                    presenter.childContext.view
                })
                .swap(isPresented: Binding(get: {
                    isActive && mode == .swap
                }, set: { value in
                    presenter.childContext.isOnScreenObserver = value
                })) {
                    presenter.childContext.view
                }
                .onTop(isPresented: Binding(get: {
                    isActive && mode == .top
                }, set: { value in
                    presenter.childContext.isOnScreenObserver = value
                })) {
                    presenter.childContext.view
                }
            
            Group {
                ZStack {}
                    .fullScreenCover(isPresented: Binding(get: {
                        isActive && mode == .fullScreen
                    }, set: { value, transaction in
                        presenter.childContext.isOnScreenObserver = value
                    })) {
                        presenter.childContext.view
                    }
                
                ZStack {}
                    .sheet(isPresented: Binding(get: {
                        isActive && mode == .sheet
                    }, set: { value in
                        presenter.childContext.isOnScreenObserver = value
                    })) {
                        presenter.childContext.view
                    }
            }
        }
    }
}
