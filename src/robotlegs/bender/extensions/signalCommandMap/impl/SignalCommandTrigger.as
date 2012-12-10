//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.impl
{
import flash.utils.Dictionary;
import flash.utils.describeType;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;
import org.swiftsuspenders.Injector;

import robotlegs.bender.extensions.commandCenter.api.ICommandMapping;
import robotlegs.bender.extensions.commandCenter.api.ICommandTrigger;
import robotlegs.bender.framework.impl.applyHooks;
import robotlegs.bender.framework.impl.guardsApprove;

public class SignalCommandTrigger implements ICommandTrigger
{

    /*============================================================================*/
    /* Private Properties                                                         */
    /*============================================================================*/

    private const _mappings:Vector.<ICommandMapping> = new Vector.<ICommandMapping>;

    private var _signal:ISignal;

    private var _signalClass:Class;

    private var _once:Boolean;

    /*============================================================================*/
    /* Protected Properties                                                         */
    /*============================================================================*/

    protected var _injector:Injector;

    protected var _signalMap:Dictionary;

    protected var _verifiedCommandClasses:Dictionary;

    /*============================================================================*/
    /* Constructor                                                                */
    /*============================================================================*/

    public function SignalCommandTrigger(
            injector:Injector,
            signalClass:Class,
            once:Boolean = false)
    {
        _injector = injector;
        _signalClass = signalClass;
        _once = once;

        _signalMap = new Dictionary( false );
        _verifiedCommandClasses = new Dictionary( false );
    }

    /*============================================================================*/
    /* Public Functions                                                           */
    /*============================================================================*/

    public function addMapping(mapping:ICommandMapping):void
    {
        verifyCommandClass(mapping);
        _mappings.push(mapping);
        if (_mappings.length == 1)
            addSignal(mapping.commandClass);
    }

    public function removeMapping(mapping:ICommandMapping):void
    {
        const index:int = _mappings.indexOf(mapping);
        if (index != -1)
        {
            _mappings.splice(index, 1);
            if (_mappings.length == 0)
                removeSignal(mapping.commandClass);
        }
    }

    /*============================================================================*/
    /* Protected Functions                                                          */
    /*============================================================================*/

    protected function verifyCommandClass(mapping:ICommandMapping):void
    {
        if ( _verifiedCommandClasses[mapping.commandClass] ) return;
        if (describeType(mapping.commandClass).factory.method.(@name == "execute").length() == 0)
            throw new Error("Command Class must expose an execute method");
        _verifiedCommandClasses[mapping.commandClass] = true;
    }

    protected function routeSignalToCommand(signal:ISignal, valueObjects:Array, commandClass:Class, oneshot:Boolean):void
    {
        const mappings:Vector.<ICommandMapping> = _mappings.concat();

        for each (var mapping:ICommandMapping in mappings)
        {
            mapSignalValues(signal.valueClasses, valueObjects);

            if (guardsApprove(mapping.guards, _injector))
            {
                _once && removeMapping(mapping);
                _injector.map(mapping.commandClass).asSingleton();
                const command:Object = _injector.getInstance( mapping.commandClass);
                applyHooks(mapping.hooks, _injector);
                _injector.unmap(mapping.commandClass);
                command.execute();
            }

            unmapSignalValues(signal.valueClasses, valueObjects);
        }

        if ( _once )
            removeSignal(commandClass );
    }

    protected function mapSignalValues(valueClasses:Array, valueObjects:Array):void {
        for (var i:uint = 0; i < valueClasses.length; i++) {
            _injector.map(valueClasses[i]).toValue(valueObjects[i]);
        }
    }

    protected function unmapSignalValues(valueClasses:Array, valueObjects:Array):void {
        for (var i:uint = 0; i < valueClasses.length; i++) {
            _injector.unmap(valueClasses[i]);
        }
    }

    protected function hasSignalCommand(signal:ISignal, commandClass:Class):Boolean
    {
        var callbacksByCommandClass:Dictionary = _signalMap[signal];
        if ( callbacksByCommandClass == null ) return false;
        var callback:Function = callbacksByCommandClass[commandClass];
        return callback != null;
    }

    /*============================================================================*/
    /* Private Functions                                                          */
    /*============================================================================*/

    private function addSignal(commandClass:Class):void
    {
        if ( hasSignalCommand( _signal, commandClass ) )
            return;

        _signal = _injector.getInstance( _signalClass );
        _injector.map( _signalClass).toValue( _signal );

        const signalCommandMap:Dictionary = _signalMap[_signal] ||= new Dictionary( false );
        const callback:Function = function():void
        {
            routeSignalToCommand( _signal, arguments, commandClass, _once );
        };
        signalCommandMap[commandClass] = callback;
        _signal.add( callback );
    }

    private function removeSignal(commandClass:Class):void
    {
        var callbacksByCommandClass:Dictionary = _signalMap[_signal];
        if ( callbacksByCommandClass == null ) return;
        var callback:Function = callbacksByCommandClass[commandClass];
        if ( callback == null ) return;
        _signal.remove( callback );
        delete callbacksByCommandClass[commandClass];
    }
}
}
