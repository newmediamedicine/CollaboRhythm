package collaboRhythm.shared.insulinTitrationSupport.model.states
{
	import mx.collections.ArrayCollection;

	public interface IInsulinTitrationDecisionSupportStatesFileStore
	{
		function readStates():void;

		function get insulinTitrationDecisionSupportStates():ArrayCollection;
		function set insulinTitrationDecisionSupportStates(value:ArrayCollection):void;
	}
}
