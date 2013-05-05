//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import flexunit.framework.Assert;
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.object.instanceOf;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.impl.Context;

	public class SignalCommandMapExtensionTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var context:Context;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			context = new Context();
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function signalCommandMap_is_mapped_into_injector():void
		{
			var actual:Object = null;
			context.install(SignalCommandMapExtension);
			context.whenInitializing(function():void {
				actual = context.injector.getInstance(ISignalCommandMap);
			});
			context.initialize();
			assertThat(actual, instanceOf(ISignalCommandMap));
		}

		[Test]
		public function chainedInjectionsPassThroughInjectionTargets():void
		{
			context.install(SignalCommandMapExtension);
			context.initialize();

			var instance:ISignalCommandMap = context.injector.getInstance(ISignalCommandMap);
			instance.map(RelaySignal).toCommand(RelayCommand);
			instance.map(TargetSignal).toCommand(TargetCommand);

			TargetCommand.TARGET_VALUE = 0;
			context.injector.getInstance(RelaySignal).dispatch(new Data(3));
			assertEquals(TargetCommand.TARGET_VALUE, 3);
		}
	}
}

import org.osflash.signals.Signal;

class Data
{

	/*============================================================================*/
	/* Public Properties                                                          */
	/*============================================================================*/

	public var value:int;

	/*============================================================================*/
	/* Constructor                                                                */
	/*============================================================================*/

	public function Data(value:int)  { this.value = value; }
}

class RelaySignal extends Signal
{

	/*============================================================================*/
	/* Constructor                                                                */
	/*============================================================================*/

	public function RelaySignal()  { super(Data); }
}

class RelayCommand
{

	/*============================================================================*/
	/* Public Properties                                                          */
	/*============================================================================*/

	[Inject]
	public var data:Data;

	[Inject]
	public var signal:TargetSignal;

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function execute():void  { signal.dispatch(data); }
}

class TargetSignal extends Signal
{

	/*============================================================================*/
	/* Constructor                                                                */
	/*============================================================================*/

	public function TargetSignal()  { super(Data); }
}

class TargetCommand
{

	/*============================================================================*/
	/* Public Static Properties                                                   */
	/*============================================================================*/

	public static var TARGET_VALUE:int;

	/*============================================================================*/
	/* Public Properties                                                          */
	/*============================================================================*/

	[Inject]
	public var data:Data;

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function execute():void  { TARGET_VALUE = data.value; }
}
