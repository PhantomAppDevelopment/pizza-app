package galleryScreens
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;

	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.ProfileManager;

	public class ImageDetailsScreen extends PanelScreen
	{
		public static const GO_LOGIN:String = "goLogin";

		private var action:String;
		private var alert:Alert
		private var commentInput:TextInput;
		private var commentsList:List;
		private var isOpen:Boolean;
		private var popup:Panel;
		private var voteValue:String;
		private var viewsLabel:Label;
		private var thumbsUpButton:Button;
		private var thumbsDownButton:Button;

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

			this.title = "Image Details";
			this.layout = new VerticalLayout();
			this.backButtonHandler = goBack;

			//We override the theme to have a white background
			this.styleProvider = null;
			this.hasElasticEdges = false;
			this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			var downloadIcon:ImageLoader = new ImageLoader();
			downloadIcon.source = "assets/icons/download.png";
			downloadIcon.width = downloadIcon.height = 25;

			var downloadButton:Button = new Button();
			downloadButton.defaultIcon = downloadIcon;
			downloadButton.styleNameList.add("header-button");
			downloadButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				navigateToURL(new URLRequest(Constants.FIREBASE_STORAGE_URL + formatUrl(_data.selectedImage.url) + "?alt=media"));
			})

			var postIcon:ImageLoader = new ImageLoader();
			postIcon.source = "assets/icons/insert_comment.png";
			postIcon.width = postIcon.height = 25;

			var postButton:Button = new Button();
			postButton.defaultIcon = postIcon;
			postButton.styleNameList.add("header-button");
			postButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				checkProfile("comment");
			});

			this.headerProperties.rightItems = new <DisplayObject>[downloadButton, postButton];

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			var bigImage:ImageLoader = new ImageLoader();
			bigImage.layoutData = new VerticalLayoutData(100, NaN);
			bigImage.minWidth = bigImage.minHeight = 50;
			bigImage.source = Constants.FIREBASE_STORAGE_URL + formatUrl(_data.selectedImage.url) + "?alt=media";
			this.addChild(bigImage);

			var layoutForInfoGroup:VerticalLayout = new VerticalLayout();
			layoutForInfoGroup.padding = 10;
			layoutForInfoGroup.gap = 10;

			var infoGroup:LayoutGroup = new LayoutGroup();
			infoGroup.layout = layoutForInfoGroup;
			infoGroup.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			infoGroup.layoutData = new VerticalLayoutData(100, NaN);
			this.addChild(infoGroup);

			var imageTitle:Label = new Label();
			imageTitle.text = "<b>" + _data.selectedImage.title + "</b>" + "\n" + _data.selectedImage.uploaderName;
			imageTitle.layoutData = new VerticalLayoutData(100, NaN);
			infoGroup.addChild(imageTitle);

			viewsLabel = new Label();
			infoGroup.addChild(viewsLabel);

			var layoutForRatingGroup:HorizontalLayout = new HorizontalLayout();
			layoutForRatingGroup.gap = 20;
			layoutForRatingGroup.padding = 10;

			var ratingGroup:LayoutGroup = new LayoutGroup();
			ratingGroup.layout = layoutForRatingGroup;
			infoGroup.addChild(ratingGroup);

			var thumbsUpIcon:ImageLoader = new ImageLoader();
			thumbsUpIcon.source = "assets/icons/thumb_up.png";
			thumbsUpIcon.width = thumbsUpIcon.height = 25;
			thumbsUpIcon.color = 0x666666;

			thumbsUpButton = new Button();
			thumbsUpButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				voteValue = "up";
				checkProfile("vote");
			});
			thumbsUpButton.defaultIcon = thumbsUpIcon;
			thumbsUpButton.styleNameList.add("horizontal-button");
			ratingGroup.addChild(thumbsUpButton);

			var thumbsDownIcon:ImageLoader = new ImageLoader();
			thumbsDownIcon.source = "assets/icons/thumb_down.png";
			thumbsDownIcon.width = thumbsDownIcon.height = 25;
			thumbsDownIcon.color = 0x666666;

			thumbsDownButton = new Button();
			thumbsDownButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				voteValue = "down";
				checkProfile("vote");
			});
			thumbsDownButton.defaultIcon = thumbsDownIcon;
			thumbsDownButton.styleNameList.add("horizontal-button");
			ratingGroup.addChild(thumbsDownButton);

			var layoutForCommentsList:VerticalLayout = new VerticalLayout();
			layoutForCommentsList.hasVariableItemDimensions = true;
			layoutForCommentsList.horizontalAlign = HorizontalAlign.JUSTIFY;

			commentsList = new List();
			commentsList.layoutData = new VerticalLayoutData(100, NaN);
			commentsList.layout = layoutForCommentsList;
			commentsList.itemRendererFactory = function ():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.isQuickHitAreaEnabled = true;
				renderer.iconSourceField = "senderAvatar";

				renderer.iconLoaderFactory = function ():ImageLoader
				{
					var mask:Canvas = new Canvas();
					mask.drawCircle(20, 20, 20);

					var loader:ImageLoader = new ImageLoader();
					loader.width = loader.height = 40;
					loader.mask = mask;
					return loader;
				}

				renderer.labelFunction = function (item:Object):String
				{
					return "<b>" + item.senderName + "</b>" + "\n" + item.message;
				};

				return renderer;

			};
			this.addChild(commentsList);
			commentsList.itemRendererProperties.minHeight = 65;

			loadComments();
			loadUpvotes();
			loadDownvotes();
			updateViewCount();
		}

		private function loadComments():void
		{
			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_COMMENTS_BASE_URL +
					_data.selectedImage.id + '.json?orderBy="timestamp"&limitToLast=50'); //We load the latest 50 comments

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, commentsLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function commentsLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, commentsLoaded);

			//The JSON generated by Firebase contains the id as the node key, we use this function to add it to our Objects

			var rawData:Object = JSON.parse(event.currentTarget.data);
			var commentsArray:Array = new Array();

			for (var parent:String in rawData) {
				var tempObject:Object = new Object();
				tempObject.id = parent;

				for (var child:* in rawData[parent]) {
					tempObject[child] = rawData[parent][child];
				}

				commentsArray.push(tempObject);
				commentsArray.sortOn("timestamp", 2);
				tempObject = null;
			}

			commentsList.dataProvider = new ListCollection(commentsArray);
		}

		private function loadUpvotes():void
		{
			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_VOTES_BASE_URL + _data.selectedImage.id + '.json?orderBy="value"&equalTo="up"');

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, upvotesLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function upvotesLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, upvotesLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			var tempArray:Array = new Array();

			for each (var item:* in rawData) {
				tempArray.push(item);
			}

			thumbsUpButton.label = String(tempArray.length);

			rawData = null;
			tempArray = null;
		}

		private function loadDownvotes():void
		{
			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_VOTES_BASE_URL + _data.selectedImage.id + '.json?orderBy="value"&equalTo="down"');

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, downvotesLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function downvotesLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, downvotesLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			var tempArray:Array = new Array();

			for each (var item:* in rawData) {
				tempArray.push(item);
			}

			thumbsDownButton.label = String(tempArray.length);

			rawData = null;
			tempArray = null;
		}

		private function checkProfile(requestedAction:String):void
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
				action = requestedAction;
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
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, accessTokenLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			//VERY IMPORTANT: Yhis token will be used to authenticate with the Firebase realtime database
			_data.FirebaseAuthToken = rawData.access_token;
			_data.userProfile = Main.profile;

			if (action == "comment") {
				initPostComment();
			} else if (action == "vote") {
				initVote();
			} else {
				//Do nothing
			}
		}

		private function initPostComment():void
		{
			var layoutForPopup:VerticalLayout = new VerticalLayout();
			layoutForPopup.padding = 10;
			layoutForPopup.gap = 10;

			popup = new Panel();
			popup.layout = layoutForPopup;
			popup.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			popup.width = 300;
			popup.height = 220;
			popup.headerProperties.paddingLeft = 10;
			popup.title = "Post a Comment";

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

			commentInput = new TextInput();
			commentInput.prompt = "Type your comment here.";
			commentInput.layoutData = new VerticalLayoutData(100, 100);
			commentInput.textEditorProperties.multiline = true;
			popup.addChild(commentInput);

			var saveButton:Button = new Button();
			saveButton.addEventListener(starling.events.Event.TRIGGERED, saveComment);
			saveButton.styleNameList.add("rounded-button");
			saveButton.horizontalAlign = HorizontalAlign.CENTER;
			saveButton.layoutData = new VerticalLayoutData(100, NaN);
			saveButton.label = "Save Comment";
			saveButton.paddingLeft = 0;
			popup.addChild(saveButton);

			PopUpManager.addPopUp(popup, true, true, function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.5;
				return quad;
			});

			isOpen = true;
		}

		private function saveComment():void
		{
			if (commentInput.text != "") {
				//We prepare the vars to be send to the database, including the logged-in user basic info
				var myObject:Object = new Object();
				myObject.message = commentInput.text;
				myObject.timestamp = new Date().getTime();
				myObject.senderAvatar = _data.userProfile.photoUrl;
				myObject.senderId = _data.userProfile.localId;
				myObject.senderName = _data.userProfile.displayName;

				var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_COMMENTS_BASE_URL + _data.selectedImage.id + ".json?auth=" + _data.FirebaseAuthToken);
				request.data = JSON.stringify(myObject);
				request.method = URLRequestMethod.POST;

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(flash.events.Event.COMPLETE, commentPosted);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(request);
			}
		}

		private function commentPosted(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, commentPosted);
			isOpen = false;
			PopUpManager.removePopUp(popup, true);
			loadComments();
		}

		private function initVote():void
		{
			var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "PATCH");
			var myObject:Object = new Object();

			if (voteValue == "up") {
				myObject.value = "up";
			} else {
				myObject.value = "down";
			}

			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_VOTES_BASE_URL + _data.selectedImage.id + "/" + Main.profile.localId + ".json?auth=" + _data.FirebaseAuthToken);
			request.data = JSON.stringify(myObject);
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, loadVotes);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function loadVotes(event:flash.events.Event):void
		{
			event.currentTarget.addEventListener(flash.events.Event.COMPLETE, loadVotes);

			loadUpvotes();
			loadDownvotes();
		}

		private function updateViewCount():void
		{
			var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "PATCH");

			var myObject:Object = new Object();
			myObject.views = Number(_data.selectedImage.views) + 1;

			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_GALLERY_URL + "/" + _data.selectedImage.id + ".json");
			request.data = JSON.stringify(myObject);
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, viewsUpdated);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function viewsUpdated(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, viewsUpdated);
			var rawData:Object = JSON.parse(event.currentTarget.data);
			viewsLabel.text = rawData.views + " views";
		}

		private function formatUrl(url:String):String
		{
			//Firebase Storage / Google Cloud Storage requires that the slashes (/) are URLEncoded
			return url.replace(/\//g, "%2F");
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			trace(event.currentTarget.data);
		}

		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}


	}
}