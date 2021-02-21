//
//  ContentView.swift
//  CodeViewer
//
//  Created by phucld on 8/20/20.
//  Copyright © 2020 Dwarves Foundattion. All rights reserved.
//

import SwiftUI
import CodeViewer

struct ContentView: View {
    @State private var json = """
        {
            "hello": "world"
        }
        """
    
    var body: some View {
        VStack {
            CVCodeEditor(
                content: $json,
                mode: .json,
                theme: .individual(light: .solarized_light, dark: .solarized_dark)
            )
            
            Button(action: { print(json)} ) {
                Label("Json", systemImage: "pencil")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
