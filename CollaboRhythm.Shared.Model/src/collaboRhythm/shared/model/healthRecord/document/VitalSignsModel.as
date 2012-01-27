package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class VitalSignsModel extends DocumentCollectionBase
	{
		private var _vitalSignsByCategory:HashMap = new HashMap();

		public static const SYSTOLIC_CATEGORY:String = "Blood Pressure Systolic";
		public static const DIASTOLIC_CATEGORY:String = "Blood Pressure Diastolic";
		public static const HEART_RATE_CATEGORY:String = "Heart Rate";
		public static const BLOOD_GLUCOSE_CATEGORY:String = "Blood Glucose";
		public static const METABOLIC_EQUIVALENT_TASK_CATEGORY:String = "Metabolic Equivalent Task";
		public static const OXYGEN_SATURATION_CATEGORY:String = "Oxygen Saturation";

		public function VitalSignsModel()
		{
			super(VitalSign.DOCUMENT_TYPE);
		}

		/**
		 * Returns a HashMap for all VitalSigns where the key is the category (VitalSign.name.text) and the value
		 * is the corresponding ArrayCollection of VitalSign documents that match that category.
		 */
		public function get vitalSignsByCategory():HashMap
		{
			return _vitalSignsByCategory;
		}

		public function hasCategory(category:String):Boolean
		{
			return vitalSignsByCategory.keys.contains(category) && vitalSignsByCategory[category].length > 0;
		}

		override public function addDocument(document:IDocument):void
		{
			super.addDocument(document);

			var vitalSign:VitalSign = document as VitalSign;
			var category:String = vitalSign.name.text;
			var collection:ArrayCollection = vitalSignsByCategory.getItem(category);
			if (!collection)
			{
				collection = new ArrayCollection();
				vitalSignsByCategory.put(category, collection);
			}
			collection.addItem(vitalSign);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);

			var vitalSign:VitalSign = document as VitalSign;
			var category:String = vitalSign.name.text;
			var collection:ArrayCollection = vitalSignsByCategory.getItem(category);
			if (collection)
			{
				var itemIndex:int = collection.getItemIndex(document);
				if (itemIndex != -1)
					collection.removeItemAt(itemIndex);
			}
		}
	}
}
