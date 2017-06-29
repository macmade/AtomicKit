/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

/**
 * Swift wrapper class for `os_unfair_lock_t`.  
 * A low-level lock that allows waiters to block efficiently on contention.
 * 
 * - seealso: Locakble
 */
public class UnfairLock: Lockable
{
    /**
     * Designated initializer.
     * Initializes an unfair lock object.
     */
    public required init()
    {
        self._lock = os_unfair_lock_t.allocate( capacity: 1 )
        
        self._lock.initialize( to: os_unfair_lock_s() )
    }
    
    deinit
    {
        self._lock.deinitialize()
        self._lock.deallocate( capacity: 1 )
    }
    
    /**
     * Locks an unfair lock.
     */
    public func lock()
    {
        os_unfair_lock_lock( self._lock )
    }
    
    /**
     * Unlocks an unfair lock.
     */
    public func unlock()
    {
        os_unfair_lock_unlock( self._lock )
    }
    
    /**
     * Tries to lock an unfair lock if it is not already locked.
     * 
     * - returns:   `true` if the lock was successfully locked, otherwise `false`.
     */
    public func tryLock() -> Bool
    {
        return os_unfair_lock_trylock( self._lock )
    }
    
    private var _lock: os_unfair_lock_t
}
