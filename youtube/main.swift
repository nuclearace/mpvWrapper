//
//  main.swift
//  youtube
//
//  Created by Erik Little on 7/30/16.
//  Copyright © 2016 Erik Little. All rights reserved.
//

import Foundation

enum Arg {
    case audioOnly
    case url(String)
    case video
    case volume(Int)
    
    var cString: [CChar] {
        switch self {
        case .audioOnly:
            return "--no-video".cStringUsingEncoding(NSUTF8StringEncoding)!
        case let .volume(vol):
            return "--volume=\(vol)".cStringUsingEncoding(NSUTF8StringEncoding)!
        default:
            return []
        }
    }
    
    static func parse(string: String) -> Arg {
        let option: String
        
        if string.containsString("=") {
            option = string[string.startIndex...string.startIndex.advancedBy(2)]
        } else {
            option = string
        }
        
        switch option {
        case "-vi":
            return .video
        case "-v=":
            return .volume(Int(string[string.startIndex.advancedBy(3)..<string.endIndex])!)
        default:
            return .url(string)
        }
    }
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
var audioOnly: Arg? = Arg.audioOnly
var urls = [String]()

for arg in arguments {
    let a = Arg.parse(arg)
    
    switch a {
    case .audioOnly:
        audioOnly = a
    case .video:
        audioOnly = nil
    case .volume:
        volume = a
    case let .url(urlString):
        urls.append(urlString)
    }
}

let audioOnlyCString = audioOnly?.cString ?? []
let volumeCString = volume.cString
var urlsCount = urls.map({ $0.cStringUsingEncoding(NSUTF8StringEncoding)!.count }).reduce(0, combine: +)
let size = strideof(Int8.self) * (mpv.count + audioOnlyCString.count + urlsCount + volumeCString.count)
var args = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.alloc(size)

args[0] = cStringToUnsafePointer(mpv)
args[1] = cStringToUnsafePointer(volumeCString)
args[2] = cStringToUnsafePointer(audioOnlyCString)

for i in 0..<urls.count {
    args[i+3] = cStringToUnsafePointer(urls[i].cStringUsingEncoding(NSUTF8StringEncoding)!)
}

execv(&mpv, args)
