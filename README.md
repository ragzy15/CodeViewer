# CodeViewer

<p align="left">
	<a href="https://webuild.community">
        <img src="https://raw.githubusercontent.com/webuild-community/badge/master/svg/made.svg" />
	</a>
    <img src="https://img.shields.io/badge/platform-macOS | iOS-lightgrey.svg" alt="platform" />
</p>

CodeViewer is a custom code editor SwiftUI view, which wrap around the [ace](http://ace.c9.io) editor.

<p align="center">
	<img width="500" alt="image" src="./misc/img.png">
	<img width="200" alt="image" src="./misc/img-ios.png">
</p>

## Features

- [x] Darkmode, lightmode adopt automatically
- [x] Syntax highlighting for over 110 languages (TextMate/Sublime Text.tmlanguage files can be imported)
- [x] Over 20 themes (TextMate/Sublime Text .tmtheme files can be imported)
- [x] Support SwiftUI

## Usage

```Swift
import SwiftUI
import CodeViewer

struct ContentView: View {
    @State private var json = ""
    
    var body: some View {
        CVCodeEditor(
            content: $json,
            mode: .json,
            theme: .individual(light: .solarized_light, dark: .solarized_dark)
            isReadOnly: true
        )
        .onAppear {
            json = """
            {
                "hello": "world"
            }
            """
        }
    }
}

```

## Requirement
- iOS >= v11
- macOS >= v10.11
- Xcode >= 12.0
