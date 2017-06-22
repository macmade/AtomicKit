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

/*!
 * @file        RWLock.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import Foundation

public class RWLock
{
    public enum Error: Swift.Error
    {
        case CannotCreateLock
        case CannotCreateLockAttributes
    }
    
    public enum Intent
    {
        case reading
        case writing
    }
    
    public init() throws
    {
        var attr = pthread_rwlockattr_t()
        
        if( pthread_rwlockattr_init( &attr ) != 0 )
        {
            throw Error.CannotCreateLockAttributes
        }
        
        if( pthread_rwlock_init( &( self._lock ), &attr ) != 0 )
        {
            throw Error.CannotCreateLock
        }
    }
    
    deinit
    {
        pthread_rwlock_destroy( &( self._lock ) )
    }
    
    public func lock( for intent: Intent )
    {
        switch( intent )
        {
            case .reading: pthread_rwlock_rdlock( &( self._lock ) )
            case .writing: pthread_rwlock_wrlock( &( self._lock ) )
        }
    }
    
    public func unlock()
    {
        pthread_rwlock_unlock( &( self._lock ) )
    }
    
    public func tryLock( for intent: Intent ) -> Bool
    {
        switch( intent )
        {
            case .reading: return pthread_rwlock_tryrdlock( &( self._lock ) ) == 0
            case .writing: return pthread_rwlock_trywrlock( &( self._lock ) ) == 0
        }
    }
    
    private var _lock = pthread_rwlock_t()
}
