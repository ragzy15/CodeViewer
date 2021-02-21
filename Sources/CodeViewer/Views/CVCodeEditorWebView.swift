//
//  CVCodeEditorWebView.swift
//  CodeViewer
//
//  Created by phucld on 8/20/20.
//  Copyright © 2020 Dwarves Foundattion. All rights reserved.
//

import WebKit

public class CVCodeEditorWebView: CVView {
    
    private struct Constants {
        static let aceEditorDidReady = "aceEditorDidReady"
        static let aceEditorDidChanged = "aceEditorDidChanged"
    }
    
    private lazy var webview: WKWebView = {
        let preferences = WKPreferences()
        var userController = WKUserContentController()
        userController.add(self, name: Constants.aceEditorDidReady) // Callback from Ace editor js
        userController.add(self, name: Constants.aceEditorDidChanged)
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = userController
        let webView = WKWebView(frame: bounds, configuration: configuration)
        
        webView.allowsLinkPreview = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        
        #if os(macOS)
        webView.setValue(true, forKey: "drawsTransparentBackground") // Prevent white flick
        #elseif os(iOS)
        webView.isOpaque = false
        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        #endif
        
        return webView
    }()
    
    public weak var delegate: CVCodeEditorWebViewDelegate? = nil
    public var textDidChanged: ((String) -> Void)? = nil
    
    private var currentContent: String = ""
    private var currentTheme: CVTheme? = .none
    private var currentMode: CVCodeMode? = .none
    private var pageLoaded = false
    private var pendingFunctions = [CVJavascriptFunction]()
    
    #if os(macOS)
    override init(frame frameRect: CVRect) {
        super.init(frame: frameRect)
        initWebView()
    }
    #elseif os(iOS)
    public override init(frame: CVRect) {
        super.init(frame: frame)
        initWebView()
    }
    #endif
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWebView()
    }
    
    public func setContent(_ value: String) {
        guard currentContent != value else {
            return
        }
        
        currentContent = value
        
        //
        // It's tricky to pass FULL JSON or HTML text with \n or "", ... into JS Bridge
        // Have to wrap with `data_here`
        // And use String.raw to prevent escape some special string -> String will show exactly how it's
        // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
        //
        let first = "var content = String.raw`"
        let content = """
        \(value)
        """
        let end = "`; editor.setValue(content);"
        
        let script = first + content + end
        callJavascript(javascriptString: script)
    }
    
    public func setTheme(_ theme: CVTheme) {
        guard currentTheme != theme else {
            return
        }
        
        currentTheme = theme
        callJavascript(javascriptString: "editor.setTheme('ace/theme/\(theme.rawValue)');")
    }
    
    public func setMode(_ mode: CVCodeMode) {
        guard currentMode != mode else {
            return
        }
        
        currentMode = mode
        callJavascript(javascriptString: "editor.session.setMode('ace/mode/\(mode.rawValue)');")
    }
    
    public func setReadOnly(_ isReadOnly: Bool) {
        callJavascript(javascriptString: "editor.setReadOnly(\(isReadOnly));")
    }
    
    public func setFontSize(_ fontSize: Int) {
        let script = "document.getElementById('editor').style.fontSize='\(fontSize)px';"
        callJavascript(javascriptString: script)
    }
    
    public func clearSelection() {
        let script = "editor.clearSelection();"
        callJavascript(javascriptString: script)
    }
    
    public func getAnnotation(callback: @escaping CVJavascriptCallback) {
        let script = "editor.getSession().getAnnotations();"
        callJavascript(javascriptString: script) { result in
            callback(result)
        }
    }
}

extension CVCodeEditorWebView {
    
    private func initWebView() {
        webview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webview)
        webview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        webview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        webview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        guard let bundlePath = Bundle.module.path(forResource: "Ace", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let indexFileURL = bundle.url(forResource: "index", withExtension: "html") else {
                fatalError("Ace editor is missing")
        }
        
        let data = try! Data(contentsOf: indexFileURL)
        webview.load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: bundle.resourceURL!)
    }
    
    private func addFunction(function: CVJavascriptFunction) {
        pendingFunctions.append(function)
    }
    
    private func callJavascriptFunction(function: CVJavascriptFunction) {
        webview.evaluateJavaScript(function.functionString) { (response, error) in
            if let error = error {
                function.callback?(.failure(error))
            } else {
                function.callback?(.success(response))
            }
        }
    }
    
    private func callPendingFunctions() {
        for function in pendingFunctions {
            callJavascriptFunction(function: function)
        }
    
        pendingFunctions.removeAll()
    }
    
    private func callJavascript(javascriptString: String, callback: CVJavascriptCallback? = nil) {
        if pageLoaded {
            callJavascriptFunction(function: CVJavascriptFunction(functionString: javascriptString, callback: callback))
        } else {
            addFunction(function: CVJavascriptFunction(functionString: javascriptString, callback: callback))
        }
    }
}

extension CVCodeEditorWebView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.isFileURL == true {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
}

// MARK: WKScriptMessageHandler

extension CVCodeEditorWebView: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        // is Ready
        if message.name == Constants.aceEditorDidReady {
            pageLoaded = true
            callPendingFunctions()
            return
        }
        
        // is Text change
        if message.name == Constants.aceEditorDidChanged,
           let text = message.body as? String {
            textDidChanged?(text)
            delegate?.codeEditorWebView(self, contentDidChange: text)
            return
        }
    }
}

#if os(iOS)
// MARK: UIScrollViewDelegate

extension CVCodeEditorWebView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
#endif
