//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import org.swiftsuspenders.Injector;
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

		private var _injector:Injector;

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

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createTrigger(signalClass:Class):ICommandTrigger
		{
			return new SignalCommandTrigger(_injector, signalClass);
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
