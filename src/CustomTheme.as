package
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.ButtonState;
	import feathers.controls.Header;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.TabBar;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.themes.StyleNameFunctionTheme;

	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.text.TextFormat;

	import utils.RoundedRect;

	public class CustomTheme extends StyleNameFunctionTheme
	{
		[Embed(source="assets/fonts/playball.ttf", fontFamily="MyFont", fontWeight="normal", fontStyle="normal", mimeType="application/x-font", embedAsCFF="false")]
		private static const MY_FONT:Class;

		private var playballFont:FontDescription;
		private var transparentQuad:Quad = new Quad(3, 3, 0xFFFFFF);

		public function CustomTheme()
		{
			super();

			this.transparentQuad.alpha = 0.0;
			this.initialize();
		}

		private function initialize():void
		{
			Alert.overlayFactory = function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;
			};

			playballFont = new FontDescription("MyFont");
			playballFont.fontLookup = FontLookup.EMBEDDED_CFF;

			this.initializeGlobals();
			this.initializeStyleProviders();
		}

		private function initializeGlobals():void
		{
			FeathersControl.defaultTextRendererFactory = function ():ITextRenderer
			{
				var renderer:TextFieldTextRenderer = new TextFieldTextRenderer()();
				renderer.wordWrap = true;
				renderer.isHTML = true;
				return renderer;
			}

			FeathersControl.defaultTextEditorFactory = function ():ITextEditor
			{
				return new StageTextTextEditor();
			}
		}

		private function initializeStyleProviders():void
		{
			this.getStyleProviderForClass(Button).setFunctionForStyleName("alert-button", setAlertButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("horizontal-button", this.setHorizontalButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("vertical-button", this.setVerticalButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("back-button", this.setBackButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("menu-button", this.setMenuButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("header-button", this.setHeaderButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("rounded-button", this.setRoundedButtonStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("big-label", this.setBigLabelStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("date-label", this.setDateLabelStyles);
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("drawer-itemrenderer", this.setDrawerItemRendererStyles);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("custom-tab", setTabStyles);


			this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
			this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
			this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
			this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
			this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
			this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
			this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
			this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		}

		//-------------------------
		// Alert
		//-------------------------

		private function setAlertStyles(alert:Alert):void
		{
			alert.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			alert.maxWidth = 280;
			alert.minHeight = 50;
			alert.padding = 10;

			alert.headerProperties.paddingLeft = 10;
			alert.headerProperties.gap = 10;
			alert.headerProperties.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;
			alert.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			alert.fontStyles.leading = 7;

			alert.buttonGroupFactory = function ():ButtonGroup
			{
				var group:ButtonGroup = new ButtonGroup();
				group.customButtonStyleName = "alert-button";
				group.direction = ButtonGroup.DIRECTION_HORIZONTAL;
				group.gap = 10;
				group.padding = 10;
				return group;
			}
		}

		//-------------------------
		// Button
		//-------------------------

		private function setAlertButtonStyles(button:Button):void
		{
			button.defaultSkin = RoundedRect.createRoundedRect(0x1565C0);
			button.downSkin = RoundedRect.createRoundedRect(0x0D47A1);
			button.gap = 15;
			button.height = 40;
			button.width = 250;
			button.fontStyles = new TextFormat("_sans", 16, 0xFFFFFF);
		}

		private function setHeaderButtonStyles(button:Button):void
		{
			button.height = button.width = 45;

			var quad:Quad = new Quad(45, 45, 0xFFFFFF);
			quad.alpha = .3;

			button.downSkin = quad;
		}

		private function setBackButtonStyles(button:Button):void
		{
			button.height = button.width = 45;

			var backButtonIcon:ImageLoader = new ImageLoader();
			backButtonIcon.source = "assets/icons/back.png";
			backButtonIcon.height = backButtonIcon.width = 25;

			button.defaultIcon = backButtonIcon;

			var quad:Quad = new Quad(45, 45, 0xFFFFFF);
			quad.alpha = .3;

			button.downSkin = quad;
		}

		private function setMenuButtonStyles(button:Button):void
		{
			button.height = button.width = 45;

			var menuButtonIcon:ImageLoader = new ImageLoader();
			menuButtonIcon.source = "assets/icons/menu.png";
			menuButtonIcon.height = menuButtonIcon.width = 25;

			button.defaultIcon = menuButtonIcon;

			var quad:Quad = new Quad(45, 45, 0xFFFFFF);
			quad.alpha = .3;

			button.downSkin = quad;
		}

		private function setHorizontalButtonStyles(button:Button):void
		{
			button.iconPosition = Button.ICON_POSITION_LEFT;
			button.horizontalAlign = HorizontalAlign.LEFT;
			button.verticalAlign = VerticalAlign.MIDDLE;
			button.gap = 10;
			button.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			button.fontStyles.leading = 5;
			button.defaultLabelProperties.wordWrap = true;
		}

		private function setVerticalButtonStyles(button:Button):void
		{
			button.iconPosition = Button.ICON_POSITION_TOP;
			button.horizontalAlign = HorizontalAlign.CENTER;
			button.paddingLeft = 15;
			button.fontStyles = new TextFormat("_sans", 16, 0x000000, "center");
		}

		private function setRoundedButtonStyles(button:Button):void
		{
			button.defaultSkin = RoundedRect.createRoundedRect(0x1565C0);
			button.downSkin = RoundedRect.createRoundedRect(0x0D47A1);
			button.horizontalAlign = HorizontalAlign.LEFT;
			button.paddingLeft = 15;
			button.gap = 15;
			button.height = 50;
			button.minWidth = 100;
			button.fontStyles = new TextFormat("_sans", 16, 0xFFFFFF, "left")
		}

		//-------------------------
		// Header
		//-------------------------

		private function setHeaderStyles(header:Header):void
		{
			header.fontStyles = new TextFormat("_sans", 16, 0xFFFFFF, "left");
			header.gap = 5;
			header.paddingLeft = header.paddingRight = 2;
			header.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;

			var skin:Quad = new Quad(3, 50);
			skin.setVertexColor(0, 0x0277BD);
			skin.setVertexColor(1, 0x0277BD);
			skin.setVertexColor(2, 0x01579B);
			skin.setVertexColor(3, 0x01579B);
			header.backgroundSkin = skin;
		}

		//-------------------------
		// Label
		//-------------------------

		private function setLabelStyles(label:Label):void
		{
			label.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			label.fontStyles.leading = 7;
		}

		private function setBigLabelStyles(label:Label):void
		{
			label.fontStyles = new TextFormat("MyFont", 60, 0xFFFFFF);
		}

		private function setDateLabelStyles(label:Label):void
		{
			label.width = 50;
			label.height = 25;
			label.paddingTop = 3;
			label.fontStyles = new TextFormat("_sans", 14, 0xFFFFFF);
		}

		//-------------------------
		// List
		//-------------------------

		private function setListStyles(list:List):void
		{
			list.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			list.hasElasticEdges = false;
		}

		private function setItemRendererStyles(renderer:BaseDefaultItemRenderer):void
		{
			renderer.defaultSelectedSkin = new Quad(3, 3, 0xD50000);
			renderer.downSkin = new Quad(3, 3, 0xD50000);
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingLeft = 10;
			renderer.paddingRight = 10;
			renderer.paddingTop = 5;
			renderer.paddingBottom = 5;
			renderer.gap = 10;
			renderer.minHeight = 50;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.isQuickHitAreaEnabled = true;

			var blackFormat:TextFormat = new TextFormat("_sans", 14, 0x000000, "left", "center");
			blackFormat.leading = 7;

			var whiteFormat:TextFormat = new TextFormat("_sans", 14, 0xFFFFFF, "left", "center");
			whiteFormat.leading = 7;

			renderer.setFontStylesForState(ButtonState.UP, blackFormat);
			renderer.setFontStylesForState(ButtonState.UP_AND_SELECTED, whiteFormat);
			renderer.setFontStylesForState(ButtonState.DOWN, whiteFormat);
			renderer.setFontStylesForState(ButtonState.DOWN_AND_SELECTED, whiteFormat);
			renderer.setFontStylesForState(ButtonState.HOVER, blackFormat);
			renderer.setFontStylesForState(ButtonState.HOVER_AND_SELECTED, whiteFormat);

			renderer.setAccessoryLabelFontStylesForState(ButtonState.UP, blackFormat);
			renderer.setAccessoryLabelFontStylesForState(ButtonState.UP_AND_SELECTED, whiteFormat);
			renderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN, whiteFormat);
			renderer.setAccessoryLabelFontStylesForState(ButtonState.DOWN_AND_SELECTED, whiteFormat);
			renderer.setAccessoryLabelFontStylesForState(ButtonState.HOVER, blackFormat);
			renderer.setAccessoryLabelFontStylesForState(ButtonState.HOVER_AND_SELECTED, whiteFormat);
		}

		private function setDrawerItemRendererStyles(renderer:BaseDefaultItemRenderer):void
		{
			renderer.defaultSelectedSkin = new Quad(3, 3, 0x01579B);
			renderer.downSkin = new Quad(3, 3, 0x01579B);
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.verticalAlign = Button.VERTICAL_ALIGN_MIDDLE;
			renderer.paddingLeft = 10;
			renderer.paddingRight = 10;
			renderer.paddingTop = 5;
			renderer.paddingBottom = 5;
			renderer.gap = 10;
			renderer.minHeight = 45;
			renderer.accessoryGap = Number.POSITIVE_INFINITY;
			renderer.iconPosition = Button.ICON_POSITION_LEFT;
			renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
			renderer.isQuickHitAreaEnabled = true;
			renderer.fontStyles = new TextFormat("_sans", 14, 0xFFFFFF, "left");
		}

		//-------------------------
		// PanelScreen
		//-------------------------

		private function setPanelScreenStyles(screen:PanelScreen):void
		{
			screen.backgroundSkin = new Quad(3, 3, 0xD50000);
			screen.hasElasticEdges = false;
		}

		//-------------------------
		// TabBar
		//-------------------------

		private function setTabBarStyles(tabBar:TabBar):void
		{
			tabBar.customTabStyleName = "custom-tab";
		}

		private function setTabStyles(tab:ToggleButton):void
		{
			var skin1:Quad = new Quad(3, 50);
			skin1.setVertexColor(0, 0x021F34);
			skin1.setVertexColor(1, 0x021F34);
			skin1.setVertexColor(2, 0x08467C);
			skin1.setVertexColor(3, 0x08467C);

			var skin2:Quad = new Quad(3, 50);
			skin2.setVertexColor(0, 0x0277BD);
			skin2.setVertexColor(1, 0x0277BD);
			skin2.setVertexColor(2, 0x01579B);
			skin2.setVertexColor(3, 0x01579B);

			tab.defaultSkin = skin2;
			tab.downSkin = skin1;
			tab.selectedDownSkin = skin1;
			tab.defaultSelectedSkin = skin1;
		}

		//-------------------------
		// TextInput
		//---------

		private function setTextInputStyles(textinput:TextInput):void
		{
			textinput.padding = 10;
			textinput.backgroundSkin = RoundedRect.createRoundedRect(0xD50000);
			textinput.fontStyles = new TextFormat("_sans", 16, 0xFFFFFF, "left", "top");
			textinput.promptFontStyles = new TextFormat("_sans", 16, 0xCCCCCC, "left", "top");
		}

	}
}