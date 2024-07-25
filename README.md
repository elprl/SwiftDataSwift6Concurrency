# SwiftDataSwift6Concurrency

An iOS app test harness for exploring strict concurrency with SwiftData and Swift 6 async/await approach with modern macros. 

## Challenges

How to create a SwiftUI app where SwiftData operations run on background threads and eventually update SwiftUI views on the main actor as required - while dealing with cross actor boundary challenges.

### Crossing actor boundaries
This sample code approaches the problem with two solutions:
1) Background actor sends SwiftData model IDs (`PersistentIdentifier`) to the main actor to be reconstituted in that context. 
2) Background actor sends `Sendable` objects mirroring the @Model classes.  

## Install
- Build using Xcode 16 Beta and run. Uses Swift 6.

## Discussion
Feel free to ask questions and send feedback via issues tab.
