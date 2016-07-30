//
//  main.swift
//  youtube
//
//  Created by Erik Little on 7/30/16.
//  Copyright © 2016 Erik Little. All rights reserved.
//

import Foundation

enum Arg {
    case volume(Int)
    case audioOnly(Bool)
    case url(String)
    
    var cString: [CChar] {
        switch self {
        case let .audioOnly(ao):
            return (ao ? "--no-video" : "").cStringUsingEncoding(NSUTF8StringEncoding)!
        case let .volume(vol):
            return "--volume=\(vol)".cStringUsingEncoding(NSUTF8StringEncoding)!
        default:
            return []
        }
    }
    
    static func parse(string: String) -> Arg {
        let option = string[string.startIndex...string.startIndex.advancedBy(2)]
        
        switch option {
        case "-a=":
            return .audioOnly(string[string.startIndex.advancedBy(3)..<string.endIndex] == "y")
        case "-v=":
            return .volume(Int(string[string.startIndex.advancedBy(3)..<string.endIndex])!)
        default:
            return .url(string)
        }
    }
}

func parseVideoArg(arg: String) -> Bool {
    return arg == "y"
}

func cStringToUnsafePointer(s: [CChar]) -> UnsafeMutablePointer<Int8> {
    let pointer = UnsafeMutablePointer<Int8>.alloc(s.count)
    
    for i in 0..<s.count {
        pointer[i] = s[i]
    }
    
    return pointer
}

let arguments = Process.arguments.dropFirst()
var mpv = "/usr/local/bin/mpv".cStringUsingEncoding(NSUTF8StringEncoding)!
var volume = Arg.volume(50)
var audioOnly = Arg.audioOnly(true)
var url = ""

for arg in arguments {
    let a = Arg.parse(arg)
    
    switch a {
    case .audioOnly:
        audioOnly = a
    case .volume:
        volume = a
    case let .url(urlString):
        url += urlString + " "
    }
}

let audioOnlyCString = audioOnly.cString
let volumeCString = volume.cString
let urlCString = url.cStringUsingEncoding(NSUTF8StringEncoding)!
var args = unsafeBitCast(malloc(strideof(Int8.self) * (mpv.count + audioOnlyCString.count + urlCString.count + volumeCString.count)),
                         UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.self)

args[0] = cStringToUnsafePointer(mpv)
args[1] = cStringToUnsafePointer(volumeCString)
args[2] = cStringToUnsafePointer(audioOnlyCString)
args[3] = cStringToUnsafePointer(urlCString)

execv(&mpv, args)
