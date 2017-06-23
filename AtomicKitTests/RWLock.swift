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

import XCTest
import AtomicKit
import STDThreadKit

class RWLockTest: XCTestCase
{
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testSingleReader()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .reading ) );
        
        l!.unlock( for: .reading );
    }
    
    func testSingleWriter()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .writing ) );
        
        l!.unlock( for: .writing );
    }
    
    func testMultipleReaders_SameThread()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .reading ) );
        XCTAssertTrue( l!.tryLock( for: .reading ) );
        
        l!.unlock( for: .reading );
        l!.unlock( for: .reading );
    }
    
    func testMultipleWriters_SameThread()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .writing ) );
        XCTAssertTrue( l!.tryLock( for: .writing ) );
        
        l!.unlock( for: .writing );
        l!.unlock( for: .writing );
    }
    
    func testReadWrite_SameThread()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .reading ) );
        XCTAssertTrue( l!.tryLock( for: .writing ) );
        
        l!.unlock( for: .reading );
        l!.unlock( for: .writing );
    }
    
    func testWriteRead_SameThread()
    {
        let l = try? RWLock()
        
        XCTAssertNotNil( l )
        XCTAssertTrue( l!.tryLock( for: .writing ) );
        XCTAssertTrue( l!.tryLock( for: .reading ) );
        
        l!.unlock( for: .writing );
        l!.unlock( for: .reading );
    }
    
    func testMultipleReaders_DifferentThreads()
    {
        let l = try? RWLock()
        var b = false
        
        XCTAssertNotNil( l )
        
        l!.lock( for: .reading )
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .reading )
            
            if( b )
            {
                l!.unlock( for: .reading )
            }
        }
        .join()
        
        XCTAssertTrue( b )
        l!.unlock( for: .reading );
    }
    
    func testMultipleWriters_DifferentThreads()
    {
        let l = try? RWLock()
        var b = false
        
        XCTAssertNotNil( l )
        
        l!.lock( for: .writing )
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .writing )
            
            if( b )
            {
                l!.unlock( for: .writing )
            }
        }
        .join()
        
        XCTAssertFalse( b );
        
        l!.unlock( for: .writing );
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .writing )
            
            if( b )
            {
                l!.unlock( for: .writing )
            }
        }
        .join()
        
        XCTAssertTrue( b );
    }
    
    func testReadWrite_DifferentThreads()
    {
        let l = try? RWLock()
        var b = false
        
        XCTAssertNotNil( l )
        
        l!.lock( for: .reading )
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .writing )
            
            if( b )
            {
                l!.unlock( for: .writing )
            }
        }
        .join()
        
        XCTAssertFalse( b );
        
        l!.unlock( for: .reading );
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .writing )
            
            if( b )
            {
                l!.unlock( for: .writing )
            }
        }
        .join()
        
        XCTAssertTrue( b );
    }
      
    func testWriteRead_DifferentThreads()
    {
        let l = try? RWLock()
        var b = false
        
        XCTAssertNotNil( l )
        
        l!.lock( for: .writing );
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .reading )
            
            if( b )
            {
                l!.unlock( for: .reading )
            }
        }
        .join()
        
        XCTAssertFalse( b );
        
        l!.unlock( for: .writing );
        
        let _ = try? STDThread
        {
            b = l!.tryLock( for: .reading )
            
            if( b )
            {
                l!.unlock( for: .reading )
            }
        }
        .join()
        
        XCTAssertTrue( b );
    }
}
