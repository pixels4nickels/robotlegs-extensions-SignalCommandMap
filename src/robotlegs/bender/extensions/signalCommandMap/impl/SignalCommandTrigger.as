//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
	import flash.utils.describeType;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.commandMap.api.ICommandMapping;
	import robotlegs.bender.extensions.commandMap.api.ICommandTrigger;
	import robotlegs.bender.framework.impl.applyHooks;
	import robotlegs.bender.framework.impl.guardsApprove;

	public class SignalCommandTrigger implements ICommandTrigger
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var _injector:Injector;

		public function get injector():Injector
		{
			return _injector;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _mappings:Vector.<ICommandMapping> = new Vector.<ICommandMapping>;

		private var _signal:ISignal;

		private var _signalClass:Class;

		private var _once:Boolean;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function SignalCommandTrigger(
			injector:Injector,
			signalClass:Class,
			once:Boolean=false )
		{
			_injector = injector;
			_signalClass = signalClass;
			_once = once;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function addMapping( mapping:ICommandMapping ):void
		{
			verifyCommandClass( mapping );
			_mappings.push( mapping );
			if ( _mappings.length == 1 )
				createSignalClassInstance( mapping.commandClass );
		}

		public function removeMapping( mapping:ICommandMapping ):void
		{
			const index:int = _mappings.indexOf( mapping );
			if ( index != -1 )
			{
				_mappings.splice( index, 1 );
				if ( _mappings.length == 0 )
					unmapSignalArguments();
			}
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function verifyCommandClass( mapping:ICommandMapping ):void
		{
			if ( describeType( mapping.commandClass ).factory.method.( @name == "execute" ).length() == 0 )
				throw new Error( "Command Class must expose an execute method" );
		}

		private function createSignalClassInstance( commandClass:Class ):void
		{
			_signal = _injector.getInstance( _signalClass );
			// chk to see if the signal is already registered with the injector
			// maybe a better way to do this.
			try
			{
				_injector.getMapping( _signalClass );
			}
			catch ( e:Error )
			{
				_injector.map( _signalClass ).toValue( _signal );
			}

			_signal.add(
				function( a:*=null, b:*=null, c:*=null, d:*=null, e:*=null, f:*=null, g:*=null ):void
				{
					routeSignalToCommand( _signal, arguments, commandClass, _once );
				}
				);
		}

		private function routeSignalToCommand( signal:ISignal, valueObjects:Array, commandClass:Class, oneshot:Boolean ):void
		{

			// run past the guards and hooks, and execute
			const mappings:Vector.<ICommandMapping> = _mappings.concat();
			for each ( var mapping:ICommandMapping in mappings )
			{
				if ( guardsApprove( mapping.guards, _injector ))
				{
					_once && removeMapping( mapping );
					_injector.map( mapping.commandClass ).asSingleton();
					const command:Object = createCommandInstance( signal.valueClasses, valueObjects, commandClass );
					applyHooks( mapping.hooks, _injector );
					_injector.unmap( mapping.commandClass );
					command.execute();
				}
			}
			// unmap properties after injecting  into command
			unmapSignalArguments();
		}

		private function unmapSignalArguments():void
		{
			for ( var i:uint = 0; i < _signal.valueClasses.length; i++ )
			{
				_injector.unmap( _signal.valueClasses[ i ]);
			}
		}

		private function createCommandInstance( valueClasses:Array, valueObjects:Array, commandClass:Class ):Object
		{
			for ( var i:uint = 0; i < valueClasses.length; i++ )
			{
				_injector.map( valueClasses[ i ]).toValue( valueObjects[ i ]);
			}
			return _injector.getInstance( commandClass );
		}
	}
}
