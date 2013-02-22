package collaboRhythm.core.model.healthRecord
{

	public class Schemas
	{
		[Embed("/assets/healthRecord/schemas/data/common/codes.xsd", mimeType="application/octet-stream")]
		public static const CodedValuesSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/codes.xsd", mimeType="application/octet-stream")]
		public static const CollaboRhythmCodedValuesSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/values.xsd", mimeType="application/octet-stream")]
		public static const CollaboRhythmValuesSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/provider.xsd", mimeType="application/octet-stream")]
		public static const ProviderSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/CollaboRhythmVitalSign/schema.xsd", mimeType="application/octet-stream")]
		public static const CollaboRhythmVitalSignSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/core/equipment/schema.xsd", mimeType="application/octet-stream")]
		public static const EquipmentSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/HealthActionSchedule/schema.xsd", mimeType="application/octet-stream")]
		public static const HealthActionScheduleSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/MedicationScheduleItem/schema.xsd", mimeType="application/octet-stream")]
		public static const MedicationScheduleItemSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/core/problem/schema.xsd", mimeType="application/octet-stream")]
		public static const ProblemSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/MedicationFill/schema.xsd", mimeType="application/octet-stream")]
		public static const MedicationFillSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/MedicationOrder/schema.xsd", mimeType="application/octet-stream")]
		public static const MedicationOrderSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/MedicationAdministration/schema.xsd", mimeType="application/octet-stream")]
		public static const MedicationAdministrationSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/AdherenceItem/schema.xsd", mimeType="application/octet-stream")]
		public static const AdherenceItemSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/HealthActionPlan/schema.xsd", mimeType="application/octet-stream")]
		public static const HealthActionPlanSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/HealthActionResult/schema.xsd", mimeType="application/octet-stream")]
		public static const HealthActionResultSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/contrib/HealthActionOccurrence/schema.xsd", mimeType="application/octet-stream")]
		public static const HealthActionOccurrenceSchema:Class;
		
		[Embed("/assets/healthRecord/schemas/Message.xsd", mimeType="application/octet-stream")]
		public static const MessageSchema:Class;

		[Embed("/assets/healthRecord/schemas/data/core/demographics/schema.xsd", mimeType="application/octet-stream")]
		public static const DemographicsSchema:Class;

		public function Schemas()
		{
		}
	}
}
