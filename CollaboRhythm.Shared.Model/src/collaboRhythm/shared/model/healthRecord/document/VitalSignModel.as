package collaboRhythm.shared.model.healthRecord.document
{

	import j2as3.collection.HashMap;

	[Bindable]
	public class VitalSignModel
	{
		private var _vitalSignsByCategory:HashMap = new HashMap();
		private var _isInitialized:Boolean = false;

		public static const SYSTOLIC_CATEGORY:String = "Blood Pressure Systolic";

		public static const DIASTOLIC_CATEGORY:String = "Blood Pressure Diastolic";

		public function VitalSignModel()
		{
		}

		public function get vitalSignsByCategory():HashMap
		{
			return _vitalSignsByCategory;
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}

		public function hasCategory(category:String):Boolean
		{
			return vitalSignsByCategory.keys.contains(category) && vitalSignsByCategory[category].length > 0;
		}
	}
}
