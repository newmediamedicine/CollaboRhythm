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
package collaboRhythm.shared.controller.apps
{
import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.core.IVisualElementContainer;

	public class AppControllerConstructorParams
	{
		private var _widgetParentContainer:IVisualElementContainer;
		private var _fullParentContainer:IVisualElementContainer;
		private var _isWorkstationMode:Boolean;
        private var _account:Account;
        private var _settings:Settings;

		public function AppControllerConstructorParams()
		{
		}

		public function get widgetParentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		public function set widgetParentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
		}

		public function get fullParentContainer():IVisualElementContainer
		{
			return _fullParentContainer;
		}

		public function set fullParentContainer(value:IVisualElementContainer):void
		{
			_fullParentContainer = value;
		}

		public function get isWorkstationMode():Boolean
		{
			return _isWorkstationMode;
		}

		public function set isWorkstationMode(value:Boolean):void
		{
			_isWorkstationMode = value;
		}

        public function get account():Account {
            return _account;
        }

        public function set account(value:Account):void {
            _account = value;
        }

        public function get settings():Settings
        {
            return _settings;
        }

        public function set settings(value:Settings):void
        {
            _settings = value;
        }
    }
}
