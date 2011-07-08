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

		[Embed("/assets/healthRecord/schemas/VitalSign.xsd", mimeType="application/octet-stream")]
		public static const VitalSignSchema:Class;

		public function Schemas()
		{
		}
	}
}
