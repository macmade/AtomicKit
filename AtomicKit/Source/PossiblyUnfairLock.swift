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
 * A potentially unfair lock.
 * If available (macOS 10.12 and later), uses internally an unfair lock.
 * Otherwise, uses a standard mutex.
 * 
 * - seealso: UnfairLock
 * - seealso: Mutex
 * - seealso: Locakble
 */
public class PossiblyUnfairLock: Lockable
{
    /**
     * Designated initializer.
     * Initializes an unfair lock object.
     */
    public required init() throws
    {
        if #available( macOS 10.12, * )
        {
            self._lock = UnfairLock()
        }
        else
        {
            do
            {
                try self._lock = Mutex()
            }
            catch let e
            {
                throw e
            }
        }
    }
    
    /**
     * Locks an unfair lock.
     */
    public func lock()
    {
        if #available( macOS 10.12, * )
        {
            ( self._lock as! UnfairLock ).lock()
        }
        else
        {
            ( self._lock as! Mutex ).lock()
        }
    }
    
    /**
     * Unlocks an unfair lock.
     */
    public func unlock()
    {
        if #available( macOS 10.12, * )
        {
            ( self._lock as! UnfairLock ).unlock()
        }
        else
        {
            ( self._lock as! Mutex ).unlock()
        }
    }
    
    /**
     * Tries to lock an unfair lock if it is not already locked.
     * 
     * - returns:   `true` if the lock was successfully locked, otherwise `false`.
     */
    public func tryLock() -> Bool
    {
        if #available( macOS 10.12, * )
        {
            return ( self._lock as! UnfairLock ).tryLock()
        }
        else
        {
            return ( self._lock as! Mutex ).tryLock()
        }
    }
    
    private var _lock: Any
}
