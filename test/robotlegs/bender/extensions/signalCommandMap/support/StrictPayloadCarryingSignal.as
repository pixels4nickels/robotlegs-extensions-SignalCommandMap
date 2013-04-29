//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.support
{
	import org.osflash.signals.Signal;

	public class StrictPayloadCarryingSignal extends Signal
	{

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function StrictPayloadCarryingSignal()
		{
			super(Payload);
		}
	}
}
