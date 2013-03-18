package robotlegs.bender.extensions.signalCommandMap.impl
{
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.commandCenter.impl.CommandCenter;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.extensions.signalCommandMap.support.NullCommand;
	import robotlegs.bender.extensions.signalCommandMap.support.PayloadCarryingSignal;
	import robotlegs.bender.extensions.signalCommandMap.support.SupportSignal;
	import robotlegs.bender.extensions.signalCommandMap.support.SupportSignal2;

	/**
	 * All commands, hooks and guards are declared as internal classes at the bottom
	 * of this file
	 */
	public class SignalCommandMapIntegrationTest{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var injector:Injector;

		private var signalCommandMap:ISignalCommandMap;

		private var reportedExecutions:Array;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before() : void{
			reportedExecutions = [];
			injector = new Injector();
			injector.map(Injector).toValue(injector);
			injector.map(Function, "reportingFunction").toValue(reportingFunction);
			signalCommandMap = new SignalCommandMap(injector, new CommandCenter());
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function test_self() : void{
			assertThat( true, equalTo( true ) );
		}

		[Test]
		public function test_command_executes_successfully():void
		{
			assertThat(commandExecutionCount(1), equalTo(1));
		}

		[Test]
		public function test_command_executes_repeatedly():void
		{
			assertThat(commandExecutionCount(5), equalTo(5));
		}

		[Test]
		public function test_fireOnce_command_executes_once():void
		{
			assertThat(oneshotCommandExecutionCount(5), equalTo(1));
		}

		[Test]
		public function test_payload_is_injected_into_command() : void{
			var injected : Object;
			injector.map(Function, 'executeCallback').toValue(function(command:PayloadInjectedCallbackCommand):void
			{
				injected = command.payload;
			});
			signalCommandMap.map( PayloadCarryingSignal ).toCommand( PayloadInjectedCallbackCommand );
			var payload : Object = {};
			var signal : Signal = injector.getInstance( PayloadCarryingSignal );
			signal.dispatch(payload );
			assertThat( injected, equalTo( payload ) );
		}

		[Test]
		public function test_only_commands_mapped_to_dispatching_signal_are_executed():void
		{
			var executeCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue( reportingFunction );
			signalCommandMap.map( SupportSignal ).toCommand(ReportingCommand);
			signalCommandMap.map( SupportSignal2 ).toCommand(ReportingCommand2);
			var expected : Array = [ ReportingCommand2 ];
			var signal : Signal  =injector.getInstance( SupportSignal2 );
			signal.dispatch();
			assertThat( reportedExecutions, array( expected ) );
		}

		[Test]
		public function test_command_does_not_execute_after_signal_unmapped():void
		{
			var executeCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue(function(item : Object, itemClass:Class):void
			{
				executeCount++;
			});
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand);
			signalCommandMap.unmap(SupportSignal).fromCommand(ReportingCommand);
			var signal : Signal = injector.getInstance( SupportSignal );
			signal.dispatch();
			assertThat(executeCount, equalTo(0));
		}

		[Test]
		public function test_oneshot_mappings_should_not_bork_stacked_mappings():void
		{
			var executeCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue( reportingFunction );
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand).once();
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand2).once();
			var signal : Signal = injector.getInstance( SupportSignal );
			signal.dispatch();
			var expected : Array = [ ReportingCommand, ReportingCommand2 ];
			assertThat( reportedExecutions, array( expected ) );
		}

		[Test]
		public function test_one_shot_command_should_not_cause_infinite_loop_when_dispatching_to_self():void
		{
			injector.map( SupportSignal ).asSingleton();
			var signal : Signal = injector.getInstance( SupportSignal );
			injector.map(Function, 'executeCallback').toValue(function(item:Object,itemClass:Class):void
			{
				signal.dispatch();
			});
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand).once();
			signal.dispatch();
			// note: no assertion. we just want to know if an error is thrown
		}

		[Test]
		public function test_cascaded_dispatches_should_not_bork_mappings():void
		{
			injector.map(Function, 'executeCallback').toValue(function( item : Object,itemClass:Class ):void
			{
				reportingFunction( item, itemClass );
				injector.unmap( Function, 'executeCallback' );
				injector.map( Function, 'executeCallback' ).toValue( reportingFunction );
				var signal2 : Signal = injector.getInstance( SupportSignal2 );
				signal2.dispatch();
			});
			signalCommandMap.map( SupportSignal ).toCommand( ReportingCommand );
			signalCommandMap.map( SupportSignal ).toCommand( ReportingCommand3 );
			signalCommandMap.map( SupportSignal2 ).toCommand( ReportingCommand2 );
			var signal1 : Signal = injector.getInstance( SupportSignal );
			signal1.dispatch();
			var expected : Array = [ ReportingCommand, ReportingCommand2, ReportingCommand3 ];
			assertThat( reportedExecutions, array( expected ) );
		}

		[Test]
		public function test_commands_are_executed_in_order():void
		{
			injector.map(Function, 'executeCallback').toValue( reportingFunction );
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand2);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand3);
			var signal1 : Signal = injector.getInstance( SupportSignal );
			signal1.dispatch();
			var expected : Array = [ ReportingCommand, ReportingCommand2, ReportingCommand3 ];
			assertThat(reportedExecutions, array(expected));
		}

		[Test]
		public function test_hooks_are_called():void
		{
			assertThat(hookCallCount(ReportingHook,ReportingHook), equalTo(2));
		}

		[Test]
		public function test_command_is_injected_into_hook():void
		{
			var executedCommand:ReportingCommand = null;
			var injectedCommand:ReportingCommand = null;
			injector.map(Function, 'executeCallback').toValue(function( command : ReportingCommand, commandClass:Class):void {
				executedCommand = command;
			});
			injector.map(Function, 'hookCallback').toValue(function(hook:ReportingHook, hookClass:Class):void {
				injectedCommand = hook.command;
			});
			signalCommandMap
				.map(SupportSignal)
				.toCommand(ReportingCommand)
				.withHooks(ReportingHook);
			var signal1 : Signal = injector.getInstance( SupportSignal );
			signal1.dispatch();
			assertThat(injectedCommand, equalTo(executedCommand));
		}

		[Test]
		public function test_command_executes_when_the_guard_allows():void
		{
			assertThat(commandExecutionCountWithGuards(HappyGuard), equalTo(1));
		}

		[Test]
		public function test_command_executes_when_all_guards_allow():void
		{
			assertThat(commandExecutionCountWithGuards(HappyGuard, HappyGuard), equalTo(1));
		}

		[Test]
		public function test_command_does_not_execute_when_the_guard_denies():void
		{
			assertThat(commandExecutionCountWithGuards(GrumpyGuard), equalTo(0));
		}

		[Test]
		public function test_command_does_not_execute_when_any_guards_denies():void
		{
			assertThat(commandExecutionCountWithGuards(HappyGuard, GrumpyGuard), equalTo(0));
		}

		[Test]
		public function test_command_does_not_execute_when_all_guards_deny():void
		{
			assertThat(commandExecutionCountWithGuards(GrumpyGuard, GrumpyGuard), equalTo(0));
		}

		[Test]
		public function test_payload_is_injected_into_guard():void
		{
			var injected : Object;
			injector.map(Function, 'approveCallback').toValue(function(guard:PayloadInjectedGuard, guardClass:Class):void
			{
				injected = guard.payload;
			});
			signalCommandMap
				.map(PayloadCarryingSignal)
				.toCommand(NullCommand)
				.withGuards(PayloadInjectedGuard);
			var payload : Object = {};
			var signal : Signal = injector.getInstance( PayloadCarryingSignal );
			signal.dispatch(payload);
			assertThat(injected, equalTo(payload));
		}

		[Test]
		public function test_payload_is_injected_into_hook():void
		{
			var injected : Object;
			injector.map(Function, 'hookCallback').toValue(function(hook:PayloadInjectedHook, hookClass:Class):void
			{
				injected = hook.payload;
			});
			signalCommandMap
				.map(PayloadCarryingSignal)
				.toCommand(NullCommand)
				.withHooks(PayloadInjectedHook);
			var payload : Object = {};
			var signal : Signal = injector.getInstance( PayloadCarryingSignal );
			signal.dispatch(payload);
			assertThat(injected, equalTo(payload));
		}

		[Test]
		public function test_cascading_signals_do_not_throw_unmap_errors():void
		{
			injector.map(ISignalCommandMap).toValue(signalCommandMap);
			signalCommandMap
				.map(SupportSignal)
				.toCommand(CascadingCommand)
				.once();
			var signal : Signal = injector.getInstance(SupportSignal);
			signal.dispatch();
		}

		[Test]
		public function test_execution_sequence_is_guard_command_guard_command_for_multiple_mappings_to_same_signal():void
		{
			injector.map(Function, 'executeCallback').toValue(reportingFunction);
			injector.map(Function, 'approveCallback').toValue(reportingFunction);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand).withGuards(ReportingGuard);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand2).withGuards(ReportingGuard2);
			var signal:Signal = injector.getInstance(SupportSignal);
			signal.dispatch();
			const expectedOrder:Array = [ReportingGuard, ReportingCommand, ReportingGuard2, ReportingCommand2];
			assertThat(reportedExecutions, array(expectedOrder));
		}

		[Test]
		public function test_previously_constructed_command_does_not_slip_through_the_loop():void
		{
			injector.map(Function, 'executeCallback').toValue(reportingFunction);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand).withGuards(HappyGuard);
			signalCommandMap.map(SupportSignal).toCommand(ReportingCommand2).withGuards(GrumpyGuard);
			const expectedOrder:Array = [ReportingCommand];
			var signal:Signal = injector.getInstance(SupportSignal);
			signal.dispatch();
			assertThat(reportedExecutions, array(expectedOrder));
		}
		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function commandExecutionCount(totalEvents:int = 1, oneshot:Boolean = false, ...valueObjects ):uint
		{
			var executeCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue(function(item:Object,itemClass:Class):void
			{
				executeCount++;
			});
			signalCommandMap.map( SupportSignal ).toCommand(ReportingCommand).once(oneshot);
			var signal : SupportSignal = injector.getInstance( SupportSignal );
			while (totalEvents--)
			{
				signal.dispatch.apply( null, valueObjects );
			}
			return executeCount;
		}

		private function oneshotCommandExecutionCount(totalEvents:int = 1):uint
		{
			return commandExecutionCount(totalEvents, true);
		}

		private function hookCallCount(... hooks):uint
		{
			var hookCallCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue(function(item:Object,itemClass:Class):void {
			});
			injector.map(Function, 'hookCallback').toValue(function(item:Object,itemClass:Class):void {
				hookCallCount++;
			});
			signalCommandMap
				.map(SupportSignal)
				.toCommand(ReportingCommand)
				.withHooks(hooks);
			var signal : Signal = injector.getInstance(SupportSignal );
			signal.dispatch();
			return hookCallCount;
		}

		private function commandExecutionCountWithGuards(... guards):uint
		{
			var executionCount:uint = 0;
			injector.map(Function, 'executeCallback').toValue(function( item:Object, itemClass:Class):void
			{
				executionCount++;
			});
			signalCommandMap
				.map(SupportSignal)
				.toCommand(ReportingCommand)
				.withGuards(guards);
			var signal : Signal = injector.getInstance(SupportSignal );
			signal.dispatch();
			return executionCount;
		}

		private function reportingFunction(item:Object, itemClass : Class):void
		{
			reportedExecutions.push(itemClass);
		}
	}
}
import org.osflash.signals.Signal;
import org.swiftsuspenders.Injector;

