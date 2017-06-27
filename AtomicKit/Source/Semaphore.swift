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
 * Represents a semaphore object.  
 * Note that named semaphores are shared accross different processes.
 */
public class Semaphore
{
    /**
     * The maximum length for a semaphore name.
     */
    public static var nameMaximumLength: Int
    {
        return XSAtomicKit_SEM_NAME_MAX
    }
    
    /**
     * Whether the semaphore is named.  
     * Note that named semaphores are shared accross different processes.
     */
    public private( set ) var isNamed: Bool
    
    /**
     * The name of the semaphore, if any.  
     * Note that named semaphores are shared accross different processes.
     */
    public private( set ) var name: String?
    
    /**
     * `Semaphore` errors.
     */
    public enum Error: Swift.Error
    {
        /**
         * Invalid semaphore count.  
         * This might be thrown when initializing a semaphore object with
         * a negative value or zero as count.
         */
        case InvalidSemaphoreCount
        
        /**
         * Invalid semaphore name.  
         * This might be thrown when initializing a semaphore object with
         * an invalid name, or a name which is too long.
         */
        case InvalidSemaphoreName
        
        /**
         * Thrown when a failure occurs trying to initialize the native
         * semaphore type.
         */
        case CannotCreateSemaphore
    }
    
    /**
     * Initializes a semaphore object.
     * 
     * - parameter count:   The count for the semaphore. Greater than zero.
     * - parameter name:    An optional name for the semaphore.  
     *                      Note that named semaphores are shared accross
     *                      different processes.
     * - throws:            `Semaphore.Error` on failure.
     */
    public init( count: Int32 = 1, name: String? = nil ) throws
    {
        if( count <= 0 )
        {
            throw Error.InvalidSemaphoreCount
        }
        
        if( name != nil && name?.utf8.count == 0 )
        {
            throw Error.InvalidSemaphoreName
        }
        
        if( name != nil && ( name?.utf8.count )! > XSAtomicKit_SEM_NAME_MAX )
        {
            throw Error.InvalidSemaphoreName
        }
        
        self.isNamed = name != nil
        self.name    = name
        
        if( name != nil && name?.hasPrefix( "/" ) == false )
        {
            self.name = "/" + name!
        }
        
        if( self.isNamed )
        {
            let cp = name?.cString( using: .utf8 ) 
            
            if( cp == nil )
            {
                throw Error.InvalidSemaphoreName
            }
            
            self._semp = XSAtomicKit_sem_open( cp, O_CREAT, S_IRUSR | S_IWUSR, count )
            
            if( self._semp == nil )
            {
                throw Error.CannotCreateSemaphore
            }
        }
        else
        {
            self._semaphore = semaphore_t()
            
            if( semaphore_create( mach_task_self_, &( self._semaphore! ), SYNC_POLICY_FIFO, count ) != KERN_SUCCESS )
            {
                throw Error.CannotCreateSemaphore
            }
        }
    }
    
    deinit
    {
        if( self.isNamed )
        {
            sem_close( self._semp )
        }
        else
        {
            semaphore_destroy( mach_task_self_, self._semaphore! )
        }
    }
    
    /**
     * Locks the semaphore.
     */
    public func wait()
    {
        if( self.isNamed )
        {
            sem_wait( self._semp )
        }
        else
        {
            semaphore_wait( self._semaphore! )
        }
    }
    
    /**
     * Signals (unlocks) the semaphore.
     */
    public func signal()
    {
        if( self.isNamed )
        {
            sem_post( self._semp )
        }
        else
        {
            semaphore_signal( self._semaphore! )
        }
    }
    
    /**
     * Tries to lock the semaphore.
     * 
     * - returns:   `true` if the semaphore was successfully locked, otherwise `false`.
     */
    public func tryWait() -> Bool
    {
        if( self.isNamed )
        {
            return sem_trywait( self._semp ) == 0
        }
        else
        {
            var ts = mach_timespec_t()
            
            ts.tv_sec  = 0
            ts.tv_nsec = 0
            
            return semaphore_timedwait( self._semaphore!, ts ) == KERN_SUCCESS
        }
    }
    
    private var _semp:      UnsafeMutablePointer< sem_t >?
    private var _semaphore: semaphore_t?
}
