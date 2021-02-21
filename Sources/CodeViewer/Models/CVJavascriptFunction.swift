//
//  CVJavascriptFunction.swift
//  CodeViewer
//
//  Created by Raghav Ahuja on 21/02/21.
//

// MARK: JavascriptFunction

struct CVJavascriptFunction {
    
    let functionString: String
    let callback: CVJavascriptCallback?
    
    init(functionString: String, callback: CVJavascriptCallback? = nil) {
        self.functionString = functionString
        self.callback = callback
    }
}
