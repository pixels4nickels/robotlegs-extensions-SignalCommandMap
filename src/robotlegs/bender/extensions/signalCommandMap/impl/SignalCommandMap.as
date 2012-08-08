//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import flash.utils.Dictionary;

	import org.osflash.signals.ISignal;
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.commandCenter.api.ICommandCenter;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandMapper;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandUnmapper;
	import robotlegs.bender.extensions.commandCenter.api.ICommandTrigger;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class SignalCommandMap implements ISignalCommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _signalTriggers:Dictionary = new Dictionary();

		private var _injector:Injector;

		private var _commandMap:ICommandCenter;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function SignalCommandMap( injector:Injector, commandMap:ICommandCenter )
		{
			_injector = injector;
			_commandMap = commandMap;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function map( signalClass:Class, once:Boolean=false ):ICommandMapper
		{
			const trigger:ICommandTrigger =
				_signalTriggers[ signalClass ] ||=
				createSignalTrigger( signalClass, once );
			return _commandMap.map( trigger );
		}

		public function unmap( signalClass:Class ):ICommandUnmapper
		{
			return _commandMap.unmap( getSignalTrigger( signalClass ));
		}


		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createSignalTrigger( signalClass:Class, once:Boolean=false ):ICommandTrigger
		{
			return new SignalCommandTrigger( _injector, signalClass, once );
		}

		private function getSignalTrigger( signalClass:Class ):ICommandTrigger
		{
			return _signalTriggers[ signalClass ];
		}
	}
}
