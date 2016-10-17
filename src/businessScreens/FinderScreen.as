package businessScreens
{
	import feathers.controls.Alert;
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PanelScreen;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.IOErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.sensors.Geolocation;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.text.TextFormat;

	import utils.NavigatorData;
	import utils.RoundedRect;

	public class FinderScreen extends PanelScreen
	{
		public static const GO_RESULTS:String = "goResults";

		private var alert:Alert;
		private var findPizzaLabel:Label;
		private var innerGroup:LayoutGroup;
		private var layoutForInnerGroup:VerticalLayout;
		private var locationInput:TextInput;
		private var mainGroup:LayoutGroup;
		private var latitude:String;
		private var longitude:String;
		private var geo:Geolocation;
		private var searchMode:String;
		private var yelpLogo:ImageLoader;

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

			this.title = "Find Local Businesses";
			this.layout = new AnchorLayout();

			var menuButton:Button = new Button();
			menuButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(Main.OPEN_MENU);
			});
			menuButton.styleNameList.add("menu-button");
			this.headerProperties.leftItems = new <DisplayObject>[menuButton];

			layoutForInnerGroup = new VerticalLayout();
			layoutForInnerGroup.horizontalAlign = HorizontalAlign.CENTER;
			layoutForInnerGroup.gap = 10;

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			initPanel();
		}

		private function initPanel():void
		{
			findPizzaLabel = new Label();
			findPizzaLabel.alpha = 0;
			findPizzaLabel.styleNameList.add("big-label");
			findPizzaLabel.text = "Find Pizza";
			findPizzaLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -50, -170);
			this.addChild(findPizzaLabel);

			var findPizzaLabelFade:Tween = new Tween(findPizzaLabel, 0.6);
			findPizzaLabelFade.animate("alpha", 1);
			Starling.juggler.add(findPizzaLabelFade);

			var findPizzaLabelSlide:Tween = new Tween(findPizzaLabel.layoutData, 0.6);
			findPizzaLabelSlide.animate("horizontalCenter", 0);
			Starling.juggler.add(findPizzaLabelSlide);

			mainGroup = new LayoutGroup();
			mainGroup.layout = new VerticalLayout();
			mainGroup.width = mainGroup.height = 1;
			mainGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(mainGroup);

			innerGroup = new LayoutGroup();
			innerGroup.alpha = 0;
			innerGroup.width = innerGroup.height = 250;
			innerGroup.layout = layoutForInnerGroup;
			mainGroup.addChild(innerGroup);

			var instructionsLabel:Label = new Label();
			instructionsLabel.width = 220;
			instructionsLabel.paddingTop = 15;
			instructionsLabel.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			instructionsLabel.fontStyles.leading = 5;
			instructionsLabel.textRendererProperties.wordWrap = true;
			instructionsLabel.layoutData = new VerticalLayoutData(NaN, 100);
			instructionsLabel.text = "Find pizza near you! Type your desired location or use the GPS.";
			innerGroup.addChild(instructionsLabel);

			locationInput = new TextInput();
			locationInput.width = 220;
			locationInput.height = 50;
			locationInput.prompt = "Location, e.g: Chicago";
			innerGroup.addChild(locationInput);

			var searchIcon:ImageLoader = new ImageLoader();
			searchIcon.source = "assets/icons/search.png";
			searchIcon.width = searchIcon.height = 25;

			var searchButton:Button = new Button();
			searchButton.addEventListener(starling.events.Event.TRIGGERED, initSearch);
			searchButton.styleNameList.add("rounded-button");
			searchButton.label = "Search";
			searchButton.defaultIcon = searchIcon;
			innerGroup.addChild(searchButton);
			searchButton.width = 220;
			searchButton.height = 50;

			var gpsIcon:ImageLoader = new ImageLoader();
			gpsIcon.source = "assets/icons/gps.png";
			gpsIcon.width = gpsIcon.height = 25;

			var gpsButton:Button = new Button();
			gpsButton.addEventListener(starling.events.Event.TRIGGERED, initGPS);
			gpsButton.styleNameList.add("rounded-button");
			gpsButton.label = "Search with GPS";
			gpsButton.defaultIcon = gpsIcon;
			innerGroup.addChild(gpsButton);
			gpsButton.width = 220;
			gpsButton.height = 50;

			var spacer:BasicButton = new BasicButton();
			spacer.height = 5;
			innerGroup.addChild(spacer);

			yelpLogo = new ImageLoader();
			yelpLogo.alpha = 0;
			yelpLogo.source = "assets/yelp/yelp_logo_large.png";
			yelpLogo.height = 40;
			yelpLogo.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 160);
			this.addChild(yelpLogo);

			var tween1:Tween = new Tween(mainGroup, 0.3);
			tween1.animate("height", 250);
			tween1.onComplete = function ():void
			{
				Starling.juggler.remove(tween1);
				Starling.juggler.add(tween2);
			};
			Starling.juggler.add(tween1);

			var tween2:Tween = new Tween(mainGroup, 0.3);
			tween2.animate("width", 250);
			tween2.onComplete = function ():void
			{
				Starling.juggler.remove(tween2);
				Starling.juggler.add(tween3);
			};

			var tween3:Tween = new Tween(innerGroup, 0.3);
			tween3.fadeTo(1);
			tween3.onComplete = function ():void
			{
				Starling.juggler.remove(tween3);
				Starling.juggler.add(tween4);
			}

			var tween4:Tween = new Tween(yelpLogo, 0.3);
			tween4.fadeTo(1);
			tween4.onComplete = function ():void
			{
				Starling.juggler.remove(tween4);
			}

		}

		private function initSearch():void
		{
			if (locationInput.text != "") {
				startFadeOut("location");
			} else {
				alert = Alert.show("Please type a location.", "Location Required", new ListCollection([{label: "OK"}]));
			}
		}

		private function initGPS(event:starling.events.Event):void
		{
			if (Geolocation.isSupported) {
				geo = new Geolocation();

				if (!geo.muted) {
					geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
				} else {
					alert = Alert.show("Your GPS is turned off, please turn it ON and try again.", "Error", new ListCollection([{label: "OK"}]));
				}

				geo.addEventListener(StatusEvent.STATUS, geoStatusHandler);
			} else {
				alert = Alert.show("GPS is not supported on your device.", "Error", new ListCollection([{label: "OK"}]));
			}
		}

		private function geoUpdateHandler(event:GeolocationEvent):void
		{
			latitude = event.latitude.toString();
			longitude = event.longitude.toString();

			geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			geo = null;

			startFadeOut("gps");
		}

		private function geoStatusHandler(event:StatusEvent):void
		{
			if (geo.muted) {
				geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			} else {
				geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			}
		}

		private function startFadeOut(mode:String):void
		{
			var findPizzaLabelFadeOut:Tween = new Tween(findPizzaLabel, 0.6);
			findPizzaLabelFadeOut.fadeTo(0);
			Starling.juggler.add(findPizzaLabelFadeOut);

			var yelpLogoFadeOut:Tween = new Tween(yelpLogo, 0.6);
			yelpLogoFadeOut.fadeTo(0);
			Starling.juggler.add(yelpLogoFadeOut);

			var innerGroupFadeOut:Tween = new Tween(innerGroup, 0.3);
			innerGroupFadeOut.fadeTo(0);
			innerGroupFadeOut.onComplete = function ():void
			{
				Starling.juggler.remove(innerGroupFadeOut);
				mainGroup.removeChild(innerGroup, true);
				Starling.juggler.add(resizeMainGroup);
			};
			Starling.juggler.add(innerGroupFadeOut);

			var resizeMainGroup:Tween = new Tween(mainGroup, 0.3);
			resizeMainGroup.animate("width", stage.stageWidth + 20);
			resizeMainGroup.animate("height", stage.stageHeight - 50);
			resizeMainGroup.onComplete = function ():void
			{
				Starling.juggler.remove(resizeMainGroup);
				searchMode = mode;
				initYelpAPI();
			};
		}

		private function initYelpAPI():void
		{
			var myObject:URLVariables = new URLVariables();
			myObject.grant_type = "client_credentials";
			myObject.client_id = Constants.YELP_APP_ID;
			myObject.client_secret = Constants.YELP_APP_SECRET;

			var request:URLRequest = new URLRequest("https://api.yelp.com/oauth2/token");
			request.data = myObject;
			request.method = URLRequestMethod.POST;

			var accessTokenLoader:URLLoader = new URLLoader();
			accessTokenLoader.addEventListener(flash.events.Event.COMPLETE, yelpAccessTokenLoaded);
			accessTokenLoader.load(request);
		}

		private function yelpAccessTokenLoaded(event:flash.events.Event):void
		{
			event.currentTarget.addEventListener(flash.events.Event.COMPLETE, yelpAccessTokenLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			_data.yelpAccessToken = rawData.access_token;

			var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.yelpAccessToken);

			var myObject:URLVariables = new URLVariables();
			myObject.limit = 50;
			myObject.offset = 0;
			myObject.term = "Pizza";
			myObject.radius = 8000;

			if (searchMode == "gps") {
				myObject.latitude = latitude;
				myObject.longitude = longitude;
			} else {
				myObject.location = locationInput.text;
			}

			var request:URLRequest = new URLRequest("https://api.yelp.com/v3/businesses/search");
			request.data = myObject;
			request.requestHeaders.push(header);

			_data.searchParameters = myObject;

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, yelpResponse);
			loader.addEventListener(IOErrorEvent.IO_ERROR, yelpError);
			loader.load(request);
		}

		private function yelpResponse(event:flash.events.Event):void
		{
			event.currentTarget.addEventListener(flash.events.Event.COMPLETE, yelpResponse);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			_data.selectedDistance = 0;
			_data.totalResults = rawData.total;
			_data.savedResults = new ListCollection(rawData.businesses as Array);
			rawData = null;

			this.dispatchEventWith(GO_RESULTS);
		}

		private function yelpError(event:flash.events.Event):void
		{
			trace(event.currentTarget.data);
		}

	}
}