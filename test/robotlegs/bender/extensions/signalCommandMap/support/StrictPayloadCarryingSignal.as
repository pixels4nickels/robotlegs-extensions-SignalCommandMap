package robotlegs.bender.extensions.signalCommandMap.support
{
	/**
	 * @author creynder
	 */
	import org.osflash.signals.Signal;

	public class StrictPayloadCarryingSignal extends Signal{
		public function StrictPayloadCarryingSignal()
		{
			super(Payload);
		}
	}
}