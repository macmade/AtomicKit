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
 * Represents a reader-writer lock.  
 * Note that this implementation is recursive.
 * 
 * Using a reader-writer lock, multiple treads can lock for reading, if no
 * writer is currently holding the lock.  
 * Only one writer can hold the lock, preventing readers to acquire it.
 */
public class RWLock
{
    /**
     * `RWLock` errors.
     */
    public enum Error: Swift.Error
    {
        /**
         * Thrown on initialization failures.
         */
        case CannotCreateMutex
    }
    
    /**
     * Locing intent.
     */
    public enum Intent
    {
        /**
         * Intent for reading operations.
         */
        case reading
        
        /**
         * Intent for writing operations.
         */
        case writing
    }
    
    /**
     * Initializer.
     * 
     * - throws: `RWLock.error` on initialization failure.
     */
    public init() throws
    {
        self._r = 0;
        
        do
        {
            try self._rrmtx = RecursiveMutex()
            try self._wrmtx = RecursiveMutex()
        }
        catch
        {
            throw Error.CannotCreateMutex
        }
    }
    
    /**
     * Acquires the lock.
     * 
     * - parameter intent:  The intent. See `RWLock.Intent`.
     * - seealso:          `RWLock.Intent`
     */
    public func lock( for intent: Intent )
    {
        if( intent == .reading )
        {
            self._rrmtx.lock()
            
            if( self._r == 0 )
            {
                self._wrmtx.lock()
            }
            
            self._r += 1
            
            self._rrmtx.unlock()
        }
        else
        {
            self._wrmtx.lock()
        }
    }
    
    /**
     * Releases the lock.
     * 
     * - parameter intent:  The intent. See `RWLock.Intent`.
     * - seealso:          `RWLock.Intent`
     */
    public func unlock( for intent: Intent )
    {
        if( intent == .reading )
        {
            self._rrmtx.lock()
            
            if( self._r > 0 )
            {
                self._r -= 1
                
                if( self._r == 0 )
                {
                    self._wrmtx.unlock();
                }
            }
            
            self._rrmtx.unlock()
        }
        else
        {
            self._wrmtx.unlock()
        }
    }
    
    /**
     * Tries to acquires the lock.
     * 
     * - parameter intent:  The intent. See `RWLock.Intent`.
     * - returns:          `true` if the lock was successfully locked, otherwise `false`.
     * - seealso:          `RWLock.Intent`
     */
    public func tryLock( for intent: Intent ) -> Bool
    {
        if( intent == .reading )
        {
            self._rrmtx.lock()
            
            let r = ( self._r == 0 ) ? self._wrmtx.tryLock() : true
            
            if( r )
            {
                self._r += 1
            }
            
            self._rrmtx.unlock()
            
            return r
        }
        else
        {
            return self._wrmtx.tryLock()
        }
    }
    
    private var _rrmtx: RecursiveMutex;
    private var _wrmtx: RecursiveMutex;
    private var _r:     Int64
}
