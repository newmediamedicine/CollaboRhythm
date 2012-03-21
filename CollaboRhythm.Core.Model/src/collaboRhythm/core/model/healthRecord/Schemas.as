package collaboRhythm.core.model.healthRecord
{

	public class Schemas
	{
		[Embed("/assets/healthRecord/schemas/codes.xsd", mimeType="application/octet-stream")]
		public static const CodedValuesSchema:Class;

		[Embed("/assets/healthRecord/schemas/values.xsd", mimeType="application/octet-stream")]
		public static const ValuesSchema:Class;

		[Embed("/assets/healthRecord/schemas/provider.xsd", mimeType="application/octet-stream")]
		public static const ProviderSchema:Class;

		[Embed("/assets/healthRecord/schemas/Measurement.xsd", mimeType="application/octet-stream")]
		public static const VitalSignSchema:Class;

		[Embed("/assets/healthRecord/schemas/Device.xsd", mimeType="application/octet-stream")]
		public static const EquipmentSchema:Class;

		[Embed("/assets/healthRecord/schemas/HealthActionSchedule.xsd", mimeType="application/octet-stream")]
		public static const EquipmentScheduleItemSchema:Class;

		[Embed("/assets/healthRecord/schemas/MedicationSchedule.xsd", mimeType="application/octet-stream")]
		public static const MedicationScheduleItemSchema:Class;

		[Embed("/assets/healthRecord/schemas/Problem.xsd", mimeType="application/octet-stream")]
		public static const ProblemSchema:Class;

		[Embed("/assets/healthRecord/schemas/VideoMessage.xsd", mimeType="application/octet-stream")]
		public static const VideoMessageSchema:Class;

		[Embed("/assets/healthRecord/schemas/MedicationFill.xsd", mimeType="application/octet-stream")]
		public static const MedicationFillSchema:Class;

		[Embed("/assets/healthRecord/schemas/MedicationOrder.xsd", mimeType="application/octet-stream")]
		public static const MedicationOrderSchema:Class;

		[Embed("/assets/healthRecord/schemas/MedicationAdministration.xsd", mimeType="application/octet-stream")]
		public static const MedicationAdministrationSchema:Class;

		[Embed("/assets/healthRecord/schemas/HealthActionOccurrence.xsd", mimeType="application/octet-stream")]
		public static const AdherenceItemSchema:Class;

		public function Schemas()
		{
		}
	}
}
