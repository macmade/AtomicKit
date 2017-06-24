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
 * @file        main.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import Foundation
import AtomicKit

print( "Test-Helper: starting" )

let argc = ProcessInfo.processInfo.arguments.count
let argv = ProcessInfo.processInfo.arguments

for i in 0 ... argc
{
    let arg = argv[ i ]
    
    if( arg == "sem-wait" || arg == "sem-signal" )
    {
        if( i >= argc - 2 )
        {
            print( "Test-Helper: not enough arguments provided for \(arg)" )
            exit( -1 )
        }
        
        let count = Int32( argv[ i + 1 ] )
        let name  = argv[ i + 2 ]
        
        if( count == nil )
        {
            print( "Test-Helper: invalid argument for semaphore count" )
            exit( -1 )
        }
        
        let sem = try? Semaphore( count: count!, name: name )
        
        if( sem == nil )
        {
            print( "Test-Helper: cannot create semaphore" )
            exit( -1 )
        }
        
        if( arg == "sem-wait" )
        {
            print( "Test-Helper: wait on \( sem!.name ?? "" ) (\( count! ))" )
            sem!.wait()
        }
        else
        {
            print( "Test-Helper: signal on \( sem!.name ?? "" ) (\( count! ))" )
            sem!.signal()
        }
        
        break;
    }
}

print( "Test-Helper: exiting" )
