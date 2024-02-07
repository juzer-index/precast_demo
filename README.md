Precast Demo was a project undertaken to connect Epicor to a mobile interface in order to provide better accessibility on the field

## Installation

To get started with contributing to the project you would need a few things:
1. Flutter SDK
2. Android Studio or VSCode (Xcode if you're on a Mac)
3. An Android or iOS device (or emulator)

The flutter SDK can be found on the [Flutter website](https://flutter.dev/docs/get-started/install). 
The website also provides instructions on how to install the SDK on your machine.

Android Studio can be found on the [Android Studio website](https://developer.android.com/studio).

And optionally if this application is built for windows in the future you will need Visual Studio.
The community version of VS will suffice which can be found on the [Visual Studio website](https://visualstudio.microsoft.com/downloads/).

## Usage

To run the application you will need to have an Android or iOS device connected to your machine or have an emulator running.
Disclaimer: To run it on a physical android device you will need to enable USB Debugging in developer Options. 
Developer options can be found in the settings app on your device. 
If you do not see it you will need to enable it by going to the About Phone section and tapping on the build number 7 times.

You can then select your connected device from the dropdown on the toolbar and click the run button to launch a debug version of this application
on the emulator or your connected device.

## Contributing

The code structure for flutter is pretty simple the details for which can be found on the [Flutter website](https://flutter.dev/docs/development/ui/layout).

The UI follows a widget tree structure where each widget is a child of another widget.

For example lets say that you want create a login screen with a username and password field and a login button.
The widget tree for this would look something like this:

```
Scaffold
  - Column
    - TextField
    - TextField
    - RaisedButton
```

The Scaffold widget is the root widget for the screen and it provides a lot of functionality for the screen.
The Column widget is a widget that allows you to stack widgets vertically.
The TextField widget is a widget that allows you to create a text input field.
The RaisedButton widget is a widget that allows you to create a button.

Lets get to the code now.

```
Scaffold(
  body: Column(
    children: <Widget>[
      TextField(),
      TextField(),
      RaisedButton()
    ]
  )
)
```

This is the basic structure of the code for the login screen.
The Scaffold widget has a property called body which takes in a widget.
The Column widget has a property called children which takes in a list of widgets.
The TextField and RaisedButton widgets do not have any properties that take in widgets.

Now lets add some functionality to the login screen.
Lets say that we want to print the username and password to the console when the login button is pressed.
The RaisedButton widget has a property called onPressed which takes in a function.
The function that we pass in will be called when the button is pressed.

```
Scaffold(
  body: Column(
    children: <Widget>[
      TextField(),
      TextField(),
      RaisedButton(
        onPressed: () {
          print("Username: " + username);
          print("Password: " + password);
        }
      )
    ]
  )
)
```

Now lets say that we want to store the username and password in variables.
The TextField widget has a property called onChanged which takes in a function.
The function that we pass in will be called when the text in the text field changes.

```
Scaffold(
  body: Column(
    children: <Widget>[
      TextField(
        onChanged: (text) {
          username = text;
        }
      ),
      TextField(
        onChanged: (text) {
          password = text;
        }
      ),
      RaisedButton(
        onPressed: () {
          print("Username: " + username);
          print("Password: " + password);
        }
      )
    ]
  )
)
```

Now lets say that we want to store the username and password in a class.

```
class User {
  String username;
  String password;
  
  User(this.username, this.password);
}

User user;

Scaffold(
  body: Column(
    children: <Widget>[
      TextField(
        onChanged: (text) {
          user.username = text;
        }
      ),
      TextField(
        onChanged: (text) {
          user.password = text;
        }
      ),
      RaisedButton(
        onPressed: () {
          print("Username: " + user.username);
          print("Password: " + user.password);
        }
      )
    ]
  )
)
```

Lets get to the actual code now.
The code for the login screen can be found in the [loginPage.dart]
The code for the home screen can be found in the [homepage.dart]

The primary features of this applicaton are the stock loading screen and off loading screen.

