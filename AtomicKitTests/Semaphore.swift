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
 * @file        Semaphore.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import XCTest
import AtomicKit

class SemaphoreTest: XCTestCase
{
    var testHelper: String?
    
    override func setUp()
    {
        super.setUp()
        
        let bundle = Bundle( identifier: "com.xs-labs.AtomicKitTests" )
        
        if( bundle == nil || bundle?.executableURL == nil )
        {
            XCTFail( "Invalid bundle" )
        }
        
        let url = bundle?.executableURL?.deletingLastPathComponent().appendingPathComponent( "Test-Helper" )
        
        if( url == nil || FileManager.default.fileExists( atPath: url!.path ) == false )
        {
            XCTFail( "Cannot find Test-Helper executable" )
        }
        
        self.testHelper = url!.path
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func runHelper( command: String, args: [ String ] )
    {
        self.runHelper( commands: [ command : args ] )
    }
    
    func runHelper( commands: [ String : [ String ] ] )
    {
        var args = [ String ]()
        
        if( self.testHelper == nil )
        {
            XCTFail( "Cannot find Test-Helper executable" )
        }
        
        for p in commands
        {
            args.append( p.key )
            args.append( contentsOf: p.value )
        }
        
        let task = Process.launchedProcess( launchPath: self.testHelper!, arguments: args )
        
        task.waitUntilExit()
    }
    
    func testUnnamedBinaryTryWait()
    {
        let sem = try? Semaphore()
        
        XCTAssertNotNil( sem )
        XCTAssertTrue( sem!.tryWait() )
        XCTAssertFalse( sem!.tryWait() )
        
        sem!.signal()
    }
    
    func testNamedBinaryTryWait()
    {
        let sem1 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        let sem2 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        
        XCTAssertNotNil( sem1 )
        XCTAssertNotNil( sem2 )
        
        XCTAssertTrue(  sem1!.tryWait() )
        XCTAssertFalse( sem1!.tryWait() )
        XCTAssertFalse( sem2!.tryWait() )
        
        sem1!.signal()
        
        XCTAssertTrue(  sem2!.tryWait() )
        XCTAssertFalse( sem2!.tryWait() )
        XCTAssertFalse( sem1!.tryWait() )
        
        sem2!.signal()
    }
    
    func testUnnamedTryWait()
    {
        let sem = try? Semaphore( count: 2 )
        
        XCTAssertNotNil( sem )
        XCTAssertTrue(  sem!.tryWait() )
        XCTAssertTrue(  sem!.tryWait() )
        XCTAssertFalse( sem!.tryWait() )
        
        sem!.signal()
        sem!.signal()
    }
    
    func testNamedTryWait()
    {
        let sem1 = try? Semaphore( count: 2, name: "XS-Test-Semaphore-2" )
        let sem2 = try? Semaphore( count: 2, name: "XS-Test-Semaphore-2" )
        
        XCTAssertNotNil( sem1 )
        XCTAssertNotNil( sem2 )
        
        XCTAssertTrue(  sem1!.tryWait() )
        XCTAssertTrue(  sem1!.tryWait() )
        XCTAssertFalse( sem1!.tryWait() )
        XCTAssertFalse( sem2!.tryWait() )
        
        sem1!.signal()
        
        XCTAssertTrue(  sem2!.tryWait() )
        XCTAssertFalse( sem1!.tryWait() )
        
        sem1!.signal()
        sem2!.signal()
    }
    
    func testUnnamedWaitSignal()
    {
        let sem = try? Semaphore( count: 1 )
        
        XCTAssertNotNil( sem )
        sem!.wait()
        XCTAssertFalse( sem!.tryWait() )
        sem!.signal()
        XCTAssertTrue( sem!.tryWait() )
        sem!.signal()
    }
    
    func testNamedWaitSignal()
    {
        let sem1 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        let sem2 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        
        XCTAssertNotNil( sem1 )
        XCTAssertNotNil( sem2 )
        
        sem1!.wait()
        
        XCTAssertFalse( sem1!.tryWait() )
        XCTAssertFalse( sem2!.tryWait() )
        
        sem1!.signal()
        
        XCTAssertTrue(  sem2!.tryWait() )
        XCTAssertFalse( sem1!.tryWait() )
        
        sem2!.signal()
    }

    func testUnnamedThrowOnInvalidCount()
    {
        XCTAssertThrowsError( try Semaphore( count: 0 ) );
    }

    func testNamedThrowOnInvalidCount()
    {
        XCTAssertThrowsError( try Semaphore( count: 0, name: "XS-Test-Semaphore-0" ) );
    }
    
    func testNamedThrowOnInvalidName()
    {
        var name = "XS-Test-Semaphore-"
        
        for _ in 0 ... 256
        {
            name += "X";
        }
        
        XCTAssertThrowsError( try Semaphore( count: 1, name:name ) );
    }
    
    func testIsNamed()
    {
        let sem1 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        let sem2 = try? Semaphore()
        
        XCTAssertNotNil( sem1 )
        XCTAssertNotNil( sem2 )
        XCTAssertTrue(   sem1!.isNamed );
        XCTAssertFalse(  sem2!.isNamed );
    }
    
    func testGetName()
    {
        let sem1 = try? Semaphore( count: 1, name: "XS-Test-Semaphore-1" )
        let sem2 = try? Semaphore()
        
        XCTAssertNotNil( sem1 )
        XCTAssertNotNil( sem2 )
        XCTAssertEqual( sem1!.name, "/XS-Test-Semaphore-1" )
        XCTAssertEqual( sem2!.name, nil )
    }
}
