package collaboRhythm.plugins.medications.model
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;
	import spark.collections.SortField;

	public class RxNormService
	{
		private static const RXNORM_BASE_URI:String = "http://rxnav.nlm.nih.gov/REST/";
		private static const RXNORM_DRUGS_API:String = "drugs?name=";

		private var _medicationHealthActionCreationModel:MedicationHealthActionCreationModel;
		private var _rxNormConceptsArrayCollection:ArrayCollection;
		private var _rxNormConcept:RxNormConcept;

		public function RxNormService(medicationHealthActionCreationModel:MedicationHealthActionCreationModel)
		{
			_medicationHealthActionCreationModel = medicationHealthActionCreationModel;
			_rxNormConceptsArrayCollection = medicationHealthActionCreationModel.rxNormConceptsArrayCollection;
		}

		public function queryDrugName(drugName:String):void
		{
			_rxNormConceptsArrayCollection.removeAll();

			var urlRequest:URLRequest = new URLRequest(RXNORM_BASE_URI + RXNORM_DRUGS_API + drugName);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, queryDrugName_completeHandler);
			urlLoader.load(urlRequest);
		}


		private function queryDrugName_completeHandler(event:Event):void
		{
			var xmlResponse:XML = new XML(event.target.data);
			for each (var conceptXML:XML in xmlResponse.drugGroup.conceptGroup.conceptProperties)
			{
				var rxNormConcept:RxNormConcept = new RxNormConcept(conceptXML);
				_rxNormConceptsArrayCollection.addItem(rxNormConcept);
			}

			if (_rxNormConceptsArrayCollection.length == 0)
			{
				_medicationHealthActionCreationModel.areRxNormConceptsAvailable = false;
			}
			else
			{
				_medicationHealthActionCreationModel.areRxNormConceptsAvailable = true;

				var sort:Sort = new Sort();
				sort.fields = [new SortField("name")];

				_rxNormConceptsArrayCollection.sort = sort;
				_rxNormConceptsArrayCollection.refresh();
			}
		}

		public function queryNdcCodes(rxNormConcept:RxNormConcept):void
		{
			_rxNormConcept = rxNormConcept;

			var urlRequest:URLRequest = new URLRequest(RXNORM_BASE_URI + "rxcui/" + rxNormConcept.rxcui + "/ndcs");
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, queryNdcCodes_completeHandler);
			urlLoader.load(urlRequest);
		}

		private function queryNdcCodes_completeHandler(event:Event):void
		{
			var xmlResponse:XML = new XML(event.target.data);
			for each (var ndcXML:XML in xmlResponse.ndcGroup.ndcList.ndc)
			{
				var ndcCode:String = ndcXML.text()[0];
				ndcCode = ndcCode.substr(0, 9);
				if (_rxNormConcept.ndcCodes.getItemIndex(ndcCode) == -1)
				{
					_rxNormConcept.ndcCodes.addItem(ndcCode);
				}
			}

			_medicationHealthActionCreationModel.areNdcCodesAvailable = (_rxNormConcept.ndcCodes.length == 0);
		}
	}
}
