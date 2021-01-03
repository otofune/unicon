//
//  DataExt.swift
//  unicon
//
//  Created by otofune on 2021/01/04.
//  Copyright © 2021 otofune. All rights reserved.
//

import Foundation

extension Data {
    /// Read binary as given type forcibly.
    /// Returns nil when collection size is shorter than T's size.
    ///
    /// I cared about value types only, eg Integer or struct or etc...
    /// Also I didn't care about alignment, I treated binary as aligned.
    /// Because of this, this method may returns invalid value.
    /// In addition, this method doesn't care endianess.
    /// So you must be responsible about checking value.
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
