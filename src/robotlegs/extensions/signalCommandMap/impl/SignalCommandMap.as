//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.extensions.signalCommandMap.impl
{
	import flash.utils.Dictionary;
	
	import org.osflash.signals.ISignal;
	import org.swiftsuspenders.Injector;
	
	import robotlegs.bender.extensions.commandMap.api.ICommandMap;
	import robotlegs.bender.extensions.commandMap.dsl.ICommandMapper;
	import robotlegs.bender.extensions.commandMap.dsl.ICommandMappingFinder;
	import robotlegs.bender.extensions.commandMap.dsl.ICommandUnmapper;
	import robotlegs.bender.extensions.commandMap.api.ICommandTrigger;
	
	import robotlegs.extensions.signalCommandMap.api.ISignalCommandMap;

	public class SignalCommandMap implements ISignalCommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const signalTriggers:Dictionary = new Dictionary();

		private var injector:Injector;
		
		private var commandMap:ICommandMap;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function SignalCommandMap(injector:Injector, commandMap:ICommandMap)
		{
			this.injector = injector;
			this.commandMap = commandMap;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function map(signalClass:Class, once:Boolean = false):ICommandMapper
		{
			const trigger:ICommandTrigger =
				signalTriggers[signalClass] ||=
				createSignalTrigger(signalClass, once);
			return commandMap.map(trigger);
		}

		public function unmap(signalClass:Class):ICommandUnmapper
		{
			return commandMap.unmap(getSignalTrigger(signalClass));
		}

		public function getMapping(signalClass:Class):ICommandMappingFinder
		{
			const trigger:ICommandTrigger = getSignalTrigger(signalClass);
			return commandMap.getMapping(trigger);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createSignalTrigger(signalClass:Class, once:Boolean = false):ICommandTrigger
		{
			return new SignalCommandTrigger(injector, signalClass, once);
		}

		private function getSignalTrigger(signalClass:Class):ICommandTrigger
		{
			return signalTriggers[signalClass];
		}
	}
}
