import Context
import SwiftUI

enum HomeContext: ViewContext {

    case root
    case viewA
    case viewB
    case viewC
    case viewD
    case viewE
    case viewF
    case viewG
    case viewH
    case viewI
    case viewJ

    var view: AnyView {
        switch self {
        case .root:
            return AnyView(Text(""))
        case .viewA:
            return AnyView(Text(""))
        case .viewB:
            return AnyView(Text(""))
        case .viewC:
            return AnyView(Text(""))
        case .viewD:
            return AnyView(Text(""))
        case .viewE:
            return AnyView(Text(""))
        case .viewF:
            return AnyView(Text(""))
        case .viewG:
            return AnyView(Text(""))
        case .viewH:
            return AnyView(Text(""))
        case .viewI:
            return AnyView(Text(""))
        case .viewJ:
            return AnyView(Text(""))
        }
    }
}
