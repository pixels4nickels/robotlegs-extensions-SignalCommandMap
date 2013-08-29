//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import mockolate.received;
	import mockolate.runner.MockolateRule;

	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.RobotlegsInjector;

	public class SignalCommandTriggerTest
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var signal:ISignal;

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var subject:SignalCommandTrigger;

		private var injector:IInjector;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			injector = new RobotlegsInjector();
			injector.map(ISignal).toValue(signal);
			subject = new SignalCommandTrigger(injector, ISignal);
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function test_activate_adds_a_listener():void
		{
			subject.activate();

			assertThat(signal, received().method('add').arg(instanceOf(Function)).once());
		}

		[Test]
		public function test_deactivate_removes_listener():void
		{
			subject.activate();

			subject.deactivate();

			assertThat(signal, received().method('remove').arg(instanceOf(Function)).once());
		}

		[Test]
		public function test_doesnt_throw_error_when_deactivating_without_signal():void
		{
			subject.deactivate();
			// note: no assertion. we just want to know if an error is thrown
		}
	}
}
