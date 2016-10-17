package
{
	import businessScreens.BusinessDetailsScreen;
	import businessScreens.DirectionsScreen;
	import businessScreens.FinderScreen;
	import businessScreens.ResultsScreen;

	import chatScreens.ChatScreen;
	import chatScreens.ChatroomsScreen;

	import feathers.controls.Drawers;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.motion.Cover;
	import feathers.motion.Fade;
	import feathers.motion.Reveal;

	import flash.text.TextFormat;

	import galleryScreens.GalleryScreen;
	import galleryScreens.ImageDetailsScreen;
	import galleryScreens.UploadImageScreen;

	import newsScreens.HomeScreen;
	import newsScreens.NewsDetailsScreen;

	import screens.LoginScreen;
	import screens.SettingsScreen;

	import starling.display.Canvas;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.ProfileManager;

	public class Main extends Sprite
	{
		public function Main()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private var drawers:Drawers;
		private var myNavigator:StackScreenNavigator;
		private var list:List;
		private var NAVIGATOR_DATA:NavigatorData;

		public static var profile:Object;
		public static var avatar:ImageLoader;
		public static var displayName:Label;

		public static const OPEN_MENU:String = "openMenu";

		private static const HOME_SCREEN:String = "homeScreen";
		private static const NEWS_DETAILS_SCREEN:String = "newsDetailsScreen";
		private static const LOGIN_SCREEN:String = "loginScreen";
		private static const FINDER_SCREEN:String = "finderScreen";
		private static const RESULTS_SCREEN:String = "resultsScreen";
		private static const BUSINESS_DETAILS_SCREEN:String = "businessDetailsScreen";
		private static const DIRECTIONS_SCREEN:String = "directionsScreen";
		private static const CHATROOMS_SCREEN:String = "chatroomsScreen";
		private static const CHAT_SCREEN:String = "chatScreen";
		private static const GALLERY_SCREEN:String = "galleryScreen";
		private static const IMAGE_DETAILS_SCREEN:String = "imageDetailsScreen";
		private static const UPLOAD_SCREEN:String = "uploadScreen";
		private static const SETTINGS_SCREEN:String = "settingsScreen";

		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

			this.NAVIGATOR_DATA = new NavigatorData();

			new CustomTheme();

			createDrawer();

			//We create the StackScreenNavigator and add the screens

			myNavigator = new StackScreenNavigator();
			myNavigator.pushTransition = Fade.createFadeInTransition();
			myNavigator.popTransition = Fade.createFadeOutTransition();
			drawers.content = myNavigator;

			var homeScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HomeScreen);
			homeScreenItem.properties.data = NAVIGATOR_DATA;
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_NEWS_DETAILS, NEWS_DETAILS_SCREEN);
			myNavigator.addScreen(HOME_SCREEN, homeScreenItem);

			var newsDetailsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(NewsDetailsScreen);
			newsDetailsScreenItem.properties.data = NAVIGATOR_DATA;
			newsDetailsScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(NEWS_DETAILS_SCREEN, newsDetailsScreenItem);

			var loginScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(LoginScreen);
			loginScreenItem.pushTransition = Cover.createCoverUpTransition();
			loginScreenItem.popTransition = Reveal.createRevealDownTransition();
			loginScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(LOGIN_SCREEN, loginScreenItem);

			var finderScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(FinderScreen);
			finderScreenItem.properties.data = NAVIGATOR_DATA;
			finderScreenItem.addPopEvent(Event.COMPLETE);
			finderScreenItem.setScreenIDForPushEvent(FinderScreen.GO_RESULTS, RESULTS_SCREEN);
			myNavigator.addScreen(FINDER_SCREEN, finderScreenItem);

			var resultsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ResultsScreen);
			resultsScreenItem.pushTransition = Fade.createFadeInTransition(0);
			resultsScreenItem.properties.data = NAVIGATOR_DATA;
			resultsScreenItem.addPopEvent(Event.COMPLETE);
			resultsScreenItem.setScreenIDForPushEvent(ResultsScreen.GO_DETAILS, BUSINESS_DETAILS_SCREEN);
			myNavigator.addScreen(RESULTS_SCREEN, resultsScreenItem);

			var businessDetailsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(BusinessDetailsScreen);
			businessDetailsScreenItem.properties.data = NAVIGATOR_DATA;
			businessDetailsScreenItem.addPopEvent(Event.COMPLETE);
			businessDetailsScreenItem.setScreenIDForPushEvent(BusinessDetailsScreen.GO_DIRECTIONS, DIRECTIONS_SCREEN);
			myNavigator.addScreen(BUSINESS_DETAILS_SCREEN, businessDetailsScreenItem);

			var directionsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DirectionsScreen);
			directionsScreenItem.pushTransition = Cover.createCoverUpTransition();
			directionsScreenItem.popTransition = Reveal.createRevealDownTransition();
			directionsScreenItem.properties.data = NAVIGATOR_DATA;
			directionsScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(DIRECTIONS_SCREEN, directionsScreenItem);

			var chatroomsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ChatroomsScreen);
			chatroomsScreenItem.properties.data = NAVIGATOR_DATA;
			chatroomsScreenItem.addPopEvent(Event.COMPLETE);
			chatroomsScreenItem.setScreenIDForPushEvent(ChatroomsScreen.GO_CHAT, CHAT_SCREEN);
			chatroomsScreenItem.setScreenIDForPushEvent(ChatroomsScreen.GO_LOGIN, LOGIN_SCREEN);
			myNavigator.addScreen(CHATROOMS_SCREEN, chatroomsScreenItem);

			var chatScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ChatScreen);
			chatScreenItem.properties.data = NAVIGATOR_DATA;
			chatScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(CHAT_SCREEN, chatScreenItem);

			var galleryScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(GalleryScreen);
			galleryScreenItem.properties.data = NAVIGATOR_DATA;
			galleryScreenItem.setScreenIDForPushEvent(GalleryScreen.GO_IMAGE_DETAILS, IMAGE_DETAILS_SCREEN);
			galleryScreenItem.setScreenIDForPushEvent(GalleryScreen.GO_LOGIN, LOGIN_SCREEN);
			galleryScreenItem.setScreenIDForPushEvent(GalleryScreen.GO_UPLOAD, UPLOAD_SCREEN);
			myNavigator.addScreen(GALLERY_SCREEN, galleryScreenItem);

			var imageDetailsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ImageDetailsScreen);
			imageDetailsScreenItem.properties.data = NAVIGATOR_DATA;
			imageDetailsScreenItem.setScreenIDForPushEvent(ImageDetailsScreen.GO_LOGIN, LOGIN_SCREEN);
			imageDetailsScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(IMAGE_DETAILS_SCREEN, imageDetailsScreenItem);

			var uploadImageScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(UploadImageScreen);
			uploadImageScreenItem.properties.data = NAVIGATOR_DATA;
			uploadImageScreenItem.addPopEvent(Event.COMPLETE);
			myNavigator.addScreen(UPLOAD_SCREEN, uploadImageScreenItem);

			var settingsScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SettingsScreen);
			settingsScreenItem.addPopEvent(Event.COMPLETE);
			settingsScreenItem.setScreenIDForPushEvent(SettingsScreen.GO_LOGIN, LOGIN_SCREEN);
			myNavigator.addScreen(SETTINGS_SCREEN, settingsScreenItem);

			myNavigator.rootScreenID = HOME_SCREEN;

		}

		private function createDrawer():void
		{
			var leftGroup:LayoutGroup = new LayoutGroup();
			leftGroup.layout = new VerticalLayout();
			leftGroup.width = 200;

			var topGroupSkin:Quad = new Quad(3, 50);
			topGroupSkin.setVertexColor(0, 0x01579B);
			topGroupSkin.setVertexColor(1, 0x01579B);
			topGroupSkin.setVertexColor(2, 0x0277BD);
			topGroupSkin.setVertexColor(3, 0x0277BD);

			var topGroup:LayoutGroup = new LayoutGroup();
			topGroup.backgroundSkin = topGroupSkin;
			topGroup.layout = new AnchorLayout();
			topGroup.layoutData = new VerticalLayoutData(100, NaN);
			topGroup.height = 50;
			leftGroup.addChild(topGroup);

			var avatarMask:Canvas = new Canvas();
			avatarMask.drawCircle(15, 15, 15);

			avatar = new ImageLoader();
			avatar.width = avatar.height = 30;
			avatar.mask = avatarMask;
			avatar.layoutData = new AnchorLayoutData(NaN, NaN, NaN, 10, NaN, 0);
			topGroup.addChild(avatar);

			displayName = new Label();
			displayName.styleProvider = null;
			displayName.layoutData = new AnchorLayoutData(NaN, 10, NaN, 50, NaN, 0);
			displayName.textRendererFactory = function ():ITextRenderer
			{
				var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();

				var format:TextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
				format.leading = 3;
				renderer.isHTML = true;
				renderer.textFormat = format;
				return renderer;
			};
			topGroup.addChild(displayName);

			list = new List();
			list.styleProvider = null;
			list.hasElasticEdges = false;
			list.itemRendererFactory = function ():DefaultListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.styleNameList.add("drawer-itemrenderer");
				renderer.iconSourceField = "icon";

				renderer.iconLoaderFactory = function ():ImageLoader
				{
					var loader:ImageLoader = new ImageLoader();
					loader.width = loader.height = 25;
					return loader;
				};

				return renderer;
			};
			list.dataProvider = new ListCollection(
					[
						{screen: HOME_SCREEN, label: "Home", icon: "assets/icons/home.png"},
						{screen: FINDER_SCREEN, label: "Find Pizza", icon: "assets/icons/search.png"},
						{screen: CHATROOMS_SCREEN, label: "Chat Rooms", icon: "assets/icons/chat.png"},
						{screen: GALLERY_SCREEN, label: "Gallery", icon: "assets/icons/gallery.png"},
						{screen: SETTINGS_SCREEN, label: "Settings", icon: "assets/icons/settings.png"}
					]);
			list.backgroundSkin = new Quad(3, 3, 0x37474F);
			list.selectedIndex = 0;
			list.layoutData = new VerticalLayoutData(100, 100);
			list.addEventListener(Event.CHANGE, changeHandler);
			leftGroup.addChild(list);

			var overlaySkin:Quad = new Quad(3, 3, 0x000000);
			overlaySkin.alpha = 0.50;

			drawers = new Drawers();
			drawers.overlaySkin = overlaySkin;
			drawers.leftDrawerToggleEventType = OPEN_MENU;
			drawers.leftDrawer = leftGroup;
			this.addChild(drawers);

			//Once our drawer and its content is created we load the logged in user profile

			profile = ProfileManager.loadProfile();

			if (profile.photoUrl != null) {
				avatar.source = profile.photoUrl;
			} else {
				avatar.source = "assets/icons/account_circle.png";
			}

			if (profile.displayName != null) {
				displayName.text = "Welcome,\n<b>" + profile.displayName + "</b>";
			} else {
				displayName.text = "Welcome Guest";
			}
		}


		private function changeHandler(event:Event):void
		{
			drawers.toggleLeftDrawer();
			var screen:String = list.selectedItem.screen;
			myNavigator.pushScreen(screen);
		}

	}
}