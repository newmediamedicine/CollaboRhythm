package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import flash.display.DisplayObjectContainer;

	/**
	 * Provides data and services used by an IChartModifier instance.
	 */
	public interface IChartModelDetails
	{
		function get record():Record;

		/**
		 * The account ID of the active account.
		 */
		function get accountId():String;
		function get currentDateSource():ICurrentDateSource;
		function get healthChartsModel():HealthChartsModel;

		/**
		 * Container of the charts in the visual hierarchy. Can be used as the parent component for popups.
		 */
		function get owner():DisplayObjectContainer;

		/**
		 * Component container which can provide services and serves as a generic gateway to other plugins, components
		 * and services.
		 */
		function get componentContainer():IComponentContainer;

		function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy;
	}
}