import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
import robotlegs.bender.extensions.signalCommandMap.support.NullCommand;
import robotlegs.bender.extensions.signalCommandMap.support.SupportSignal;

internal class PayloadInjectedCallbackCommand{
	/*============================================================================*/
	/* Public Properties                                                          */
	/*============================================================================*/

	[Inject]
	public var payload : Object;

	[Inject(name="executeCallback")]
	public var callback:Function;

	public function execute():void
	{
		callback( this );
	}
}
internal class ReportingCommand{
	[Inject(name="executeCallback")]
	public var callback:Function;

	public function execute():void
	{
		callback( this, ReportingCommand );
	}

}
internal class ReportingCommand2{
	[Inject(name="executeCallback")]
	public var callback:Function;

	public function execute():void
	{
		callback( this, ReportingCommand2 );
	}

}
internal class ReportingCommand3{
	[Inject(name="executeCallback")]
	public var callback:Function;

	public function execute():void
	{
		callback( this, ReportingCommand3 );
	}
}
internal class ReportingHook{
	[Inject]
	public var command:ReportingCommand;

	[Inject(name="hookCallback")]
	public var callback:Function;
	public function hook():void
	{
		callback(this, ReportingHook);
	}
}
internal class HappyGuard{
	public function approve():Boolean
	{
		return true;
	}
}
internal class GrumpyGuard{
	public function approve():Boolean
	{
		return false;
	}
}
internal class PayloadInjectedGuard{
	[Inject]
	public var payload : Object;

	[Inject(name="approveCallback")]
	public var callback:Function;

	public function approve():Boolean
	{
		callback(this, PayloadInjectedGuard);
		return true;
	}
}
internal class PayloadInjectedHook{
	[Inject]
	public var payload : Object;

	[Inject(name="hookCallback")]
	public var callback:Function;

	public function hook():void
	{
		callback(this, PayloadInjectedHook);
	}
}
internal class CascadingCommand
{
	[Inject]
	public var injector : Injector;

	[Inject]
	public var signalCommandMap:ISignalCommandMap;

	public function execute():void
	{
		signalCommandMap
			.map(SupportSignal)
			.toCommand(NullCommand)
			.once();
		var signal : Signal = injector.getInstance(SupportSignal);
		signal.dispatch();
	}
}
internal class ReportingGuard{
	[Inject(name="approveCallback")]
	public var callback:Function;

	public function approve():Boolean
	{
		callback(this, ReportingGuard);
		return true;
	}
}
internal class ReportingGuard2{
	[Inject(name="approveCallback")]
	public var callback:Function;

	public function approve():Boolean
	{
		callback(this, ReportingGuard2);
		return true;
	}
}