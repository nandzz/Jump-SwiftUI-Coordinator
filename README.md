# Jump 🐒

[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg?style=for-the-badge&logo=swift&logoColor=black)](https://developer.apple.com/xcode/swiftui)
[![Swift](https://img.shields.io/badge/Swift-5.6-orange.svg?style=for-the-badge&logo=swift)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-14.2-blue.svg?style=for-the-badge&logo=Xcode&logoColor=white)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/license-MIT-black.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)


## Description

<sub> A simple way to coordinate flows in an App </sub>

![Jump-SwiftUI-Coordinator](https://user-images.githubusercontent.com/75216897/221434358-41ce5cc2-68ef-4c1d-a29c-2f8438e7aa82.png)

<br>

### Features

* Embedded Router
* Action based decision
* Content Wrapper
* Built for Injection 

### More about

- Advisable to use with MVVM
- Built to simplify navigation decisions
- Unit tested / UI tested

<br>

### UITests

> UITest repository: [Jump UITests](https://github.com/nandzz/Jump---SwiftUI-Coordinator-UITests)

<br>


## Tutorial

* [Installation](#installation-)
* [Define Paths](#definepaths-)
* [Create the Coordinator](#createthecoordinator-)
* [Create Views](#createviews-)
* [Create Actions](#createactions-)
* [Take decisions](#takedecisions-)
* [What to Improve / Open Points](#whattoimprove/openpoints-)

## Installation ⚙️

In Xcode, add the dependency to your project via File > Add Packages > Search or Enter Package URL and use the following URL:

```
https://github.com/nandzz/Jump-SwiftUI-Coordinator
```

Once added, import the package in your code:
```swift
import SwiftUIRouter
```

### Define Paths 🚙

Every flow has its given paths ( the view’s routing name ), so a path corresponds to a View. But what are these paths? If inside an App we have a section called Profile, this section can contain many paths:

```
Profile {
  root
  changePicture
  settings
  editBio
  badges
}
```

Here is how you create these paths for **Jump** by using an enum. 
The enum has to conform to ContextPath and can be called with the name of your choice. 

```swift
enum ProfilePaths: ContextPath {
    case root
    case changePicture
    case settings
    case editBio
    case badges
}
```

### Create the Coordinator 🤟

The coordinator has to conform to **Coordinator** Type and its associated paths ( the type we just have created in the section above )

```swift
class ProfileCoordinator: Coordinator<ProfilePaths> {}
```

### Create Views 📺

Each view using jump has to conform to `ContextView`
Here is how to declare the View:

> You can avoid to write the typealias by declaring directly the presenter as below

```swift
struct ContentView: ContextView {
    
   var presenter: ContextPresenter<ProfilePaths>

    var body: some View {
        ContextContent<ProfilePaths>(presenter) { dispatch in
            // Use ContextContent to wrap your view passing the paths you created
            // to its generic type and initialising it with the presenter injected. 
        }
    }
}
```

### Create Actions 👨‍💻

Every view has its actions. Taking the example of the Profile section we can have the following actions for the root view

* didTapOnChangePicture
* didTapOnSettings
* didTapOnEditBio
* didTapOnBadges
* didTapOnDismiss
* dismissAfterError
* viewModelDidProduceWarning
* idle

> Actions can also be consequences of state changes in the viewModel (ex. Network Error, API Call succeeded)

:warning: **You always need to have an idle action inside the enum**

Here is an example of how to define the profile actions:


```swift
public enum ProfileRootActions: ContextAction {
    case idle
    // Actions from interaction 
    case didTapOnChangePicture
    case didTapOnSettings
    case didTapOnEditBio
    case didTapOnBadges

    // Actions from state change
    case dismissAfterError(error:)
    case viewModelDidProduceWarning
}
```

> Piece of Adivise:  declate these actions over the declarion of the view, so they can be easily be found. 

> The actions has to conform to **Equatable** and **Hashable** as well as any associated information that will be sent to the coordinator using associated types. You can conform the actions directly to ContextAction that implements **Equatable** and **Hashable** protocols.


## Take decisions 🚦

### `Give Actions to the Paths`

Previously we have declared the paths for the Profile with an enum. Now we gonna give actions to each one of these paths. 

**Remember:** Each View has its path and action defined. You have to associate the actions with the path:

```swift
enum ProfilePaths: ContextPath {
    case root(ProfileRootActions)
    case changePicture(ProfileChangePictureActions = .idle)
    case settings(ProfileSettingsActions = .idle)
    case editBio(ProfileEditBioActions = .idle)
    case badges(ProfileBadgesActions = .idle)
}
```

> By Having an idle action inside the enum of actions we are able to init the path without a given action.

### `Dispatch the actions`

Now from the view we can dispatch actions to the coordinator 


```swift

class ProfileRootViewModel: ObservableObject {
    
    enum Status {
        case error
        case warning
        case ready
    }
    
    var status: Status = .ready
}

struct ProfileRootView: ContextView {
   
    var presenter: ContextPresenter<ProfilePaths>
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        ContextContent<ProfilePaths>(presenter) { dispatch in
            VStack {
                Button("Edit Bio") {
                    dispatch(.root(.didTapOnEditBio))
                }
                
                Button("Settings") {
                    dispatch(.root(.didTapOnSettings))
                }
            }
            .onChange(of: viewModel.status) { status in
                switch status {
                case .error:
                    dispatch(.root(.dismissAfterError))
                case .warning:
                    dispatch(.root(.viewModelDidProduceWarning))
                case .ready:
                    break
                }
            }
        }
    }
}

```


> The actions can be from interactions or viewModel state changes

### `Handle the Actions`

The coordinator can be easily understood. You receive a routing request from the view and this request comes with an action and eventually data associated. You need to handle the action to take a routing decision.

> You can handle these requests inside the **onNext(current path: ProfilePaths)** as you can see below, or you can create an extension for your coordinator and implement the functions of requests. For example: **func requestFromProfileRootView(_ action: ProfileRootActions)**

```swift
class ProfileCoordinator: Coordinator<ProfilePaths> {
    
    override func onNext(current path: ProfilePaths) {
        switch path {
        case .root(let action):
            switch action {
            case .didTapOnSettings:
                present(.settings(), mode: .sheet)
            case .didTapOnEditBio:
                present(.editBio(), mode: .push)
            case .viewModelDidProduceWarning:
                dismiss()
            case .dismissAfterError:
                present(.warning, mode: .fullScreen)
            case .idle:
                break
                // view just appeared
            }
        default:
            break
        }
    }
    
    override func onAppear(context: ProfilePaths) {
        super.onAppear(context: context)
    }
    
    override func onDisappear(context: ProfilePaths) {
        super.onDisappear(context: context)
    }
    
    override func buildView(presenter: ContextPresenter<ProfilePaths>) -> AnyView {
        switch presenter.name {
        case .root:
            let viewModel = ProfileViewModel()
            return ProfileRootView(presenter: presenter, viewModel: viewModel).any
        default:
            fatalError("You need to implement the construction of every view for your paths")
        }
    }
}
```

As you can see, inside the coordinator we also have methods responsible to tell us wich paths are currently presented or removed. 
The function buildView is where you gonna assemble your view and return it as **AnyView**. Jump has an extension **.any** that makes this construction easier. If you use **Dependecy Containers**, here is a good place to inject it inside your ViewModels.

## What to Improve / Open Points

* Directly wrap the content inside the ContextContent without the need for the user to do it always.
* Evaluate the possibility to implement the navigation stack for iOS>16
* Present in sequence
* Evaluate the need to make Coordinators to have parent/child relations between each other
* Improve Documentation

## Considerations

It's highly recommended to understand if this coordinator can help your development. Recently Apple launched NavigationStack which facilitates much more navigation with SwiftUI. Take a look more here: [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)

Currently is becoming hard to do routing with pure SwiftUI without wrap views inside HostingControllers, moreover, it’s even harder to understand the flow of the screens once the routing system is created, for new developers it can be a torment having to browse the whole project to understand the navigation system.

## License 📄
[MIT License](LICENSE).
