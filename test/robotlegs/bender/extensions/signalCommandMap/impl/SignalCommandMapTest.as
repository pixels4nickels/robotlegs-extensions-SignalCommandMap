//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{

	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	import org.swiftsuspenders.Injector;
	import robotlegs.bender.extensions.commandMap.api.ICommandMap;
	import robotlegs.bender.extensions.commandMap.impl.CommandMap;
	import robotlegs.bender.extensions.signalCommandMap.support.NullCommand;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.support.TestSignal;

	public class SignalCommandMapTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var injector:Injector;

		private var commandMap:ICommandMap;

		private var signalCommandMap:ISignalCommandMap;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			injector = new Injector();
			commandMap = new CommandMap();
			signalCommandMap = new SignalCommandMap( injector, commandMap );
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function mapEvent_creates_mapper():void
		{
			assertThat( signalCommandMap.map( TestSignal, false ), notNullValue());
		}

		[Test]
		public function mapSignal_to_command_stores_mapping():void
		{
			signalCommandMap.map( TestSignal ).toCommand( NullCommand );
			assertThat( signalCommandMap.getMapping( TestSignal ).forCommand( NullCommand ), notNullValue());
		}

		[Test]
		public function unmapSignal_from_command_removes_mapping():void
		{
			signalCommandMap.map( TestSignal ).toCommand( NullCommand );
			signalCommandMap.unmap( TestSignal ).fromCommand( NullCommand );
			assertThat( signalCommandMap.getMapping( TestSignal ).forCommand( NullCommand ), nullValue());
		}
	}
}
