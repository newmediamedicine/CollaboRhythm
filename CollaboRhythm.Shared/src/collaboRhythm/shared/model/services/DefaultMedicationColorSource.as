package collaboRhythm.shared.model.services
{

	import flash.utils.Dictionary;

	public class DefaultMedicationColorSource implements IMedicationColorSource
	{
		private var _medicationColorsArray:Array = [
			{key: "atacand", value: 0xf0dbc9},
			{key: "658620064", value: 0x9cb7cc},
			{key: "658620062", value: 0x9cb7cc},
			{key: "605050049", value: 0xa49887},
			{key: "498840027", value: 0xb96f4b},
			{key: "007811506", value: 0x969da7},
			{key: "006033856", value: 0xa38580},
			{key: "006033740", value: 0x979fa9},
			{key: "005271413", value: 0xba9e93},
			{key: "003782075", value: 0xaeb7a6},
			{key: "003782072", value: 0x99afca},
			{key: "003780216", value: 0x9ca1ab},
			{key: "003780018", value: 0xb0b6c0},
			{key: "001723760", value: 0xabb2bf},
			{key: "001723760", value: 0xa5adb9},
			{key: "001723757", value: 0x99a1aa},
			{key: "001722907", value: 0x99a1aa},
			{key: "001431268", value: 0xa36a6a},
			{key: "000930734", value: 0x779cb7},
			{key: "000930733", value: 0x9e7389},
			{key: "000798", value: 0xebe8e0},
			{key: "000779", value: 0xd2d1cf},
			{key: "000777", value: 0xd1d0cc},
			{key: "000771", value: 0x84a7a8},
			{key: "000544299", value: 0xadafb5},
			{key: "000319", value: 0xd5d5d5},
			{key: "000279", value: 0xfdac81},
			{key: "s00185028101", value: 0xcabdb7},
			{key: "0093511898", value: 0x0f5d4a},
			{key: "0093736598", value: 0x9fb996},
			{key: "s0011460385R", value: 0xde9a87},
			{key: "s00069154041", value: 0xd3b690},
			{key: "s00186108805", value: 0xb8aca9},
			{key: "s00228282011", value: 0xb49c67},
			{key: "s00068067861", value: 0xd9d4d0},
			{key: "s0093736597", value: 0x8aa47d},
			{key: "s003780018", value: 0xa7a9a6},
			{key: "s000777", value: 0x9ba8b0},
			{key: "06035339", value: 0xcbc8ca},
			{key: "0173071820", value: 0xa52b2a},
			{key: "173068224", value: 0x3e84a6},
			{key: "0169643910", value: 0x2BA28E}, // levemir
			{key: "169643910", value: 0x81c4b7},
			{key: "551541918", value: 0xdbd8cf},
			{key: "667159712", value: 0xec6a5d},
			{key: "1331014601", value: 0xc2bca4},
			{key: "1731485001", value: 0xf1e4c2},
			{key: "5486823371", value: 0xc7c5b8},
			{key: "motrin400", value: 0xcdcacb},
			{key: "flexeril5", value: 0xfeb864},
			{key: "6079352501", value: 0xe1e0e0},
			{key: "007811452", value: 0x86625B}, // glipizide
			{key: "000931048", value: 0x638AA7}, // metformin
			{key: "000939364", value: 0x98b1c2}, // glyburide
			{key: "000060112", value: 0xc1ad94}, // sitagliptin
			{key: "000060221", value: 0xeca770}, // sitagliptin
			{key: "647640301", value: 0xd9d5d2}, // pioglitazone
			{key: "504190863", value: 0xb4b9b3}, // acarabose
			{key: "001730595", value: 0x217ab4},
			{key: "001730721", value: 0xd79b9b},
			{key: "005970046", value: 0x888d95}

		];

		private var _medicationColorsDictionary:Dictionary = new Dictionary();

		public function DefaultMedicationColorSource()
		{
			for each (var keyValuePair:Object in _medicationColorsArray)
			{
				_medicationColorsDictionary[keyValuePair.key] = keyValuePair.value;
			}
		}

		public function getMedicationColor(ndc:String):uint
		{
			return _medicationColorsDictionary[ndc];
		}
	}
}
