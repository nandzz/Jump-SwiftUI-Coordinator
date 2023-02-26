# Jump 🐒

[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg?style=for-the-badge&logo=swift&logoColor=black)](https://developer.apple.com/xcode/swiftui)
[![Swift](https://img.shields.io/badge/Swift-5.6-orange.svg?style=for-the-badge&logo=swift)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-14.2-blue.svg?style=for-the-badge&logo=Xcode&logoColor=white)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/license-MIT-black.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)


## Description

<sub> Simple way to coordinate flows in an app </sub>

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

> UITest repository: [Jump UITests](https://github.com/nandzz/Jump-SwiftUI-Coordinator)

<br>


## Tutorial

* [Installation](#installation-)
* [Define Paths](#definepaths-)
* [Create the Coordinator](#createthecoordinator-)
* [Create Views](#createviews-)
* [Create Actions](#createactions-)
* [Take decisions](#takedecisions-)

## Installation ⚙️

In Xcode add the dependency to your project via File > Add Packages > Search or Enter Package URL and use the following url:

```
https://github.com/nandzz/Jump-SwiftUI-Coordinator
```

Once added, import the package in your code:
```swift
import SwiftUIRouter
```

<br>

### Define Paths 🚙

Every flow has their given paths ( the view’s routing name ), so a path corresponds to a View. But what is these paths? If inside an app we have a section called Profile, this section can contain many paths

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

<br>

### Create the Coordinator 🤟

The coordinator has to conform to ##Coordinator## Type and its associated paths ( the one we just create in the section above )

```swift
class ProfileCoordinator: Coordinator<ProfilePaths> {}
```

<br>

### Create Views 📺

Each view using jump has to conform to `ContextView`
Here is how to declare the View:

> You can avoid to type the typealias by declaring directly the presenter as below

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

<br>

### Create Actions 👨‍💻

Every view has their actions. Taking the example of Profile section we can have the following actions for the root view

* didTapOnChangePicture
* didTapOnSettings
* didTapOnEditBio
* didTapOnPictures
* didTapOnDismiss
* dismissAfterError
* idle

> The actions can also be consequences of state change in the viewModel (ex. Network Error, API Call succeeded )

**You always need to have an idle action inside the enum**

Here is an example of how to define the profile actions:


```swift
public enum ProfileRootActions: ContextAction {
    case idle
    // Actions from interaction 
    case didTapOnChangePicture
    case didTapOnSettings
    case didTapOnEditBio
    case didTapOnPictures

    // Actions from state change
    case dismissAfterError(error:)
    case completeAfterSuccess(data:)
}
```

> It's advisable to declate these actions over the declarion of the view, so they can be easily be found. 

> The actions has to conform to ##Equatable## and ##Hashable## as well as any associated information that will be sent to the coordinator using associated types. You can conform the actions directly to ContextAction that implements ##Equatable## and ##Hashable## protocols.

<br>

## Take decisions 🚦

### Give the Paths Actions

Previously we declared the paths of the Profile flow with an enum. Now we gonna give actions to these paths to each one of this paths. 

**Remember:** Each View has it's actions and each view has it path defined inside Paths

```swift
enum ProfilePaths: ContextPath {
		case root(RootActions)
    case changePicture(ChangePictureActions = .idle)
    case settings(SettingsActions = .idle)
    case editBio(EditBioActions = .idle)
	  case pictures(PictureActions = .idle)
}
```

> By Having an idle action inside the enum of actions we are able to assign the init the path without a given action.


