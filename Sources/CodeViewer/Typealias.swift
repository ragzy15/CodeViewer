//
//  Typealias.swift
//  CodeViewer
//
//  Created by Raghav Ahuja on 21/02/21.
//

#if os(macOS)
import AppKit

public typealias CVView = NSView
public typealias CVRect = NSRect
#elseif os(iOS)
import UIKit

public typealias CVView = UIView
public typealias CVRect = CGRect
#endif

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)
@available(macOS 10.15, *)
public typealias CVViewRepresentable = NSViewRepresentable
#elseif os(iOS)
@available(iOS 13.0, *)
public typealias CVViewRepresentable = UIViewRepresentable
#endif
#endif

// JS Func
public typealias CVJavascriptCallback = (Result<Any?, Error>) -> Void
