//
//  ANSIStyle.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 15/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */// Project's Source: https://github.com/codeFi/XcodeLogger

public struct ANSIStyle: Equatable, Sendable {
    public let foreground: (UInt8, UInt8, UInt8)?
    public let background: (UInt8, UInt8, UInt8)?

    public init(
        foreground: (UInt8, UInt8, UInt8)? = nil,
        background: (UInt8, UInt8, UInt8)? = nil
    ) {
        self.foreground = foreground
        self.background = background
    }

    public static func == (lhs: ANSIStyle, rhs: ANSIStyle) -> Bool {
        lhs.foreground?.0 == rhs.foreground?.0 &&
        lhs.foreground?.1 == rhs.foreground?.1 &&
        lhs.foreground?.2 == rhs.foreground?.2 &&
        lhs.background?.0 == rhs.background?.0 &&
        lhs.background?.1 == rhs.background?.1 &&
        lhs.background?.2 == rhs.background?.2
    }
}

extension ANSIStyle {
    func applying(to string: String) -> String {
        guard foreground != nil || background != nil else {
            return string
        }

        var fragments: [String] = []
        if let foreground {
            fragments.append("\u{001B}[38;2;\(foreground.0);\(foreground.1);\(foreground.2)m")
        }
        if let background {
            fragments.append("\u{001B}[48;2;\(background.0);\(background.1);\(background.2)m")
        }
        fragments.append(string)
        fragments.append("\u{001B}[0m")
        return fragments.joined()
    }
}
