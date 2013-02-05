from indivo.document_processing import BaseTransform
from indivo.lib.iso8601 import parse_utc_date
from indivo.models import HealthActionResult
from lxml import etree

class HealthActionPlanTransform(BaseTransform):
    ns = "http://indivo.org/vocab/xml/documents/healthActionPlan#"

    def to_facts(self, doc_etree):
        args = self._get_data(doc_etree)

        # Create the fact and return it
        # Note: This method must return a list
        return [HealthActionPlan(**args)]

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
        
        # plannedBy
        ret['plannedBy'] = doc_etree.findtext(_t('plannedBy'))

        # datePlanned
        ret['datePlanned'] = parse_utc_date(doc_etree.findtext(_t('datePlanned')))

        # dateExpires
        date_expires = doc_etree.findtext(_t('dateExpires'))
        if date_expires:
            ret['dateExpires'] = parse_utc_date(date_expires)

        # indication
        ret['indication'] = doc_etree.findtext(_t('indication'))

        # instructions
        ret['instructions'] = doc_etree.findtext(_t('instructions'))

        # system
        system_node = doc_etree.find(_t('system'))
        ret['system_text'] = name_node.text
        ret['system_type'] = name_node.get('type')
        ret['system_type'] = name_node.get('value')
        ret['system_type'] = name_node.get('abbrev')

        # actions
        actions_node = doc_etree.find(_t('actions'))
        ret['actions'] = etree.tostring(actions_node, xml_declaration=False)

        return ret
