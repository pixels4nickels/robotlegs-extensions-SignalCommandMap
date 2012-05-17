//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IContextExtension;
	import robotlegs.bender.framework.impl.UID;

	public class SignalCommandMapExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create( SignalCommandMapExtension );

		private var _context:IContext;

		private var _injector:Injector;

		private var _signalCommandMap:ISignalCommandMap;

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend( context:IContext ):void
		{

			_context = context;
			_injector = context.injector;
			_injector.map( ISignalCommandMap ).toSingleton( SignalCommandMap );
			_context.lifecycle.beforeInitializing( handleContextPreInitialize );

		}

		private function handleContextPreInitialize():void
		{
			_signalCommandMap = _injector.getInstance( ISignalCommandMap );
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
