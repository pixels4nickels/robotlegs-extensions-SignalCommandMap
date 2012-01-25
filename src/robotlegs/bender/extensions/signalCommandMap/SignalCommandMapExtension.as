//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMap;
	import robotlegs.bender.framework.context.api.IContext;
	import robotlegs.bender.framework.context.api.IContextConfig;

	public class SignalCommandMapExtension implements IContextConfig
	{
		private var context:IContext;

		public function configureContext(context:IContext):void
		{
			this.context = context;
			context.injector.map(ISignalCommandMap).toSingleton(SignalCommandMap);
		}
		
		private function handleContextPreInitialize(step:String, callback:Function):void
		{
			//trace("Doing some things before the context self initializes...");
			//setTimeout(callback, 1000);
		}
		
		private function handleContextPostInitialize():void
		{
			trace("Doing some things now that the context is initialized...");
			context.injector.getInstance(ISignalCommandMap);
		}
/*
		public function initialize():void
		{
			context.injector.getInstance(ISignalCommandMap);
		}

		public function uninstall():void
		{
			context.injector.unmap(ISignalCommandMap);
		}*/
	}
}
