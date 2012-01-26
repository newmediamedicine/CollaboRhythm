package collaboRhythm.plugins.bloodPressure.view
{

	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.services.IComponentContainer;

	public interface IBloodPressureFullView
	{
		function get model():HealthChartsModel;

		function set model(value:HealthChartsModel):void;

		function refresh():void;

		function get modality():String;

		function set modality(value:String):void;

		function get componentContainer():IComponentContainer;
		function set componentContainer(value:IComponentContainer):void;
		function get activeAccountId():String;
		function set activeAccountId(value:String):void;
	}
}
