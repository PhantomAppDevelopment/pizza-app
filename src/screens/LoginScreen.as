package screens
{
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.WebView;
	import feathers.core.PopUpManager;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.ProfileManager;
	import utils.RoundedRect;

	public class LoginScreen extends PanelScreen
	{
		private var popup:Panel;
		private var webView:WebView;
		private var sessionId:String;
		private var requestUri:String;

		private var isOpen:Boolean;

		override protected function initialize():void
		{
			super.initialize();

			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.horizontalAlign = HorizontalAlign.CENTER;
			myLayout.gap = 15;

			this.title = "Select a Login Provider";
			this.layout = myLayout;
			this.backButtonHandler = goBack;
			this.headerProperties.paddingLeft = 10;

			var cancelIcon:ImageLoader = new ImageLoader();
			cancelIcon.width = cancelIcon.height = 25;
			cancelIcon.source = "assets/icons/cancel.png";

			var cancelButton:Button = new Button();
			cancelButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			cancelButton.styleNameList.add("header-button");
			cancelButton.defaultIcon = cancelIcon;
			this.headerProperties.rightItems = new <DisplayObject>[cancelButton];

			isOpen = false;

			var spacer1:BasicButton = new BasicButton();
			spacer1.layoutData = new VerticalLayoutData(100, 100);
			this.addChild(spacer1);

			var label1:Label = new Label();
			label1.styleNameList.add("big-label");
			label1.text = "Social Login";
			this.addChild(label1);

			var layoutForButtonsContainer:VerticalLayout = new VerticalLayout();
			layoutForButtonsContainer.gap = 10;
			layoutForButtonsContainer.padding = 10;

			var buttonsContainer:LayoutGroup = new LayoutGroup();
			buttonsContainer.width = 280;
			buttonsContainer.layout = layoutForButtonsContainer;
			buttonsContainer.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(buttonsContainer);

			var facebookIcon:ImageLoader = new ImageLoader();
			facebookIcon.source = "assets/icons/facebook.png";
			facebookIcon.width = facebookIcon.height = 25;

			var signInFacebookButton:Button = new Button();
			signInFacebookButton.layoutData = new VerticalLayoutData(100, NaN);
			signInFacebookButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				startAuth("facebook.com");
			});
			signInFacebookButton.styleNameList.add("rounded-button");
			signInFacebookButton.label = "Sign in with Facebook";
			signInFacebookButton.defaultIcon = facebookIcon;
			buttonsContainer.addChild(signInFacebookButton);

			signInFacebookButton.defaultSkin = RoundedRect.createRoundedRect(0x3b5998);
			signInFacebookButton.downSkin = RoundedRect.createRoundedRect(0x314A7F);

			var twitterIcon:ImageLoader = new ImageLoader();
			twitterIcon.source = "assets/icons/twitter.png";
			twitterIcon.width = twitterIcon.height = 25;

			var signInTwitterButton:Button = new Button();
			signInTwitterButton.layoutData = new VerticalLayoutData(100, NaN);
			signInTwitterButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				startAuth("twitter.com");
			});
			signInTwitterButton.styleNameList.add("rounded-button");
			signInTwitterButton.label = "Sign in with Twitter";
			signInTwitterButton.defaultIcon = twitterIcon;
			buttonsContainer.addChild(signInTwitterButton);

			signInTwitterButton.defaultSkin = RoundedRect.createRoundedRect(0x55ACEE);
			signInTwitterButton.downSkin = RoundedRect.createRoundedRect(0x489DD);

			var googleIcon:ImageLoader = new ImageLoader();
			googleIcon.source = "assets/icons/google.png";
			googleIcon.width = googleIcon.height = 25;

			var signInGoogleButton:Button = new Button();
			signInGoogleButton.layoutData = new VerticalLayoutData(100, NaN);
			signInGoogleButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				startAuth("google.com");
			});
			signInGoogleButton.styleNameList.add("rounded-button");
			signInGoogleButton.label = "Sign in with Google";
			signInGoogleButton.defaultIcon = googleIcon;
			buttonsContainer.addChild(signInGoogleButton);

			signInGoogleButton.defaultSkin = RoundedRect.createRoundedRect(0xD34836);
			signInGoogleButton.downSkin = RoundedRect.createRoundedRect(0xBA3D2D);

			var spacer2:BasicButton = new BasicButton();
			spacer2.layoutData = new VerticalLayoutData(100, 100);
			this.addChild(spacer2);
		}

		private function startAuth(provider:String):void
		{
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var myObject:Object = new Object();
			myObject.continueUri = Constants.FIREBASE_REDIRECT_URL;
			myObject.providerId = provider;

			var request:URLRequest = new URLRequest(Constants.FIREBASE_CREATE_AUTH_URL);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, authURLCreated);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function authURLCreated(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, authURLCreated);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			//We store the sessionId value from the response
			sessionId = rawData.sessionId;

			webView = new WebView();
			webView.addEventListener(FeathersEventType.LOCATION_CHANGE, changeLocation);
			webView.layoutData = new VerticalLayoutData(100, 100);

			webView.width = 310;
			webView.height = 380;

			//We load the URL from the response, it will automatically contain the client id, scopes and the redirect URL
			webView.loadURL(rawData.authUri);

			popup = new Panel();
			popup.headerProperties.paddingLeft = 10;
			popup.title = "Sign In";
			popup.addChild(webView);

			var closeIcon:ImageLoader = new ImageLoader();
			closeIcon.source = "assets/icons/close.png";
			closeIcon.width = closeIcon.height = 25;

			var closeButton:Button = new Button();
			closeButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				isOpen = false;
				webView.dispose();
				PopUpManager.removePopUp(popup, true);
			});
			closeButton.styleNameList.add("header-button");
			closeButton.defaultIcon = closeIcon;
			popup.headerProperties.rightItems = new <DisplayObject>[closeButton];

			PopUpManager.addPopUp(popup, true, true, function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;
			});

			isOpen = true;
		}

		private function changeLocation(event:starling.events.Event):void
		{
			var location:String = webView.location;

			if (location.indexOf("/__/auth/handler?code=") != -1 || location.indexOf("/__/auth/handler?state=") != -1 || location.indexOf("/__/auth/handler#state=") != -1) {

				//We are looking for a code parameter in the URL, once we have it we dispose the webview and prepare the last URLRequest	
				webView.removeEventListener(FeathersEventType.LOCATION_CHANGE, changeLocation);
				webView.dispose();
				PopUpManager.removePopUp(popup, true);
				isOpen = false;

				requestUri = location;
				getAccountInfo();
			}
		}

		private function getAccountInfo():void
		{
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var myObject:Object = new Object();
			myObject.requestUri = requestUri;
			myObject.sessionId = sessionId;
			myObject.returnSecureToken = true;

			var request:URLRequest = new URLRequest(Constants.FIREBASE_VERIFY_ASSERTION_URL);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, registerComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}


		private function registerComplete(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, registerComplete);

			//The profile data is returned abck from Firebase, we call our ProfileManager and save the data in a local file

			var rawData:Object = JSON.parse(event.currentTarget.data);
			trace(event.currentTarget.data);
			ProfileManager.saveProfile(rawData);

			Main.profile = rawData;
			Main.displayName.text = "Welcome,\n<b>" + rawData.displayName + "</b>";
			Main.avatar.source = rawData.photoUrl;

			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			trace(event.currentTarget.data);
		}

		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

		override public function dispose():void
		{
			if (isOpen == true) {
				webView.dispose();
				PopUpManager.removePopUp(popup, true);
			}

			super.dispose();
		}

	}
}