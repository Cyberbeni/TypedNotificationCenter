//
//  ReadWriteLock.swift
//  TypedNotificationCenter
// 
//  Created by Benedek Kozma on 2021. 08. 13.
//  Copyright (c) 2021. Benedek Kozma
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

final class ReadWriteLock: NSLocking {
    // https://developer.apple.com/videos/play/wwdc2016/720/?time=1085
    // Swift assumes that anything that is struct can be moved, and that doesn't work with a mutex or with a lock.
    private let _lock: UnsafeMutablePointer<pthread_rwlock_t>
    
    init() {
        _lock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        _lock.initialize(to: pthread_rwlock_t())
        assert(pthread_rwlock_init(_lock, nil) == 0)
    }
    
    deinit {
        assert(pthread_rwlock_destroy(_lock) == 0)
        _lock.deinitialize(count: 1)
        _lock.deallocate()
    }
    
    func readLock() {
        pthread_rwlock_rdlock(_lock)
    }
    
    func lock() {
        pthread_rwlock_wrlock(_lock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(_lock)
    }
}
