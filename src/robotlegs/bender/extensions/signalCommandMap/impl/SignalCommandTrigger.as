//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import org.osflash.signals.ISignal;

	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.extensions.commandCenter.api.ICommandExecutor;
	import robotlegs.bender.extensions.commandCenter.api.ICommandTrigger;
	import robotlegs.bender.extensions.commandCenter.impl.CommandExecutor;
	import robotlegs.bender.extensions.commandCenter.impl.CommandMapper;
	import robotlegs.bender.extensions.commandCenter.impl.CommandMappingList;
	import robotlegs.bender.extensions.commandCenter.api.CommandPayload;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class SignalCommandTrigger implements ICommandTrigger
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _signalClass:Class;

		private var _signal:ISignal;

		private var _injector:IInjector;

		private var _mappings:CommandMappingList;

		private var _executor:ICommandExecutor;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function SignalCommandTrigger(
			injector:IInjector,
			signalClass:Class,
			processors:Array = null,
			logger:ILogger = null)
		{
			_injector = injector;

			_signalClass = signalClass;
			_mappings = new CommandMappingList(this, processors, logger);
			_executor = new CommandExecutor(injector, _mappings.removeMapping);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function createMapper():CommandMapper
		{
			return new CommandMapper(_mappings);
		}

		/**
		 * @inheritDoc
		 */
		public function activate():void
		{
			if (!_injector.hasMapping(_signalClass))
				_injector.map(_signalClass).asSingleton();
			_signal = _injector.getInstance(_signalClass);
			_signal.add(routePayloadToCommands);
		}

		/**
		 * @inheritDoc
		 */
		public function deactivate():void
		{
			if (_signal)
				_signal.remove(routePayloadToCommands);
		}

		public function toString():String
		{
			return String(_signalClass);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function routePayloadToCommands(... valueObjects):void
		{
			const payload:CommandPayload = new CommandPayload(valueObjects, _signal.valueClasses);
			_executor.executeCommands(_mappings.getList(), payload);
		}
	}
}
