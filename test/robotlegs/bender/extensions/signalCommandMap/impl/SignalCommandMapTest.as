//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import org.hamcrest.assertThat;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.notNullValue;
	import org.swiftsuspenders.Injector;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandMapper;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandUnmapper;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.support.NullCommand;
	import robotlegs.bender.extensions.signalCommandMap.support.NullSignal;
	import robotlegs.bender.extensions.signalCommandMap.support.TestSignal;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	public class SignalCommandMapTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var injector:Injector;

		private var signalCommandMap:ISignalCommandMap;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			const context:IContext = new Context();
			injector = context.injector;
			signalCommandMap = new SignalCommandMap(context);
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function map_creates_mapper():void
		{
			assertThat(signalCommandMap.map(TestSignal), notNullValue());
		}

		[Test]
		public function test_map_returns_new_mapper_when_identical_signal():void
		{
			var mapper:ICommandMapper = signalCommandMap.map(NullSignal);
			assertThat(signalCommandMap.map(NullSignal), not(equalTo(mapper)));
		}

		[Test]
		public function test_unmap_returns_unmapper():void
		{
			var mapper:ICommandUnmapper = signalCommandMap.unmap(NullSignal);
			assertThat(mapper, instanceOf(ICommandUnmapper));
		}

		[Test]
		public function test_robust_unmapping_non_existent_mappings():void
		{
			signalCommandMap.unmap(NullSignal).fromCommand(NullCommand);
		}
	}
}
