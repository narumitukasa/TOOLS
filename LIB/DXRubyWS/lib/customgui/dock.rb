#coding: utf-8
module WS
  ### 画像選択コントロールのクラス ###
  class WSDock < WSLightContainer

    # 初期化
    def initialize(sx, sy, width, height)
       super(sx, sy, width, height)
       @org_width = width
       @open = true
       create_controls
    end
    
    def create_controls 
      add_control(WSContainer.new(0, 0, width, height), :client)
      add_control(WSButton.new(0, 0, 16, 32, "◀"), :c_btn_switch)
      c_btn_switch.add_handler(:click){ switch }
      # オートレイアウト
      layout_open
    end

    def layout_open
      layout(:hbox) do
        self.set_margin(0, 0, 0, 0)
        add obj.client, true, true
        add obj.c_btn_switch, false, true  
      end
    end
    
    def layout_close
      layout(:hbox) do
        self.set_margin(0, 0, 0, 0)
        add obj.c_btn_switch, false, true  
      end
    end
    
    def org_width=(v)
      @org_width = v
      open_or_close
    end
        
    def switch
      @open = !@open
      open_or_close
    end
    
    def open_or_close
      @open ? open : close
    end
      
    def open 
      @open = true
      self.c_btn_switch.caption = "◀"
      self.client.show
      layout_open
      resize(@org_width, height)
    end
    
    def close
      @open = false
      self.c_btn_switch.caption = "▶"
      self.client.hide
      layout_close
      resize(16, height)
    end
    
  end 
end

