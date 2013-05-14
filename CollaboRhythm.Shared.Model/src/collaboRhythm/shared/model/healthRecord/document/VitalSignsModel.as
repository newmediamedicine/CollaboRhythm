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
		public static const ASTHMA_SYMPTOM_CATEGORY:String = "asthma symptom";
		public static const ASTHMA_TRIGGER_CATEGORY:String = "asthma trigger";
		public static const CALORIC_INTAKE_CATEGORY:String = "Caloric Intake";
		public static const PEAK_EXPIRATORY_FLOW_RATE_CATEGORY:String = "Peak Expiratory Flow Rate";
		public static const STEP_COUNT_CATEGORY:String = "Step Count";
		public static const VIRAL_LOAD_CATEGORY:String = "Viral Load";
		public static const TCELL_COUNT_CATEGORY:String = "TCell Count";

		public static const SUPPORTED_CATEGORIES:Vector.<String> = new <String>[
			SYSTOLIC_CATEGORY,
			DIASTOLIC_CATEGORY,
			HEART_RATE_CATEGORY,
			BLOOD_GLUCOSE_CATEGORY,
			METABOLIC_EQUIVALENT_TASK_CATEGORY,
			OXYGEN_SATURATION_CATEGORY,
			ASTHMA_SYMPTOM_CATEGORY,
			ASTHMA_TRIGGER_CATEGORY,
			CALORIC_INTAKE_CATEGORY,
			PEAK_EXPIRATORY_FLOW_RATE_CATEGORY,
			STEP_COUNT_CATEGORY,
			VIRAL_LOAD_CATEGORY,
			TCELL_COUNT_CATEGORY
		];

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
			var collection:ArrayCollection = getVitalSignsByCategory(category);
			collection.addItem(vitalSign);
		}

		/**
		 * Returns a collection containing all of the vital signs of a given category. If the category does not yet
		 * exist, a new collection will be created. Note that this method has the side effect of modifying the
		 * vitalSignsByCategory, so getVitalSignsByCategory should generally not be called for categories that do not
		 * apply or are not relevant to the current record.
		 *
		 * @param category The name from the vital sign (vitalSign.name.text)
		 * @return The ArrayCollection of VitalSign objects where each VitalSign has name.text matching the category.
		 */
		public function getVitalSignsByCategory(category:String):ArrayCollection
		{
			var collection:ArrayCollection = vitalSignsByCategory.getItem(category);
			if (!collection)
			{
				collection = new ArrayCollection();
				vitalSignsByCategory.put(category, collection);
			}
			return collection;
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
