package galleryScreens
{
	import feathers.controls.Alert;
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.textures.Texture;

	import utils.NavigatorData;
	import utils.RoundedRect;

	public class UploadImageScreen extends PanelScreen
	{

		private var alert:Alert;
		private var now:Number;
		private var bigImage:ImageLoader;
		private var nameInput:TextInput;
		private var cameraUIButton:Button;
		private var cameraUI:CameraUI;
		private var cameraRollButton:Button;
		private var cameraRoll:CameraRoll;
		private var dataSource:IDataInput;
		private var myBitmapData:BitmapData;
		private var myTexture:Texture;
		private var thumbUrl:String;

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

			//This screen is a bit complex, it requires special attention in the object creation and destruction

			this.title = "Upload Picture";
			this.layout = new AnchorLayout();
			this.backButtonHandler = goBack;

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			var layoutForMainGroup:VerticalLayout = new VerticalLayout();
			layoutForMainGroup.padding = 10;
			layoutForMainGroup.gap = 10;

			var mainGroup:ScrollContainer = new ScrollContainer();
			mainGroup.hasElasticEdges = false;
			mainGroup.layout = layoutForMainGroup;
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(mainGroup);

			nameInput = new TextInput();
			nameInput.prompt = "Type a title for your image";
			nameInput.layoutData = new VerticalLayoutData(100, NaN);
			mainGroup.addChild(nameInput);

			bigImage = new ImageLoader();
			bigImage.layoutData = new VerticalLayoutData(100, NaN);
			bigImage.minWidth = bigImage.minHeight = 1;
			mainGroup.addChild(bigImage);

			var spacer:BasicButton = new BasicButton();
			spacer.layoutData = new VerticalLayoutData(100, 100);
			mainGroup.addChild(spacer);

			var infoIcon:ImageLoader = new ImageLoader();
			infoIcon.source = "assets/icons/info.png";
			infoIcon.width = infoIcon.height = 35;
			infoIcon.color = 0x666666;

			var infoButton:Button = new Button();
			infoButton.styleNameList.add("horizontal-button");
			infoButton.layoutData = new VerticalLayoutData(100, NaN);
			infoButton.label = "All submissiones are subject to approval by a Moderator.";
			infoButton.defaultIcon = infoIcon;
			mainGroup.addChild(infoButton);

			var cameraIcon:ImageLoader = new ImageLoader();
			cameraIcon.source = "assets/icons/camera.png";
			cameraIcon.width = cameraIcon.height = 60;
			cameraIcon.color = 0x666666;

			cameraUIButton = new Button();
			cameraUIButton.styleNameList.add("vertical-button");
			cameraUIButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -60, 0);
			cameraUIButton.addEventListener(starling.events.Event.TRIGGERED, initCameraUI);
			cameraUIButton.defaultIcon = cameraIcon;
			cameraUIButton.label = "Camera";
			this.addChild(cameraUIButton);

			var galleryIcon:ImageLoader = new ImageLoader();
			galleryIcon.source = "assets/icons/camera_roll.png";
			galleryIcon.width = galleryIcon.height = 60;
			galleryIcon.color = 0x666666;

			cameraRollButton = new Button();
			cameraRollButton.styleNameList.add("vertical-button");
			cameraRollButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 60, 0);
			cameraRollButton.addEventListener(starling.events.Event.TRIGGERED, initCameraRoll);
			cameraRollButton.defaultIcon = galleryIcon;
			cameraRollButton.label = "Camera Roll";
			this.addChild(cameraRollButton);
		}

		private function initCameraUI(event:starling.events.Event):void
		{
			if (CameraUI.isSupported) {
				cameraUI = new CameraUI();
				cameraUI.addEventListener(MediaEvent.COMPLETE, imageSelected);
				cameraUI.addEventListener(flash.events.Event.CANCEL, browseCanceled);
				cameraUI.addEventListener(ErrorEvent.ERROR, mediaError);
				cameraUI.launch(MediaType.IMAGE);
			}
		}

		private function initCameraRoll(event:starling.events.Event):void
		{
			if (CameraRoll.supportsBrowseForImage) {
				cameraRoll = new CameraRoll();
				cameraRoll.addEventListener(MediaEvent.SELECT, imageSelected);
				cameraRoll.addEventListener(flash.events.Event.CANCEL, browseCanceled);
				cameraRoll.addEventListener(ErrorEvent.ERROR, mediaError);
				cameraRoll.browseForImage();
			}
		}

		protected function imageSelected(event:MediaEvent):void
		{
			var promise:MediaPromise = event.data as MediaPromise;
			var promiseFile:File = promise.file;

			if (promiseFile != null) {
				var imagePromise:MediaPromise = event.data;

				if (imagePromise.file != null && false) {
					//Do nothing
				}
				else {
					dataSource = imagePromise.open();

					if (imagePromise.isAsync) {
						//trace("Asynchronous media promise.");
						var eventSource:IEventDispatcher = dataSource as IEventDispatcher;
						eventSource.addEventListener(flash.events.Event.COMPLETE, onMediaLoaded);
					}
					else {
						//trace("Synchronous media promise.");
						readMediaData();
					}
				}
			}

			event.target.removeEventListener(MediaEvent.COMPLETE, imageSelected);

		}

		private function onMediaLoaded(event:flash.events.Event):void
		{
			readMediaData();
		}

		private function readMediaData():void
		{
			//We get the image as bytes, we turn it into a ByteArray
			var imageBytes:ByteArray = new ByteArray();
			dataSource.readBytes(imageBytes);

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.INIT, function ():void
			{
				cameraUIButton.visible = false;
				cameraRollButton.visible = false;

				myBitmapData = scaleBMD(Bitmap(loader.content).bitmapData, "scale");
				bigImage.source = myTexture = Texture.fromBitmapData(myBitmapData);

				loader = null;
				imageBytes = null;
			});
			loader.loadBytes(imageBytes);

			var sendIcon:ImageLoader = new ImageLoader();
			sendIcon.source = "assets/icons/send.png";
			sendIcon.height = sendIcon.width = 25;

			var sendButton:Button = new Button();
			sendButton.styleNameList.add("header-button");
			sendButton.defaultIcon = sendIcon;
			sendButton.addEventListener(starling.events.Event.TRIGGERED, uploadThumbnail);
			this.headerProperties.rightItems = new <DisplayObject>[sendButton];
		}

		private function scaleBMD(originalBitmapData:BitmapData, mode:String):BitmapData
		{
			var contentWidth:Number = originalBitmapData.width;
			var contentHeight:Number = originalBitmapData.height;

			var targetWidth:Number = 0;
			var targetHeight:Number = 0;

			if (mode == "thumbnail") {
				//If we want a thumbnail we hardcode its size to be 100x100px
				targetWidth = 100;
				targetHeight = 100;
			} else if (mode == "scale") {
				//Textures larger than 2048px are not supported on limited Stage3d profiles, so we scale them to a safe size
				if (contentWidth >= 2000 || contentHeight >= 2000) {
					targetWidth = 2000;
					targetHeight = 2000;
				} else {
					//If they are smaller we leave them as is
					return originalBitmapData;
				}
			} else {
				//Do nothing;
				return originalBitmapData;
			}

			var containerRatio:Number = targetWidth / targetHeight;
			var imageRatio:Number = contentWidth / contentHeight;

			if (containerRatio < imageRatio) {
				targetHeight = targetWidth / imageRatio;
			} else {
				targetWidth = targetHeight * imageRatio;
			}

			var matrix:Matrix = new Matrix();
			matrix.scale(targetWidth / contentWidth, targetHeight / contentHeight);

			var scaledBitmapData:BitmapData = new BitmapData(targetWidth, targetHeight, false, 0x000000);
			scaledBitmapData.draw(originalBitmapData, matrix, null, null, null, true);

			return scaledBitmapData;
		}

		private function uploadThumbnail(event:starling.events.Event):void
		{
			if (nameInput.text != "") {
				now = new Date().getTime();

				//We prepare the thumbnail for upload
				var byteArray:ByteArray = new ByteArray();

				var thumbBitmapData:BitmapData = scaleBMD(myBitmapData, "thumbnail");
				thumbBitmapData.encode(new Rectangle(0, 0, thumbBitmapData.width, thumbBitmapData.height), new JPEGEncoderOptions(), byteArray);

				var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.FirebaseAuthToken);

				var request:URLRequest = new URLRequest(Constants.FIREBASE_STORAGE_URL + "images%2Fthumbs%2F" + String(now) + ".jpg");
				request.method = URLRequestMethod.POST;
				request.data = byteArray;
				request.contentType = "image/jpeg";
				request.requestHeaders.push(header);

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(flash.events.Event.COMPLETE, thumbnailUploaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(request);

				alert = Alert.show("Uploading, please wait.", "Uploading Picture");
				alert.width = 200;
			} else {
				alert = Alert.show("A name is required.", "Error", new ListCollection([{label: "OK"}]));
			}
		}

		private function thumbnailUploaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, thumbnailUploaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);
			thumbUrl = rawData.name;

			//We prepare the scaled image for upload
			var byteArray:ByteArray = new ByteArray();

			var scaledBitmapData:BitmapData = scaleBMD(myBitmapData, "scale");
			scaledBitmapData.encode(new Rectangle(0, 0, scaledBitmapData.width, scaledBitmapData.height), new JPEGEncoderOptions(), byteArray);

			var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.FirebaseAuthToken);

			var request:URLRequest = new URLRequest(Constants.FIREBASE_STORAGE_URL + "images%2F" + String(now) + ".jpg");
			request.method = URLRequestMethod.POST;
			request.data = byteArray;
			request.contentType = "image/jpeg";
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, imageUploaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function imageUploaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, imageUploaded);

			//Once the file has been uploaded we add a reference to it to the database

			var rawData:Object = JSON.parse(event.currentTarget.data);

			var myObject:Object = new Object();
			myObject.url = rawData.name;
			myObject.thumb_url = thumbUrl;
			myObject.uploaderId = Main.profile.localId;
			myObject.uploaderName = Main.profile.displayName;
			myObject.uploadererAvatar = Main.profile.photoUrl;
			myObject.status = "pending";
			myObject.title = nameInput.text;
			myObject.views = 0;
			myObject.timestamp = new Date().getTime();

			var request:URLRequest = new URLRequest(Constants.FIREBASE_IMAGES_GALLERY_URL + ".json?auth=" + _data.FirebaseAuthToken);
			request.data = JSON.stringify(myObject);
			request.method = URLRequestMethod.POST;

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, insertComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function insertComplete(event:flash.events.Event):void
		{
			//The reference has been added to the database, we send the user back to the gallery
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, insertComplete);

			if (alert) {
				alert.removeFromParent(true);
			}

			goBack();
		}

		private function errorHandler(event:flash.events.Event):void
		{
			trace(event.currentTarget.data);
		}

		private function mediaError(event:ErrorEvent):void
		{
			trace("Media Error");
		}

		private function browseCanceled(event:flash.events.Event):void
		{
			trace("Media select canceled");
		}

		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

		override public function dispose():void
		{
			//All of these objects need to be manually disposed to avoid memory leaks

			if (cameraUI) {
				cameraUI = null;
			}
			;
			if (cameraRoll) {
				cameraRoll = null;
			}

			if (myTexture) {
				myTexture.dispose();
				myTexture = null;
			}

			dataSource = null;
			myBitmapData = null;

			super.dispose();
		}

	}
}