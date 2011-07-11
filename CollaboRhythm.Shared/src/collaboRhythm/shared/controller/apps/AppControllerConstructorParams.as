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
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.CollaborationModel;
	import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.core.IVisualElementContainer;

	public class AppControllerConstructorParams
	{
		private var _widgetContainer:IVisualElementContainer;
		private var _fullContainer:IVisualElementContainer;
		private var _modality:String;
        private var _activeAccount:Account;
        private var _activeRecordAccount:Account;
        private var _settings:Settings;
        private var _componentContainer:IComponentContainer;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;

		public function AppControllerConstructorParams()
		{
		}

		public function get widgetContainer():IVisualElementContainer
		{
			return _widgetContainer;
		}

		public function set widgetContainer(value:IVisualElementContainer):void
		{
			_widgetContainer = value;
		}

		public function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public function set fullContainer(value:IVisualElementContainer):void
		{
			_fullContainer = value;
		}

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

        public function get activeAccount():Account {
            return _activeAccount;
        }

        public function set activeAccount(value:Account):void {
            _activeAccount = value;
        }

        public function get settings():Settings
        {
            return _settings;
        }

        public function set settings(value:Settings):void
        {
            _settings = value;
        }

        public function get activeRecordAccount():Account
        {
            return _activeRecordAccount;
        }

        public function set activeRecordAccount(value:Account):void
        {
            _activeRecordAccount = value;
        }

        public function get componentContainer():IComponentContainer
        {
            return _componentContainer;
        }

        public function set componentContainer(value:IComponentContainer):void
        {
            _componentContainer = value;
        }

		public function get collaborationLobbyNetConnectionService():CollaborationLobbyNetConnectionService
		{
			return _collaborationLobbyNetConnectionService;
		}

		public function set collaborationLobbyNetConnectionService(value:CollaborationLobbyNetConnectionService):void
		{
			_collaborationLobbyNetConnectionService = value;
		}
	}
}
