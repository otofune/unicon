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
    static func supportCPUTypes(path: URL) throws -> Array<CPUType> {
        let memoryMap = try MKMemoryMap(contentsOfFile: path)
        if let fatBinary = try? MKFatBinary(memoryMap: memoryMap) {
            return fatBinary.architectures.map({ a in a.cputype })
        }
        return []
    }
    
    // FIXME: 場所がおかしい…
    // @unused ← みたいなのってあるのかな
    static func getMachineArchitecture() throws -> CPUType {
        var type = CPUType(0)
        var size = MemoryLayout.size(ofValue: type)
        // https://github.com/apple/darwin-xnu/blob/master/bsd/sys/sysctl.h
        let result = sysctlbyname("hw.cputype", &type, &size, nil, 0);
        if result == -1 {
            throw NSError(domain: "hw.cputype", code: -1, userInfo: nil)
        }
        return type
    }
}
