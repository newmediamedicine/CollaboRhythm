package collaboRhythm.shared.insulinTitrationSupport.model.states
{
	import mx.collections.ArrayCollection;

	public interface ITitrationDecisionSupportStatesFileStore
	{
		function readStates():void;

		function get titrationDecisionSupportStates():ArrayCollection;
		function set titrationDecisionSupportStates(value:ArrayCollection):void;
	}
}
