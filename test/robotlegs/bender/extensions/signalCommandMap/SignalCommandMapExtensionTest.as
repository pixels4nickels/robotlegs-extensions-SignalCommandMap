//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.instanceOf;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.commandCenter.CommandCenterExtension;
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
			context.extend( CommandCenterExtension );
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function signalCommandMap_is_mapped_into_injector():void
		{
			var actual:Object = null;
			context.extend( SignalCommandMapExtension );
			context.lifecycle.whenInitializing( function():void {
				actual = context.injector.getInstance( ISignalCommandMap );
			});
			context.initialize();
			assertThat( actual, instanceOf( ISignalCommandMap ));
		}
	}
}
