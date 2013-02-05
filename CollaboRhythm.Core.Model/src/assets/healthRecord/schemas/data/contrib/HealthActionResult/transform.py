from indivo.document_processing import BaseTransform
from indivo.lib.iso8601 import parse_utc_date
from indivo.models import HealthActionPlan
from lxml import etree


class HealthActionResultTransform(BaseTransform):
    ns = "http://indivo.org/vocab/xml/documents/healthActionResult#"

    def to_facts(self, doc_etree):
        args = self._get_data(doc_etree)

        # Create the fact and return it
        # Note: This method must return a list
        return [HealthActionResult(**args)]

    def _tag(self, tagname):
        return "{%s}%s"%(self.ns, tagname)

    def _get_data(self, doc_etree):
        """ Parse the etree and return a dict of key-value pairs for object construction. """
        ret = {}
        _t = self._tag

        # name
        name_node = doc_etree.find(_t('name'))
        ret['name_text'] = name_node.text
        ret['name_type'] = name_node.get('type')
        ret['name_type'] = name_node.get('value')
        ret['name_type'] = name_node.get('abbrev')

        # planType
        ret['planType'] = doc_etree.findtext(_t('planType'))
        
        # reportedBy
        ret['reportedBy'] = doc_etree.findtext(_t('reportedBy'))

        # dateReported
        date_reported = doc_etree.findtext(_t('dateReported'))
        if date_reported:
            ret['dateReported'] = parse_utc_date(date_reported)

        # actions
        actions_node = doc_etree.find(_t('actions'))
        ret['actions'] = etree.tostring(actions_node, xml_declaration=False)

        return ret
