package businessScreens
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;

	import renderers.BusinessRenderer;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.NavigatorData;

	public class ResultsScreen extends PanelScreen
	{
		public static const GO_DETAILS:String = "goBusinessDetails";

		private var businessList:List;
		private var loading:Boolean = false;
		private var popup:Panel;
		private var isOpen:Boolean = false;

		protected var _data:NavigatorData;

		public function get data():NavigatorData
		{
			return this._data;
		}

		public function set data(value:NavigatorData):void
		{
			this._data = value;
		}

		override protected function initialize():void
		{
			super.initialize();

			this.title = _data.totalResults + " Search Results";
			this.layout = new VerticalLayout();
			this.backButtonHandler = goBack;

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			var rightMenuIcon:ImageLoader = new ImageLoader();
			rightMenuIcon.source = "assets/icons/overflow.png";
			rightMenuIcon.width = rightMenuIcon.height = 20;

			var rightMenuButton:Button = new Button();
			rightMenuButton.addEventListener(starling.events.Event.TRIGGERED, openPopUpMenu);
			rightMenuButton.styleNameList.add("header-button");
			rightMenuButton.defaultIcon = rightMenuIcon;
			this.headerProperties.rightItems = new <DisplayObject>[rightMenuButton];

			businessList = new List();
			businessList.layoutData = new VerticalLayoutData(100, 100);
			businessList.itemRendererType = BusinessRenderer;
			this.addChild(businessList);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			businessList.dataProvider = _data.savedResults;

			if (_data.selectedIndex != undefined) {
				businessList.scrollToDisplayIndex(_data.selectedIndex);
				businessList.selectedIndex = _data.selectedIndex;
			}

			businessList.addEventListener(starling.events.Event.CHANGE, changeHandler);
			businessList.addEventListener(starling.events.Event.SCROLL, scrollHandler)
		}

		private function loadMore():void
		{
			if (!loading) {
				loading = true;

				var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.yelpAccessToken);

				var myObject:URLVariables = _data.searchParameters;
				myObject.offset = myObject.offset + 50;

				var request:URLRequest = new URLRequest("https://api.yelp.com/v3/businesses/search");
				request.data = myObject;
				request.requestHeaders.push(header);

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(flash.events.Event.COMPLETE, businessLoaded);
				loader.load(request);
			}
		}

		private function businessLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, businessLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			trace(event.currentTarget.data);
			this.title = rawData.total + " Search Results";

			for each (var item:* in rawData.businesses) {
				businessList.dataProvider.addItem(item);
			}

			loading = false;
		}

		private function scrollHandler(event:starling.events.Event):void
		{
			if (businessList.verticalScrollPosition == (businessList.viewPort.height - businessList.height)) {
				loadMore();
			}
		}

		private function changeHandler(event:starling.events.Event):void
		{
			_data.savedResults = businessList.dataProvider;
			_data.currentBusiness = businessList.selectedItem;
			_data.selectedIndex = businessList.selectedIndex;

			this.dispatchEventWith(GO_DETAILS);
		}

		private function openPopUpMenu(event:starling.events.Event):void
		{
			popup = new Panel();
			popup.layout = new VerticalLayout();
			popup.backgroundSkin = new Quad(3, 3, 0xDDDDDD);
			popup.headerProperties.paddingLeft = 10;
			popup.title = "Select a Distance";
			popup.width = 220;

			var closeIcon:ImageLoader = new ImageLoader();
			closeIcon.source = "assets/icons/close.png";
			closeIcon.width = closeIcon.height = 25;

			var closeButton:Button = new Button();
			closeButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				isOpen = false;
				PopUpManager.removePopUp(popup, true);
			});
			closeButton.styleNameList.add("header-button");
			closeButton.defaultIcon = closeIcon;
			popup.headerProperties.rightItems = new <DisplayObject>[closeButton];

			var distancesList:List = new List();
			distancesList.itemRendererFactory = function ():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.accessorySourceFunction = function ():String
				{
					if (distancesList.selectedIndex == renderer.index) {
						return "assets/icons/radio_checked.png";
					} else {
						return "assets/icons/radio_unchecked.png";
					}
				}

				renderer.accessoryLoaderFactory = function ():ImageLoader
				{
					var loader:ImageLoader = new ImageLoader();
					loader.width = loader.height = 20;
					loader.color = 0x000000;
					return loader;
				}

				return renderer;
			}
			distancesList.width = 220;
			distancesList.dataProvider = new ListCollection(
					[
						{label: "5 mi.", value: 8000},
						{label: "10 mi.", value: 16000},
						{label: "15 mi.", value: 24000}
					]);
			popup.addChild(distancesList);

			distancesList.selectedIndex = _data.selectedDistance;

			distancesList.addEventListener(starling.events.Event.CHANGE, function ():void
			{
				//Order of these instructions DOES matter
				businessList.removeEventListener(starling.events.Event.CHANGE, changeHandler);
				businessList.selectedIndex = -1;
				_data.selectedDistance = distancesList.selectedIndex;
				_data.searchParameters.radius = distancesList.selectedItem.value;
				PopUpManager.removePopUp(popup, true);
				isOpen = false;
				startNewSearch();
				businessList.addEventListener(starling.events.Event.CHANGE, changeHandler);
			});

			PopUpManager.addPopUp(popup, true, true, function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.75;
				return quad;
			})

			var instructionsLabel:Label = new Label();
			instructionsLabel.paddingLeft = 10;
			instructionsLabel.paddingTop = 5;
			instructionsLabel.text = "Works best with GPS.";
			popup.addChild(instructionsLabel);

			isOpen = true;
		}

		private function startNewSearch():void
		{
			loading = true;

			businessList.removeEventListener(starling.events.Event.SCROLL, scrollHandler)
			businessList.dataProvider = new ListCollection();
			businessList.addEventListener(starling.events.Event.SCROLL, scrollHandler)

			var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.yelpAccessToken);

			var myObject:URLVariables = _data.searchParameters;
			myObject.offset = 0;

			var request:URLRequest = new URLRequest("https://api.yelp.com/v3/businesses/search");
			request.data = myObject;
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, businessLoaded);
			loader.load(request);
		}

		private function goBack():void
		{
			_data.selectedDistance = null;
			_data.selectedIndex = null;
			_data.savedResults = null;
			_data.currentBusiness = null;
			_data.totalResults = null;
			_data.searchParameters = null;

			businessList.removeEventListener(starling.events.Event.CHANGE, changeHandler);
			businessList.removeEventListener(starling.events.Event.SCROLL, scrollHandler);
			businessList.dataProvider = null;

			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

		override public function dispose():void
		{
			if (isOpen) {
				PopUpManager.removePopUp(popup);
			}

			businessList.removeEventListener(starling.events.Event.CHANGE, changeHandler);
			businessList.removeEventListener(starling.events.Event.SCROLL, scrollHandler);

			super.dispose();
		}

	}
}