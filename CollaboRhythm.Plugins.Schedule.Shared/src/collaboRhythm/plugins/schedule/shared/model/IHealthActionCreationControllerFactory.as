package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Account;

	import spark.components.ViewNavigator;

	public interface IHealthActionCreationControllerFactory
	{
		function createHealthActionCreationController(activeAccount:Account,
													  activeRecordAccount:Account,
													  viewNavigator:ViewNavigator):IHealthActionCreationController;
	}
}
