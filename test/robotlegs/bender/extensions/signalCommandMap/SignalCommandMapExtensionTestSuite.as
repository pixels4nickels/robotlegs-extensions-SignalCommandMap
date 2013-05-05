//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMapIntegrationTest;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMapTest;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandTriggerTest;

	[RunWith("org.flexunit.runners.Suite")]
	[Suite]
	public class SignalCommandMapExtensionTestSuite
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		public var signalCommandMapExtension:SignalCommandMapExtensionTest;

		public var signalCommandMap:SignalCommandMapTest;

		public var signalCommandMapIntegration:SignalCommandMapIntegrationTest;

		public var signalCommandTrigger:SignalCommandTriggerTest;
	}
}
