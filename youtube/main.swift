//
//  main.swift
//  youtube
//
//  Created by Erik Little on 7/30/16.
//  Copyright © 2016 Erik Little. All rights reserved.
//

import Foundation

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

var mpv = "/usr/local/bin/mpv".cStringUsingEncoding(NSUTF8StringEncoding)!
var volume = 50
var video = false
var url = Process.arguments[Process.arguments.count - 1]

for i in 0..<Process.arguments.count {
    switch i {
    case 0:
        continue
    case 1:
        video = parseVideoArg(Process.arguments[1])
        fallthrough
    case 1:
        volume = Int(Process.arguments[1]) ?? 50
    case 2 where Int(Process.arguments[2]) != nil:
        volume = Int(Process.arguments[2])!
    default:
        continue
    }
}

let videoCString = (video ? "" : "--no-video").cStringUsingEncoding(NSUTF8StringEncoding)!
let volumeCString =  "--volume=\(volume)".cStringUsingEncoding(NSUTF8StringEncoding)!
let urlCString = url.cStringUsingEncoding(NSUTF8StringEncoding)!
var args = unsafeBitCast(malloc(strideof(Int8.self) * (mpv.count + videoCString.count + urlCString.count + volumeCString.count)),
                         UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.self)

args[0] = cStringToUnsafePointer(mpv)
args[1] = cStringToUnsafePointer(volumeCString)
args[2] = cStringToUnsafePointer(videoCString)
args[3] = cStringToUnsafePointer(urlCString)

execv(&mpv, args)
