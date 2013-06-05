//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.extensions.commandCenter.api.ICommandTrigger;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandMapper;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandUnmapper;
	import robotlegs.bender.extensions.commandCenter.impl.CommandTriggerMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class SignalCommandMap implements ISignalCommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _mappingProcessors:Array = [];

		private var _injector:IInjector;

		private var _triggerMap:CommandTriggerMap;

		private var _logger:ILogger;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function SignalCommandMap(context:IContext)
		{
			_injector = context.injector;
			_logger = context.getLogger(this);
			_triggerMap = new CommandTriggerMap(getKey, createTrigger);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function map(signalClass:Class):ICommandMapper
		{
			return getTrigger(signalClass).createMapper();
		}

		/**
		 * @inheritDoc
		 */
		public function unmap(signalClass:Class):ICommandUnmapper
		{
			return getTrigger(signalClass).createMapper();
		}

		public function addMappingProcessor(handler:Function):ISignalCommandMap
		{
			if (_mappingProcessors.indexOf(handler) == -1)
				_mappingProcessors.push(handler);
			return this;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createTrigger(signalClass:Class):ICommandTrigger
		{
			return new SignalCommandTrigger(_injector, signalClass, _mappingProcessors);
		}

		private function getTrigger(signalClass:Class):SignalCommandTrigger
		{
			return _triggerMap.getTrigger(signalClass) as SignalCommandTrigger;
		}

		private function getKey(signalClass:Class):Object
		{
			return signalClass;
		}
	}
}
