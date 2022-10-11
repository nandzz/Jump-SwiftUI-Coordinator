@testable import Context

extension NavigationListTest {

    public enum HomeContextName: Equatable {
        case root
        case viewA
        case viewB
        case viewC
        case viewD
        case viewE
        case viewF
        case viewG
        case viewH
        case viewL
        case viewM
    }

    public enum HomeContextState: ContextState {
        enum HightlightStatus {
            case didFailWithError(error: Error)
        }
    }

    public struct HomeContext: ViewContext {
        typealias ContextName = HomeContextName
        var id: UUID = UUID()
        var name: HomeContextName

        var view: AnyView {
            switch name {
            case .root:
                return AnyView(Text(""))
            case .viewA:
                return AnyView(Text(""))
            case .viewB:
                return AnyView(Text(""))
            }
        }
    }
}
