# Zendesk Connect iOS SDK

## Install 

### Cocoapods

If you don't have cocoapods yet:
```
sudo gem install cocoapods
```

If you don't have any pods installed yet:
```
pod init
```

To install the Outbound SDK, add this to your `Podfile`:
```
pod 'ZendeskConnect', ~> '2.0'
```

Then run:
```
pod install
```

### Carthage

If you use [Carthage](https://github.com/Carthage/Carthage) add this to your `Cartfile`: 
```
github "zendesk/connect-ios-sdk" ~> 2.0
```

Then run:
```
carthage update
```

## Migration guides

- [1.0.X to 1.1.X](docs/migrating.md)