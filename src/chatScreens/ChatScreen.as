package chatScreens
{
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.ChatMessageItemRenderer;
	import utils.NavigatorData;
	import utils.RoundedRect;

	public class ChatScreen extends PanelScreen
	{
		private var isListFocused:Boolean;

		private var messagesArray:Array;
		private var messagesList:List;
		private var messageInput:TextInput;
		private var messagesStream:URLStream;

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

			this.title = _data.selectedRoom.name;
			this.layout = new VerticalLayout();
			this.backButtonHandler = goBack;

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			messagesArray = new Array();

			var layoutForMessagesList:VerticalLayout = new VerticalLayout();
			layoutForMessagesList.hasVariableItemDimensions = true;
			layoutForMessagesList.horizontalAlign = HorizontalAlign.JUSTIFY;
			layoutForMessagesList.gap = 5;

			messagesList = new List();
			messagesList.paddingTop = messagesList.paddingBottom = 10;
			messagesList.layout = layoutForMessagesList;
			messagesList.itemRendererType = ChatMessageItemRenderer;
			messagesList.layoutData = new VerticalLayoutData(100, 100);
			messagesList.dataProvider = new ListCollection(messagesArray);
			this.addChild(messagesList);

			var layoutForBottomGroup:HorizontalLayout = new HorizontalLayout();
			layoutForBottomGroup.paddingLeft = layoutForBottomGroup.paddingRight = 10;
			layoutForBottomGroup.verticalAlign = VerticalAlign.MIDDLE;
			layoutForBottomGroup.gap = 10;

			var bottomGroupSkin:Quad = new Quad(3, 50);
			bottomGroupSkin.setVertexColor(0, 0x01579B);
			bottomGroupSkin.setVertexColor(1, 0x01579B);
			bottomGroupSkin.setVertexColor(2, 0x0277BD);
			bottomGroupSkin.setVertexColor(3, 0x0277BD);

			var bottomGroup:LayoutGroup = new LayoutGroup();
			bottomGroup.backgroundSkin = bottomGroupSkin;
			bottomGroup.layout = layoutForBottomGroup;
			bottomGroup.layoutData = new VerticalLayoutData(100, NaN);
			bottomGroup.height = 70;

			this.addChild(bottomGroup);

			var spacer:BasicButton = new BasicButton();
			spacer.width = 10;
			spacer.height = 0;
			this.addChild(spacer);

			messageInput = new TextInput();
			messageInput.layoutData = new HorizontalLayoutData(100, NaN);
			messageInput.height = 50;
			messageInput.prompt = "Type your message here";
			messageInput.textEditorProperties.maintainTouchFocus = true;
			bottomGroup.addChild(messageInput);
			messageInput.backgroundSkin = RoundedRect.createRoundedRect(0x263238);

			var sendIcon:ImageLoader = new ImageLoader();
			sendIcon.source = "assets/icons/send.png";
			sendIcon.width = sendIcon.height = 25;

			var sendButton:Button = new Button();
			sendButton.addEventListener(starling.events.Event.TRIGGERED, sendMessage);
			sendButton.width = sendButton.height = 50;
			sendButton.defaultIcon = sendIcon;
			sendButton.defaultSkin = new Quad(50, 50, 0x000000);
			bottomGroup.addChild(sendButton);
			sendButton.defaultSkin = RoundedRect.createRoundedRect(0x263238);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
			loadMessages();
		}

		protected function loadMessages():void
		{
			var header:URLRequestHeader = new URLRequestHeader("Accept", "text/event-stream");
			var request:URLRequest = new URLRequest(Constants.FIREBASE_CHATROOM_BASE_URL + _data.selectedRoom.id + '.json?auth='
					+ _data.FirebaseAuthToken + '&orderBy="timestamp"&limitToLast=100'); //We are always loading the last 100 messages
			request.requestHeaders.push(header);

			messagesStream = new URLStream();
			messagesStream.addEventListener(ProgressEvent.PROGRESS, progress);
			messagesStream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			messagesStream.load(request);
		}

		private function progress(event:ProgressEvent):void
		{
			//We are continously listening responses and response codes

			var message:String = messagesStream.readUTFBytes(messagesStream.bytesAvailable);
			//trace(message);

			//If a message contains the null value it means nothing happened and we skip it

			if (message.indexOf("null") == -1) {
				//Otherwise we take the JSON part of the response and convert it into an Object
				message = message.substr(message.indexOf("data:") + 6, message.length);

				var rawData:Object = JSON.parse(message);

				//The first time we connect to the database it will return saved messages in a different structure
				//Even if we requested the data sorted by timestamp, the JSON parser scrambles it, so we have to put it in an Array

				var tempArray:Array = new Array();

				for each(var item:Object in rawData.data) {
					if (item.hasOwnProperty("message")) {
						tempArray.push(item);
					}
				}

				//We sort our data by timestamp so it shows the most recent messages at the bottom, like in all messaging apps
				tempArray.sortOn("timestamp");

				for (var i:uint = 0; i < tempArray.length; i++) {
					//We add the contents of the sorted array to the dataprovider
					messagesList.dataProvider.addItem(tempArray[i]);
				}

				//For the individual messages the structure is more simple, we just make sure it contains a message
				if (Object(rawData.data).hasOwnProperty("message")) {
					messagesList.dataProvider.addItem(rawData.data);
				}

				//If the list is not focused we automatically scroll it to the bottom
				if (isListFocused == false) {
					messagesList.scrollToDisplayIndex(messagesList.dataProvider.data.length - 1);
				}

				//Clean up
				tempArray = null;
				rawData = null;
				message = null;
			}
		}

		private function sendMessage():void
		{
			if (messageInput.text != "") {
				//We prepare the vars to be send to the database, including the logged-in user basic info
				var myObject:Object = new Object();
				myObject.message = messageInput.text;
				myObject.timestamp = new Date().getTime();
				myObject.senderId = Main.profile.localId;
				myObject.senderName = Main.profile.displayName;

				var request:URLRequest = new URLRequest(Constants.FIREBASE_CHATROOM_BASE_URL + _data.selectedRoom.id + ".json?auth=" + _data.FirebaseAuthToken);
				request.data = JSON.stringify(myObject);
				request.method = URLRequestMethod.POST;

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(flash.events.Event.COMPLETE, messageSent);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(request);
			}
		}

		private function messageSent(event:flash.events.Event):void
		{
			event.currentTarget.addEventListener(flash.events.Event.COMPLETE, messageSent);
			messageInput.text = "";
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
			//Remove the event listener or you will be still receiving messages
			messagesStream.removeEventListener(ProgressEvent.PROGRESS, progress);
			messagesList.dataProvider = null;

			super.dispose();
		}

	}
}