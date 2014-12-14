#coding: utf-8

module WS
  class AnimationWindow < WSWindowBase
  end
end

require_relative 'animation'
require_relative 'emitter'
require_relative 'parts'
require_relative 'partsimg'

module WS
  class AnimationWindow
      
    # 初期化
    def initialize
      DataManager.load_effect
      DataManager.repair_effect
      super(0,0,Window.width,Window.height)#,"アニメーションウィンドウ")
      Window.bgcolor = COLOR[:base]
      create_controls
      c_tab.select_tab(:anm_tab)
    end
    
    # コントロールの作成
    def create_controls
      create_tab(8, 24, @width - 16, @height - 64)
      add_control(WS::WSButton.new(width - 96, height - 24, 64, 20, "保存"), :c_btn_save)
      c_btn_save.add_handler(:click){ DataManager.save_effect }
    end
   
    # タブの作成
    def create_tab(cx, cy, cw, ch)
      pw = 1416
      ph = 860
      add_control(WS::WSTab.new(cx, cy, cw, ch), :c_tab)
      c_tab.create_tab(WSTabPanel_Animation.new(0, 0, pw, ph), :anm_tab , "エフェクト")
      c_tab.create_tab(WSTabPanel_Emitter.new(0, 0, pw, ph), :emt_tab , "エミッター")
      c_tab.create_tab(WSTabPanel_Parts.new(0, 0, pw, ph), :prt_tab , "パーツ")
      c_tab.create_tab(WSTabPanel_PartsImg.new(0, 0, pw, ph), :img_tab , "画像")
    end

  end
end
