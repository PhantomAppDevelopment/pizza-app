package galleryScreens
{

	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TabBar;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	import starling.display.DisplayObject;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.ProfileManager;

	public class GalleryScreen extends PanelScreen
	{
		public static const GO_IMAGE_DETAILS:String = "goImageDetails";
		public static const GO_LOGIN:String = "goLogin";
		public static const GO_UPLOAD:String = "goUpload";

		private var alert:Alert;
		private var imagesList:List;
		private var tabBar:TabBar;

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

			this.layout = new AnchorLayout();

			var menuButton:Button = new Button();
			menuButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(Main.OPEN_MENU);
			});
			menuButton.styleNameList.add("menu-button");
			this.headerProperties.leftItems = new <DisplayObject>[menuButton];

			var uploadIcon:ImageLoader = new ImageLoader();
			uploadIcon.source = "assets/icons/upload.png";
			uploadIcon.width = uploadIcon.height = 25;

			var uploadButton:Button = new Button();
			uploadButton.addEventListener(starling.events.Event.TRIGGERED, checkProfile);
			uploadButton.styleNameList.add("header-button");
			uploadButton.defaultIcon = uploadIcon;
			this.headerProperties.rightItems = new <DisplayObject>[uploadButton];

			imagesList = new List();
			imagesList.addEventListener(starling.events.Event.CHANGE, changeHandler);
			imagesList.layoutData = new AnchorLayoutData(0, 0, 50, 0, NaN, NaN);
			imagesList.itemRendererFactory = function ():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.isQuickHitAreaEnabled = true;

				renderer.labelFunction = function (item:Object):String
				{
					return "<b>" + item.title + "</b>" + "\n" + new Date(Number(item.timestamp)).toLocaleDateString() + "\n" + item.views + " views";
				}

				renderer.iconSourceFunction = function (item:Object):String
				{
					return Constants.FIREBASE_STORAGE_URL + formatUrl(item.thumb_url) + "?alt=media";
				}

				renderer.iconLoaderFactory = function ():ImageLoader
				{
					var loader:ImageLoader = new ImageLoader();
					loader.width = loader.height = 70;
					return loader;
				}

				return renderer;
			};
			this.addChild(imagesList);

			var popularIcon:ImageLoader = new ImageLoader();
			popularIcon.width = popularIcon.height = 25;
			popularIcon.source = "assets/icons/star.png";

			var popularIconSelected:ImageLoader = new ImageLoader();
			popularIconSelected.alpha = 0.75;
			popularIconSelected.width = popularIconSelected.height = 25;
			popularIconSelected.source = "assets/icons/star.png";

			var recentIcon:ImageLoader = new ImageLoader();
			recentIcon.width = recentIcon.height = 25;
			recentIcon.source = "assets/icons/date.png";

			var recentIconSelected:ImageLoader = new ImageLoader();
			recentIconSelected.alpha = 0.75;
			recentIconSelected.width = recentIconSelected.height = 25;
			recentIconSelected.source = "assets/icons/date.png";

			tabBar = new TabBar();
			tabBar.layoutData = new AnchorLayoutData(NaN, 0, 0, 0, NaN, NaN);
			tabBar.dataProvider = new ListCollection(
					[
						{
							label: "",
							data: "popular",
							defaultIcon: popularIcon,
							defaultSelectedIcon: popularIconSelected,
							downIcon: popularIconSelected
						},
						{
							label: "",
							data: "latest",
							defaultIcon: recentIcon,
							defaultSelectedIcon: recentIconSelected,
							downIcon: recentIconSelected
						}
					]);
			tabBar.addEventListener(starling.events.Event.CHANGE, loadGallery);
			this.addChild(tabBar);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			loadGallery();
		}

		private function loadGallery():void
		{
			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_GALLERY_URL + '.json?orderBy="status"&equalTo="approved"');

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, galleryLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function galleryLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, galleryLoaded);

			//The JSON generated by Firebase contains the id as the node key, we use this function to add it to our Objects

			var rawData:Object = JSON.parse(event.currentTarget.data);
			var imagesArray:Array = new Array();

			for (var parent:String in rawData) {
				var tempObject:Object = new Object();
				tempObject.id = parent;

				for (var child:* in rawData[parent]) {
					tempObject[child] = rawData[parent][child];
				}

				imagesArray.push(tempObject);
				tempObject = null;
			}

			if (tabBar.selectedItem.data == "popular") {
				this.title = "Most Popular";
				imagesArray.sortOn("views", 2);
			} else if (tabBar.selectedItem.data == "latest") {
				this.title = "Latest Submissions";
				imagesArray.sortOn("timestamp", 2);
			} else {
				//Nothing
			}

			imagesList.dataProvider = new ListCollection(imagesArray);
		}

		private function changeHandler(event:starling.events.Event):void
		{
			_data["selectedImage"] = imagesList.selectedItem;
			this.dispatchEventWith(GO_IMAGE_DETAILS);
		}

		private function checkProfile(event:starling.events.Event):void
		{
			if (ProfileManager.isLoggedIn() === false) {
				alert = Alert.show("This feature requires that you are signed in, proceed to Sign In process?", "Sign In Required", new ListCollection(
						[
							{label: "Cancel"},
							{label: "OK"}
						]));

				alert.addEventListener(starling.events.Event.CLOSE, function (event:starling.events.Event, data:Object):void
				{
					if (data.label == "OK") {
						dispatchEventWith(GO_LOGIN);
					}
				});
			} else {
				getAccessToken();
			}
		}

		private function getAccessToken():void
		{
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var myObject:Object = new Object();
			myObject.grant_type = "refresh_token";
			myObject.refresh_token = Main.profile.refreshToken;

			var request:URLRequest = new URLRequest(Constants.FIREBASE_AUTH_TOKEN_URL);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, accessTokenLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function accessTokenLoaded(event:flash.events.Event):void
		{
			event.currentTarget.addEventListener(flash.events.Event.COMPLETE, accessTokenLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			//VERY IMPORTANT: Yhis token will be used to authenticate with the Firebase realtime database
			_data.FirebaseAuthToken = rawData.access_token;
			this.dispatchEventWith(GO_UPLOAD);
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			trace(event.currentTarget.data);
		}

		private function formatUrl(url:String):String
		{
			//Firebase Storage / Google Cloud Storage requires that the slashes (/) are URLEncoded
			return url.replace(/\//g, "%2F");
		}

		override public function dispose():void
		{
			if (alert) {
				alert.removeFromParent(true);
			}

			super.dispose();
		}

	}
}