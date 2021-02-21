//
//  CVCodeEditorWebViewDelegate.swift
//  CodeViewer
//
//  Created by Raghav Ahuja on 21/02/21.
//

public protocol CVCodeEditorWebViewDelegate: AnyObject {
    func codeEditorWebView(_ codeEditorWebView: CVCodeEditorWebView, contentDidChange newContent: String)
}
