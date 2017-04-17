package screens
{
	import feathers.controls.Alert;
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
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
	import starling.events.Event;
	import starling.text.TextFormat;

	import utils.ProfileManager;
	import utils.RoundedRect;

	public class SettingsScreen extends PanelScreen
	{
		public static const GO_LOGIN:String = "goLogin";

		private var alert:Alert;
		private var mainGroup:ScrollContainer;
		private var nameInput:TextInput;

		override protected function initialize():void
		{
			super.initialize();

			this.title = "Settings";
			this.layout = new AnchorLayout();

			var menuButton:Button = new Button();
			menuButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(Main.OPEN_MENU);
			});
			menuButton.styleNameList.add("menu-button");
			this.headerProperties.leftItems = new <DisplayObject>[menuButton];

			var layoutForMainGroup:VerticalLayout = new VerticalLayout();
			layoutForMainGroup.horizontalAlign = HorizontalAlign.CENTER;
			layoutForMainGroup.padding = 10;
			layoutForMainGroup.gap = 10;

			mainGroup = new ScrollContainer();
			mainGroup.layout = layoutForMainGroup;
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(mainGroup);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			if (ProfileManager.isLoggedIn() === false) {
				loadLoggedOffUI();
			} else {
				loadLoggedInUI();
			}
		}

		private function loadLoggedOffUI():void
		{
			var spacer1:BasicButton = new BasicButton();
			spacer1.layoutData = new VerticalLayoutData(100, 100);
			mainGroup.addChild(spacer1);

			var label1:Label = new Label();
			label1.text = "Settings are only available for logged in users.";
			label1.fontStyles = new TextFormat("_sans", 18, 0x00000, "center");
			label1.layoutData = new VerticalLayoutData(100, NaN);
			label1.wordWrap = true;
			mainGroup.addChild(label1);

			var spacer2:BasicButton = new BasicButton();
			spacer2.height = 5
			mainGroup.addChild(spacer2);

			var signInButton:Button = new Button();
			signInButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(GO_LOGIN);
			})
			signInButton.styleNameList.add("rounded-button");
			signInButton.label = "Sign In";
			signInButton.width = 150;
			signInButton.paddingLeft = 0;
			signInButton.horizontalAlign = HorizontalAlign.CENTER;
			mainGroup.addChild(signInButton);

			var spacer3:BasicButton = new BasicButton();
			spacer3.layoutData = new VerticalLayoutData(100, 100);
			mainGroup.addChild(spacer3);
		}

		private function loadLoggedInUI():void
		{
			var spacer1:BasicButton = new BasicButton();
			spacer1.height = 1
			mainGroup.addChild(spacer1);

			var label1:Label = new Label();
			label1.text = "Change displayed name:";
			label1.layoutData = new VerticalLayoutData(100, NaN);
			mainGroup.addChild(label1);

			nameInput = new TextInput();
			nameInput.layoutData = new VerticalLayoutData(100, NaN);
			nameInput.text = Main.profile.displayName;
			nameInput.prompt = "Type your desired display name";
			mainGroup.addChild(nameInput);

			var spacer2:BasicButton = new BasicButton();
			spacer2.layoutData = new VerticalLayoutData(NaN, 100);
			mainGroup.addChild(spacer2);

			var saveIcon:ImageLoader = new ImageLoader();
			saveIcon.source = "assets/icons/save.png";
			saveIcon.width = saveIcon.height = 25;

			var saveButton:Button = new Button();
			saveButton.addEventListener(starling.events.Event.TRIGGERED, getAccessToken);
			saveButton.layoutData = new VerticalLayoutData(100, NaN);
			saveButton.styleNameList.add("rounded-button");
			saveButton.label = "Save Changes";
			saveButton.defaultIcon = saveIcon;
			mainGroup.addChild(saveButton);

			var signOutIcon:ImageLoader = new ImageLoader();
			signOutIcon.source = "assets/icons/logout.png";
			signOutIcon.width = signOutIcon.height = 25;

			var signOutButton:Button = new Button();
			signOutButton.addEventListener(starling.events.Event.TRIGGERED, attemptSingOut);
			signOutButton.layoutData = new VerticalLayoutData(100, NaN);
			signOutButton.styleNameList.add("rounded-button");
			signOutButton.label = "Sign Out";
			signOutButton.defaultIcon = signOutIcon;
			mainGroup.addChild(signOutButton);
		}

		private function getAccessToken():void
		{
			if (nameInput.text != "") {
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
			} else {
				alert = Alert.show("Display name is a required field.", "Error", new ListCollection([{label: "OK"}]));
			}
		}

		private function accessTokenLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, accessTokenLoaded);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			var myObject:Object = new Object();
			myObject.displayName = nameInput.text;
			myObject.idToken = rawData.access_token;

			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var request:URLRequest = new URLRequest(Constants.FIREBASE_ACCOUNT_SETINFO_URL);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(flash.events.Event.COMPLETE, nameUpdated);
			loader.load(request);
		}

		private function nameUpdated(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, nameUpdated);

			//After the name was updated in the Firebase Auth service we update it locally

			var rawData:Object = JSON.parse(event.currentTarget.data);
			Main.displayName.text = "Welcome,\n<b>" + rawData.displayName + "</b>";
			Main.profile.displayName = rawData.displayName;
			ProfileManager.saveProfile(Main.profile);
			alert = Alert.show("Display name successfully updated.", "Success", new ListCollection([{label: "OK"}]));
		}

		private function attemptSingOut(event:starling.events.Event):void
		{
			alert = Alert.show("Do you really want to sign out from this app?", "Sign Out", new ListCollection(
					[
						{label: "Cancel"},
						{label: "OK"}
					]));

			alert.addEventListener(starling.events.Event.CLOSE, function (event:starling.events.Event, data:Object):void
			{
				if (data.label == "OK") {
					//User profile data will be cleared from the app and logged in information will be cleared
					ProfileManager.signOut();
					Main.avatar.source = "assets/icons/account_circle.png";
					Main.displayName.text = "Welcome Guest";

					mainGroup.removeChildren();
					loadLoggedOffUI();
				}
			});
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			trace(event.currentTarget.data);
		}
	}
}