//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap
{
	import robotlegs.bender.core.api.IContext;
	import robotlegs.bender.core.api.IContextExtension;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.impl.SignalCommandMap;

	public class SignalCommandMapExtension implements IContextExtension
	{
		private var context:IContext;

		public function install(context:IContext):void
		{
			this.context = context;
			context.injector.map(ISignalCommandMap).toSingleton(SignalCommandMap);
		}

		public function initialize():void
		{
			context.injector.getInstance(ISignalCommandMap);
		}

		public function uninstall():void
		{
			context.injector.unmap(ISignalCommandMap);
		}
	}
}
