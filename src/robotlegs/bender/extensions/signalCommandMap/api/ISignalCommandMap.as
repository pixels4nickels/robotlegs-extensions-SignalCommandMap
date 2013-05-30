//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.signalCommandMap.api
{
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandMapper;
	import robotlegs.bender.extensions.commandCenter.dsl.ICommandUnmapper;



	/**
	 * The Signal Command Map allows you to bind Signals to Commands
	 */
	public interface ISignalCommandMap
	{

		/**
		 * Creates a mapping for a Signal based trigger
		 * @param signalClass The concrete Signal class
		 * @return Command mapper
		 */
		function map( signalClass:Class ):ICommandMapper;

		/**
		 * Unmaps a Signal based trigger from a command
		 * @param signalClass The concrete Signal class
		 * @return Command unmapper
		 */
		function unmap( signalClass:Class ):ICommandUnmapper;

		/**
		 * Adds a handler to process mappings
		 * @param handler Function that accepts a mapping
		 * @return Self
		 */
		function addMappingProcessor(handler:Function):ISignalCommandMap;
	}
}
