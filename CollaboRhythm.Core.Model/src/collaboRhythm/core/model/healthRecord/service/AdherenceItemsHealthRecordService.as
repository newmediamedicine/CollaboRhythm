/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.*;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.xml.IAdherenceItemXmlMarshaller;

	import com.adobe.utils.DateUtil;

	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	public class AdherenceItemsHealthRecordService extends DocumentStorageServiceBase implements IAdherenceItemXmlMarshaller
	{

		public function AdherenceItemsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
														  account:Account, debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, AdherenceItem.DOCUMENT_TYPE,
				  AdherenceItem, Schemas.AdherenceItemSchema);
		}

        override public function loadDocuments(record:Record):void
        {
			super.loadDocuments(record);

			// TODO: figure out what is wrong with order_by for this report; it is currently causing an error
			var params:URLVariables = new URLVariables();
//			params["order_by"] = "date_reported";
			params["limit"] = "999";

            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(null, null, record);
            _pha.reports_minimal_X_GET(params, null, null, null, record.id, "adherenceitems", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            parseAdherenceItemsReportXml(responseXml, healthRecordServiceRequestDetails.record);
			super.handleResponse(event, responseXml, healthRecordServiceRequestDetails);
        }

		public function parseAdherenceItemsReportXml(value:XML, record:Record):void
		{
			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			var data:ArrayCollection = new ArrayCollection();

			for each (var adherenceItemXml:XML in value.Report)
			{
				var adherenceItem:AdherenceItem = new AdherenceItem();
                initFromReportXML(adherenceItemXml, adherenceItem);
				if (!_debuggingToolsEnabled)
				{
					data.addItem(adherenceItem);
				}
				else if (adherenceItem.dateReported.valueOf() <= nowTime)
				{
					data.addItem(adherenceItem);
				}
			}

			// TODO: get order_by working and remove this sorting
			data = new ArrayCollection(data.toArray().sortOn("dateReportedValue", Array.NUMERIC));

			logParsedReportDocuments(data);

			for each (adherenceItem in data)
			{
				record.addDocument(adherenceItem);
			}

            record.adherenceItemsModel.isInitialized = true;
		}

		public function initFromReportXML(reportXml:XML, adherenceItem:AdherenceItem):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			DocumentMetadata.parseDocumentMetadata(reportXml.Meta.Document[0], adherenceItem.meta);
			var adherenceItemXml:XML = reportXml.Item.AdherenceItem[0];
			adherenceItem.name = HealthRecordHelperMethods.xmlToCodedValue(adherenceItemXml.name[0]);
			adherenceItem.reportedBy = adherenceItemXml.reportedBy;
			adherenceItem.dateReported = collaboRhythm.shared.model.DateUtil.parseW3CDTF(adherenceItemXml.dateReported);
			adherenceItem.recurrenceIndex = int(adherenceItemXml.recurrenceIndex);
			adherenceItem.adherence = HealthRecordHelperMethods.stringToBoolean(adherenceItemXml.adherence);
			adherenceItem.nonadherenceReason = adherenceItemXml.nonadherenceReason;
			for each (var relatedDocumentXml:XML in reportXml..relatesTo.relation.(@type == AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT).relatedDocument)
			{
				adherenceItem.adherenceResultIds.push(relatedDocumentXml.@id);
			}
			_relationshipXmlMarshaller.unmarshallRelationships(reportXml, adherenceItem);
		}

//		override public function marshallToXml(document:IDocument):String
//		{
//			return convertToXML(document as AdherenceItem).toXMLString();
//		}

		public function convertToXML(adherenceItem:AdherenceItem):XML
		{
			default xml namespace = "";
			var adherenceItemXml:XML = <AdherenceItem/>;
			adherenceItemXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
			// TODO: Write a helper method for coded value to xml
			adherenceItemXml.name = adherenceItem.name.text;
			adherenceItemXml.name.@type = adherenceItem.name.type;
			adherenceItemXml.name.@value = adherenceItem.name.value;
			adherenceItemXml.name.@abbrev = adherenceItem.name.abbrev;
			adherenceItemXml.reportedBy = adherenceItem.reportedBy;
			adherenceItemXml.dateReported = DateUtil.toW3CDTF(adherenceItem.dateReported);
			adherenceItemXml.recurrenceIndex = adherenceItem.recurrenceIndex.toString();
			adherenceItemXml.adherence = HealthRecordHelperMethods.booleanToString(adherenceItem.adherence);
			if (adherenceItem.nonadherenceReason)
				adherenceItemXml.nonadherenceReason = adherenceItem.nonadherenceReason;

			return adherenceItemXml;
		}
	}
}
