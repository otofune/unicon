//
//  CPU.swift
//  unicon
//
//  Created by owner on 2020/11/21.
//

import Foundation

// TODO: 自動で Int になっちゃうのか気になる (オートダウンキャストされるのか名前によって絞られるのか -> type alias は識別されないらしい)
typealias CPUType = cpu_type_t // NSBundleExecutableArchitecture と中の値は同じっぽいが

enum CPUGroup {
    case Unknown
    case PPC
    case Intel
    case Apple
}

protocol CPUArchitecture {
    func toStr() -> String
    func group() -> CPUGroup
    func isSameGroup(_ target: CPUArchitecture) -> Bool
}

extension Int: CPUArchitecture {
    func toStr() -> String {
        switch self {
        case NSBundleExecutableArchitecturePPC:
            return "ppc"
        case NSBundleExecutableArchitecturePPC64:
            return "ppc64"
        case NSBundleExecutableArchitectureI386:
            return "i386"
        case NSBundleExecutableArchitectureX86_64:
            return "x86_64"
        case let other:
            if #available(OSX 11.0, *), other == NSBundleExecutableArchitectureARM64 {
                return "arm64"
            }
            if other == Int(CPU_TYPE_ARM64) {
                return "arm64"
            }
            fallthrough
        default: return "Unknown"
        }
    }
    func group() -> CPUGroup {
        switch self {
        case NSBundleExecutableArchitecturePPC:
            fallthrough
        case NSBundleExecutableArchitecturePPC64:
            return .PPC
        case NSBundleExecutableArchitectureI386:
            fallthrough
        case NSBundleExecutableArchitectureX86_64:
            return .Intel
        case let other:
            if #available(OSX 11.0, *), other == NSBundleExecutableArchitectureARM64 {
                return .Apple
            }
            fallthrough
        default: return .Unknown
        }
    }
    func isSameGroup(_ target: CPUArchitecture) -> Bool {
        let lhs = self.group()
        let rhs = target.group()
        if lhs == .Unknown || rhs == .Unknown {
            return false
        }
        return lhs == rhs
    }
}

extension CPUType: CPUArchitecture {
    func toStr() -> String {
        (Int(self) as CPUArchitecture).toStr()
    }
    func group() -> CPUGroup {
        (Int(self) as CPUArchitecture).group()
    }
    func isSameGroup(_ target: CPUArchitecture) -> Bool {
        (Int(self) as CPUArchitecture).isSameGroup(target)
    }
}

class SysctlUtility {
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
