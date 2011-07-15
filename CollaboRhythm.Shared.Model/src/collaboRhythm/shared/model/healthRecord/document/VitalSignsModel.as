package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;

	import j2as3.collection.HashMap;

	[Bindable]
	public class VitalSignsModel extends DocumentCollectionBase
	{
		private var _vitalSignsByCategory:HashMap = new HashMap();

		public static const SYSTOLIC_CATEGORY:String = "Blood Pressure Systolic";

		public static const DIASTOLIC_CATEGORY:String = "Blood Pressure Diastolic";

		public function VitalSignsModel()
		{
			super(VitalSign.DOCUMENT_TYPE);
		}

		public function get vitalSignsByCategory():HashMap
		{
			return _vitalSignsByCategory;
		}

		public function hasCategory(category:String):Boolean
		{
			return vitalSignsByCategory.keys.contains(category) && vitalSignsByCategory[category].length > 0;
		}
	}
}
