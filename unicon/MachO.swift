//
//  MachO.swift
//  unicon
//
//  Created by otofune on 2020/11/19.
//

import Foundation

extension Data {
    /// Read binary as given type forcibly.
    /// I cared about value types only, eg Integer or struct or etc...
    /// Also I didn't care about alignment, I treated binary as aligned.
    /// Because of this, this method may returns invalid value.
    /// In addition, this method doesn't care endianess.
    /// So you must be responsible about checking value.
    /// Returns nil when collection size is shorter than T's size.
    mutating func popFirstAs<T>() -> T? {
        let p = UnsafeMutableRawPointer.allocate(
            byteCount: MemoryLayout<T>.size,
            alignment: MemoryLayout<T>.alignment
        )
        p.bindMemory(to: UInt8.self, capacity: MemoryLayout<T>.size)
        for i in 0..<MemoryLayout<T>.size {
            guard let b: UInt8 = self.popFirst() else { return nil }
            p.storeBytes(
                of: b,
                toByteOffset: i,
                as: UInt8.self
            )
        }
        let val = p.load(as: T.self)
        p.deallocate()
        return val
    }
}

extension FixedWidthInteger {
    func swap(_ r: Bool) -> Self {
        return r ? self.byteSwapped : self
    }
}

class MachOUtility {
    static func supportCPUTypes(path: URL) throws -> Array<CPUArchitecture> {
        // throw when no permission to read file
        // eg: execute .app directly from mounted dmg file
        var data = try Data(contentsOf: path)
        guard let fat_magic: UInt32 = data.popFirstAs() else { throw NSError(domain: "[unreachable] missing header (file too short)", code: -1, userInfo: nil) }

        // TODO: Magic code "0xcafebabe" is same as Java byte code.
        // path is delivered from frontmostApplication, so it's not problem for now, but I want to check more strictly checking in future.
        if ![FAT_MAGIC, FAT_CIGAM, FAT_MAGIC_64, FAT_CIGAM_64].contains(fat_magic) {
            // not fat binary
            return []
        }

        var architectures: Array<CPUArchitecture> = []

        let swap_required = [FAT_CIGAM, FAT_CIGAM_64].contains(fat_magic)

        guard let nfat_arch = data.popFirstAs().map({ (i: UInt32) in i.swap(swap_required) }) else { throw NSError(domain: "", code: -1, userInfo: nil) }

        for _ in 0..<nfat_arch {
            switch fat_magic {
            case FAT_MAGIC, FAT_CIGAM:
                // TODO: Make parsing fat_arch more stable
                // This line dependents that fat_arch has no padding between members
                // because all fields are 32bit (4 byte) number at now. (int32_t = integer_t = cpu_type_t)
                // But its type may be changed in future,
                // or Swift memory layout may be changed because there are no guarantee about in-memory layout.
                guard let fa: fat_arch = data.popFirstAs() else { throw NSError(domain: "unexpected: missing fat_arch (file too short)", code: -1, userInfo: nil) }
                let cputype = fa.cputype.swap(swap_required)
                architectures.append(cputype as CPUArchitecture)
                break
            case FAT_MAGIC_64, FAT_CIGAM_64:
                throw NSError(domain: "64bit fat header unsupported", code: -1)
            default:
                throw NSError(domain: "unreachable", code: -1, userInfo: nil)
            }
        }
        return architectures
    }
}
