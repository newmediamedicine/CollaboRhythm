package collaboRhythm.shared.tests.model.healthRecord.util
{
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	import org.flexunit.asserts.assertEquals;

	import org.flexunit.runners.Parameterized;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class MedicationNameUtilTest
	{
		private var foo:Parameterized;

		private var _rawName:String;
		private var _medicationName:String;
		private var _strength:String;
		private var _form:String;
		private var _proprietaryName:String;
		private var _fillQuantity:String;

		[Parameters]
		public static function data():Array
		{
			/*
		 * 	Hydrochlorothiazide 25 MG Oral Tablet
		 * 	24 HR Diltiazem Hydrochloride 240 MG Extended Release Capsule
		 * 	3 ML insulin detemir 100 UNT/ML Prefilled Syringe [Levemir]
		 * 	Lisinopril 2.5 MG Oral Tablet [Zestril]
		 *  200 ACTUAT Albuterol 0.09 MG/ACTUAT Metered Dose Inhaler [Proventil]
			* */
			return [
				[
					"Hydrochlorothiazide 25 MG Oral Tablet",
					"Hydrochlorothiazide",
					"25 MG",
					"Oral Tablet",
					null
				],
				[
					"24 HR Diltiazem Hydrochloride 240 MG Extended Release Capsule",
					"Diltiazem Hydrochloride",
					"240 MG",
					"Extended Release Capsule",
					null
				],
				[
					"3 ML insulin detemir 100 UNT/ML Prefilled Syringe [Levemir]",
					"insulin detemir",
					"100 UNT/ML",
					"Prefilled Syringe",
					"[Levemir]"
				],
				[
					"Lisinopril 2.5 MG Oral Tablet [Zestril]",
					"Lisinopril",
					"2.5 MG",
					"Oral Tablet",
					"[Zestril]"
				],
				[
					"200 ACTUAT Albuterol 0.09 MG/ACTUAT Metered Dose Inhaler [Proventil]",
					"Albuterol",
					"0.09 MG/ACTUAT",
					"Metered Dose Inhaler",
					"[Proventil]"
				],
				[
					"lopinavir 100 MG / Ritonavir 25 MG Oral Tablet [Kaletra]",
					"lopinavir / Ritonavir",
					"100 MG / 25 MG",
					"Oral Tablet",
					"[Kaletra]"
				],
				[
					"efavirenz 600 MG / emtricitabine 200 MG / Tenofovir disoproxil fumarate 300 MG Oral Tablet [Atripla]",
					"efavirenz / emtricitabine / Tenofovir disoproxil fumarate",
					"600 MG / 200 MG / 300 MG",
					"Oral Tablet",
					"[Atripla]"
				],
			];
		}

		public function MedicationNameUtilTest(rawName:String, medicationName:String, strength:String, form:String, proprietaryName:String/*, fillQuantity:String*/)
		{
			_rawName = rawName;
			_medicationName = medicationName;
			_strength = strength;
			_form = form;
			_proprietaryName = proprietaryName;
/*
			_fillQuantity = fillQuantity;
*/
		}

		[Test(description = "Tests that parsing a medication name works as expected")]
		public function parseName():void
		{
			var result:MedicationName = MedicationNameUtil.parseName(_rawName);

			assertEquals(_medicationName, result.medicationName);
			assertEquals(_strength, result.strength);
			assertEquals(_form, result.form);
			assertEquals(_proprietaryName, result.proprietaryName);
		}
	}
}
