#coding: utf-8

module WS
  class AnimationWindow < WSWindowBase
  end
end

require_relative 'nfx'
require_relative 'animation'
require_relative 'emitter'
require_relative 'parts'
require_relative 'partsimg'

module WS
  class AnimationWindow
      
    # 初期化
    def initialize
      super(0,0,Window.width,Window.height)#,"アニメーションウィンドウ")
      Window.bgcolor = COLOR[:base]
      create_controls
      c_tab.select_tab(:prt_tab)
    end
    
    # コントロールの作成
    def create_controls
      # ツールバーの作成
      add_control(WSImageButton.new(0, 0, IMG_CACHE[:icon_new], 24, 24, "ライブラリの新規作成"), :c_icon_new)
      add_control(WSImageButton.new(0, 0, IMG_CACHE[:icon_save], 24, 24, "ライブラリの保存"), :c_icon_save)
      add_control(WSImageButton.new(0, 0, IMG_CACHE[:icon_open], 24, 24, "ライブラリを開く"), :c_icon_open)
      c_icon_save.add_handler(:click){}
      c_icon_new.add_handler(:click){ create_new_library }
      # ライブラリ選択コントロール
      c_lable_lib = add_control(WSLabel.new(0, 0, 64, 20, "ライブラリ:"))
      add_control(WSPullDownList.new(0,0,164,22,[]), :c_library_select)
      # タブの作成
      create_tab
      # レイアウトの初期化
      layout(:vbox) do
        set_margin(8, 8, 8, 8)
        self.space = 8
        layout(:hbox) do
          self.space = 2
          self.resizable_height = false
          self.height = 24
          add obj.c_icon_new, false, false
          add obj.c_icon_save, false, false
          add obj.c_icon_open, false, false
          layout do 
            self.resizable_width =false
            self.width = 24
          end
          add c_lable_lib, false, false
          add obj.c_library_select, false, false
          layout
        end
        add obj.c_tab, true, true
        
      end
    end
   
    # タブの作成
    def create_tab
      pw, ph = 1416, 860
      add_control(WS::WSTab.new(0, 0, Window.width,Window.height), :c_tab)
      c_tab.create_tab(WSTabPanel_Animation.new(0, 0, pw, ph), :anm_tab , "エフェクト")
      c_tab.create_tab(WSTabPanel_Emitter.new(0, 0, pw, ph), :emt_tab , "エミッター")
      c_tab.create_tab(WSTabPanel_Parts.new(0, 0, pw, ph), :prt_tab , "パーツ")
      c_tab.create_tab(WSTabPanel_PartsImg.new(0, 0, pw, ph), :img_tab , "画像")
    end
    
    def create_new_library 
      path = Window.save_filename( [["NFXライブラリ(*.nfx)", "*.nfx"]], "新規ライブラリの作成" )
      if path
        name = File.basename(path)
        NFX.create_library(name.to_sym)
        
        
      end
    end
    
  end
end
