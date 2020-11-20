//
//  MachO.swift
//  unicon
//
//  Created by owner on 2020/11/19.
//

import Foundation
import MachOKit

class MachOUtility {
    // not universal binary, return []
    // ファイルを見る権限が足りないと throw (ex: dmg を開いてそのままアプリを実行する) 
    static func supportCPUTypes(path: URL) throws -> Array<CPUType> {
        let memoryMap = try MKMemoryMap(contentsOfFile: path)
        if let fatBinary = try? MKFatBinary(memoryMap: memoryMap) {
            return fatBinary.architectures.map({ a in a.cputype })
        }
        return []
    }
}
