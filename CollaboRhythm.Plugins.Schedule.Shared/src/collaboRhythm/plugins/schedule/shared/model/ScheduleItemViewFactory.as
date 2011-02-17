/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.plugins.schedule.shared.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemWidgetViewBase;
	import collaboRhythm.shared.model.healthRecord.IDocumentMetadata;
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;

	import com.theory9.data.types.OrderedMap;

	/**
	 * Factory for creating instances of view classes for the schedule (clock). Note that this could
	 * be generalized as a means of plugging in different new view(s) for a given document type and view type.
	 * This factory is NOT currently used.
	 * <p>
	 * Using this factory would involve two parts:
	 * <code>
	 * (1) Registering the appropriate view component(s). For example:
	 * 		typeName = ReflectionUtils.getClassInfo(ScheduleItemWidgetViewMedication).name;
	 * 		componentContainer.registerComponentInstance(typeName, DocumentViewDescriptor,
	 * 													 new DocumentViewDescriptor("http://indivo.org/vocab/xml/documents#Medication",
	 * 																				ScheduleItemWidgetViewBase.SCHEDULE_ITEM_WIDGET_VIEW,
	 * 																				ScheduleItemWidgetViewMedication));
	 * (2) Invoking the factory to create a view. For example:
	 * 		var scheduleItem:ScheduleItem;
	 * 		var factory:ScheduleItemViewFactory = new ScheduleItemViewFactory(componentContainer);
	 *  	var widgetScheduleItemView:ScheduleItemWidgetViewBase = factory.createWidgetView(scheduleItem.scheduledAction);
	 * </code>
	 */
	public class ScheduleItemViewFactory
	{
		private var _viewClassesMap:OrderedMap = new OrderedMap();

		public function ScheduleItemViewFactory(componentContainer:IComponentContainer)
		{
			var documentViewDescriptors:Array = componentContainer.resolveAll(DocumentViewDescriptor);

			for each (var documentViewDescriptor:DocumentViewDescriptor in documentViewDescriptors)
			{
				_viewClassesMap.addKeyValue(getKey(documentViewDescriptor), documentViewDescriptor.viewClass)
			}
		}

		private function getKey(documentViewDescriptor:DocumentViewDescriptor):String
		{
			return documentViewDescriptor.documentType + "." + documentViewDescriptor.viewType;
		}

		public function createWidgetView(scheduleItem:IDocumentMetadata):ScheduleItemWidgetViewBase
		{
			var key:String = scheduleItem.type + "." + ScheduleItemWidgetViewBase.SCHEDULE_ITEM_WIDGET_VIEW;
			var viewClass:Class = _viewClassesMap.getValueByKey(key);

			var view:Object = new viewClass();
			if (!view)
				throw new Error("Failed to create new instance of view class " + ReflectionUtils.getClassInfo(viewClass).name + " for " + key);

			var widgetView:ScheduleItemWidgetViewBase = view as ScheduleItemWidgetViewBase;
			if (!widgetView)
				throw new Error("Failed to cast view instance as " + ReflectionUtils.getClassInfo(ScheduleItemWidgetViewBase).name + " for " + key);
			
			return widgetView;
		}
	}
}
