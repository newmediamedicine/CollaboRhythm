package collaboRhythm.shared.model.healthRecord
{

	import collaboRhythm.shared.model.healthRecord.document.*;

	import collaboRhythm.shared.model.healthRecord.document.VitalSignModel;

	public interface IRecord
	{
		function get id():String;

		function set id(value:String):void;

		function get label():String;

		function set label(value:String):void;

		function get shared():Boolean;

		function set shared(value:Boolean):void;

		function get role_label():String;

		function set role_label(value:String):void;

		function get vitalSignModel():VitalSignModel;

		function set vitalSignModel(value:VitalSignModel):void;
	}
}
