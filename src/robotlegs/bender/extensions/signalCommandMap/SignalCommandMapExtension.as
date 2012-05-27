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
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.IExtension;
import robotlegs.bender.framework.impl.UID;

public class SignalCommandMapExtension implements IExtension
{

    /*============================================================================*/
    /* Private Properties                                                         */
    /*============================================================================*/

    private const _uid:String = UID.create(SignalCommandMapExtension);

    /*============================================================================*/
    /* Public Functions                                                           */
    /*============================================================================*/

    public function extend(context:IContext):void
    {
        context.injector.map(ISignalCommandMap).toSingleton(SignalCommandMap);
    }

    public function toString():String
    {
        return _uid;
    }
}
}
