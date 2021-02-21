//
//  CVCodeEditor.swift
//  CodeViewer
//
//  Created by Raghav Ahuja on 21/02/21.
//

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
public struct CVCodeEditor: CVViewRepresentable {
    
    public enum Theme {
        case individual(light: CVTheme, dark: CVTheme)
        case single(CVTheme)
    }
    
    @Binding public var content: String
    
    public let mode: CVCodeMode
    public let theme: Theme
    public let isReadOnly: Bool
    
    public var fontSize: CGFloat {
        #if os(macOS)
        if #available(macOS 11.0, *) {
            return NSFont.preferredFont(forTextStyle: .body, options: [:]).pointSize
        } else {
            return NSFont.systemFontSize
        }
        #elseif os(iOS)
        return UIFont.preferredFont(forTextStyle: .body, compatibleWith: .none).pointSize
        #endif
    }
    
    public init(content: Binding<String>, mode: CVCodeMode = .json,
                theme: Theme = .individual(light: .solarized_light, dark: .solarized_dark), isReadOnly: Bool = false) {
        self._content = content
        self.mode = mode
        self.theme = theme
        self.isReadOnly = isReadOnly
    }
    
    // MARK: macOS
    public func makeNSView(context: Context) -> CVCodeEditorWebView {
        createWebView(context: context)
    }
    
    public func updateNSView(_ webview: CVCodeEditorWebView, context: Context) {
        updateWebView(webview, context: context)
    }
    
    // MARK: iOS
    public func makeUIView(context: Context) -> CVCodeEditorWebView {
        createWebView(context: context)
    }
    
    public func updateUIView(_ webview: CVCodeEditorWebView, context: Context) {
        updateWebView(webview, context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(content: $content)
    }
    
    private func createWebView(context: Context) -> CVCodeEditorWebView {
        let codeView = CVCodeEditorWebView()
        codeView.delegate = context.coordinator
        
        codeView.setContent(content)
        codeView.clearSelection()
        updateWebView(codeView, context: context)

        return codeView
    }
    
    private func updateWebView(_ webview: CVCodeEditorWebView, context: Context) {
        webview.setFontSize(Int(fontSize))
        webview.setReadOnly(isReadOnly)
        webview.setMode(mode)
        
        switch theme {
        case .single(let theme):
            webview.setTheme(theme)
        case .individual(let lightTheme, let darkTheme):
            switch context.environment.colorScheme {
            case .light:
                webview.setTheme(lightTheme)
            case .dark:
                webview.setTheme(darkTheme)
            @unknown default:
                break
            }
        }
    }
}

// MARK: Coordinator

@available(iOS 13.0, macOS 10.15, *)
extension CVCodeEditor {
    
    public class Coordinator: CVCodeEditorWebViewDelegate {
        
        @Binding private(set) var content: String
        
        init(content: Binding<String>) {
            _content = content
        }
        
        func set(content: String) {
            if self.content != content {
                self.content = content
            }
        }
        
        public func codeEditorWebView(_ codeEditorWebView: CVCodeEditorWebView, contentDidChange newContent: String) {
            content = newContent
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct CVCodeEditor_Previews : PreviewProvider {
    static private var jsonString = """
    {
        "hello": "world"
    }
    """
    
    @available(iOS 13.0.0, *)
    static var previews: some View {
        CVCodeEditor(content: .constant(jsonString))
    }
}
#endif
