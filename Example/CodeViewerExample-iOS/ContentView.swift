//
//  ContentView.swift
//  CodeViewerExample-iOS
//
//  Created by Phuc on 07/09/2020.
//  Copyright © 2020 Dwarves Foundattion. All rights reserved.
//

import SwiftUI
import CodeViewer

struct ContentView: View {
    
    @State private var json =  """
        {
            "hello": "world"
        }
        """
    
    var body: some View {
        CVCodeEditor(
            content: $json,
            mode: .json,
            theme: .individual(light: .solarized_light, dark: .solarized_dark)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
