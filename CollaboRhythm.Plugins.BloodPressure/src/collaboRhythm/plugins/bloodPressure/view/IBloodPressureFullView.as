package collaboRhythm.plugins.bloodPressure.view
{

	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;

	public interface IBloodPressureFullView
	{
		function get model():BloodPressureModel;

		function set model(value:BloodPressureModel):void;

		function refresh():void;

		function get modality():String;

		function set modality(value:String):void;
	}
}
