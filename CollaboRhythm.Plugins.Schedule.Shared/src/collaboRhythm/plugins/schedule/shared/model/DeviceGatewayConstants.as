package collaboRhythm.plugins.schedule.shared.model
{
	public class DeviceGatewayConstants
	{
		public static const BLOOD_GLUCOSE_HEALTH_ACTION_NAME:String = "Blood Glucose";
		public static const BLOOD_PRESSURE_HEALTH_ACTION_NAME:String = "Blood Pressure";
		public static const W3CDTF_FORMAT:String = "yyyy-MM-dd'T'HH:mm:ssZ";
		/**
		 * Type, such as Equipment, Medication, or Insulin Titration
		 */
		public static const HEALTH_ACTION_TYPE_KEY:String = "healthActionType";
		public static const EQUIPMENT_NAME_KEY:String = "equipmentName";
		/**
		 * Name of the health action, such as Blood Glucose, Blood Pressure, or MedicationAdministration
		 */
		public static const HEALTH_ACTION_NAME_KEY:String = "healthActionName";
		public static const EQUIPMENT_HEALTH_ACTION_TYPE:String = "Equipment";
		public static const CORRECTED_MEASURED_DATE_KEY:String = "correctedMeasuredDate";
		public static const DEVICE_MEASURED_DATE_KEY:String = "deviceMeasuredDate";
		public static const LOCAL_TRANSMITTED_DATE_KEY:String = "localTransmittedDate";
		public static const DEVICE_TRANSMITTED_DATE_KEY:String = "deviceTransmittedDate";
		public static const DATA_SOURCE_INFO_KEY:String = "dataSourceInfo";
		public static const BLOOD_GLUCOSE_KEY:String = "bloodGlucose";
		public static const SYSTOLIC_KEY:String = "systolic";
		public static const DIASTOLIC_KEY:String = "diastolic";
		public static const HEARTRATE_KEY:String = "heartrate";
		public static const SUCCESS_KEY:String = "success";
		public static const BATCH_TRANSFER_KEY:String = "batchTransfer";
	}
}
