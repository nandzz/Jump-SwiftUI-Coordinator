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

### Create the Coordinator 🤟

The coordinator has to conform to ##Coordinator## Type and its associated paths ( the one we just create in the section above )

```swift
class ProfileCoordinator: Coordinator<ProfilePaths> {}
```


### Create Views 📺

Each view using jump has to conform to `ContextView`
Here is how to declare the View:

> You can avoid to type the typealias by declaring directly the presenter as below

```swift
struct ContentView: ContextView {
    
   var presenter: ContextPresenter<ProfilePaths>

    var body: some View {
        ContextContent<ProfilePaths>(presenter) { emit in
            // Use ContextContent to wrap your view passing the paths 
            // to its generic type and initialising it with the presenter injected. 
        }
    }
}
```

### Create Actions 👨‍💻

### Take decisions 🚦
