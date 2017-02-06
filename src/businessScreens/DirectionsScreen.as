package businessScreens
{
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;

	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.sensors.Geolocation;

	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.textures.Texture;

	import utils.NavigatorData;

	public class DirectionsScreen extends PanelScreen
	{
		[Embed(source="./../assets/icons/pin.png")]
		private static const pinAsset:Class;
		public static var pinTexture:Texture;

		private var directionsLoader:URLLoader;
		private var origin:String;
		private var destination:String;
		private var geo:Geolocation;
		private var alert:Alert;
		private var directionsList:List;
		private var geoMap:GeoMap;

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

			this.title = "Directions";
			this.layout = new VerticalLayout();
			this.backButtonHandler = goBack;
			this.headerProperties.paddingLeft = 10;

			var doneIcon:ImageLoader = new ImageLoader();
			doneIcon.source = "assets/icons/check.png";
			doneIcon.width = doneIcon.height = 25;

			var doneButton:Button = new Button();
			doneButton.defaultIcon = doneIcon;
			doneButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			doneButton.styleNameList.add("header-button");
			this.headerProperties.rightItems = new <DisplayObject>[doneButton];

			var mapOptions:MapOptions = new MapOptions();
			mapOptions.initialScale = 16 / 32;
			mapOptions.minimumScale = 1 / 32;
			mapOptions.maximumScale = 16 / 32;
			mapOptions.disableRotation = true;

			var mapContainer:LayoutGroup = new LayoutGroup();
			mapContainer.layoutData = new VerticalLayoutData(100, 50);
			mapContainer.layout = new AnchorLayout();
			this.addChild(mapContainer);

			geoMap = new GeoMap(mapOptions);
			geoMap.visible = false;
			geoMap.layoutData = new AnchorLayoutData(0, 0, 0, 0, NaN, NaN);
			geoMap.setSize(1, 1);
			mapContainer.addChild(geoMap);

			var osMaps:MapLayerOptions = Maps.OSM;
			osMaps.notUsedZoomThreshold = 1;
			geoMap.addLayer("osMaps", osMaps);

			directionsList = new List();
			directionsList.layoutData = new VerticalLayoutData(100, 50);
			directionsList.itemRendererFactory = function ():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelFunction = function (item:Object):String
				{
					return item.html_instructions;
				}

				renderer.accessoryLabelFunction = function (item:Object):String
				{
					return item.distance.text + "\n" + item.duration.text;
				}

				return renderer;
			};
			this.addChild(directionsList);

			pinTexture = Texture.fromEmbeddedAsset(pinAsset);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			destination = _data.currentBusiness.coordinates.latitude + "," + _data.currentBusiness.coordinates.longitude;

			if (Geolocation.isSupported) {
				geo = new Geolocation();

				if (!geo.muted) {
					geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
				} else {
					alert = Alert.show("Your GPS is turned off, please turn it ON and try again.", "Error", new ListCollection([{
						label: "OK",
						triggered: goBack
					}]));
				}
				geo.addEventListener(StatusEvent.STATUS, geoStatusHandler);
			} else {
				alert = Alert.show("GPS is not supported on your device.", "Error", new ListCollection([{
					label: "OK",
					triggered: goBack
				}]));
			}
		}

		private function geoUpdateHandler(event:GeolocationEvent):void
		{
			var lat:String = event.latitude.toString();
			var lon:String = event.longitude.toString();

			geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			geo = null;

			origin = lat + "," + lon;
			getDirections();
		}

		private function geoStatusHandler(event:StatusEvent):void
		{
			if (geo.muted) {
				geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			} else {
				geo.addEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
			}
		}

		private function getDirections():void
		{
			var request:URLRequest = new URLRequest("https://maps.googleapis.com/maps/api/directions/json?origin=" + origin + "&destination=" + destination + "&units=imperial");

			directionsLoader = new URLLoader();
			directionsLoader.addEventListener(flash.events.Event.COMPLETE, directionsLoaded);
			directionsLoader.load(request);
		}

		private function directionsLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, directionsLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			directionsList.dataProvider = new ListCollection(rawData.routes[0].legs[0].steps as Array);

			this.title = "Directions [ " + rawData.routes[0].legs[0].distance.text + " in " + rawData.routes[0].legs[0].duration.text + " ]";

			if (directionsList.dataProvider != null && directionsList.dataProvider.length >= 1) {

				geoMap.setCenterLongLat(directionsList.dataProvider.getItemAt(0).start_location.lng, directionsList.dataProvider.getItemAt(0).start_location.lat);

				directionsList.addEventListener(starling.events.Event.CHANGE, listHandler);

				geoMap.removeAllMarkers();
				geoMap.visible = true;

				for each(var item:Object in directionsList.dataProvider.data) {

					var marker:ImageLoader = new ImageLoader();
					marker.source = pinTexture;
					marker.color = 0xCC0000;
					marker.width = marker.height = 50;
					marker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);

					geoMap.addMarkerLongLat(String(Math.random()),
							Number(item.end_location.lng),
							Number(item.end_location.lat), marker);
				}

				var firstMarker:ImageLoader = new ImageLoader();
				firstMarker.source = "assets/icons/person_pin.png";
				firstMarker.width = firstMarker.height = 50;
				firstMarker.color = 0x0000FF;
				firstMarker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
				geoMap.addMarkerLongLat("first", directionsList.dataProvider.getItemAt(0).start_location.lng, directionsList.dataProvider.getItemAt(0).start_location.lat, firstMarker);

				var finalMarker:ImageLoader = new ImageLoader();
				finalMarker.source = "assets/icons/person_pin.png";
				finalMarker.width = finalMarker.height = 50;
				finalMarker.color = 0x0000FF;
				finalMarker.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
				geoMap.addMarkerLongLat("final", _data.currentBusiness.coordinates.longitude, _data.currentBusiness.coordinates.latitude, finalMarker);
			}
		}

		private function listHandler(event:starling.events.Event):void
		{
			geoMap.setCenterLongLat(directionsList.selectedItem.end_location.lng, directionsList.selectedItem.end_location.lat);
		}

		private function goBack():void
		{
			if (geo) {
				geo.removeEventListener(GeolocationEvent.UPDATE, geoUpdateHandler);
				geo = null;
			}

			if (alert) {
				alert.removeFromParent(true);
			}

			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

	}
}