#coding: utf-8

module WS
  ### アニメーションウィンドウ ### 
  class AnimationWindow
    ### アニメーションタブパネルの定義 ###  
    class WSTabPanel_Animation < WSTabPanel
      
      # 初期化
      def initialize(cx, cy, cw, ch)
        super
        @list = []
        create_controls
      end
      
      # コントロールの作成
      def create_controls
        # ドックの作成
        dock = add_control(WSDock.new(0, 0, 460, 240), :c_dock)
        # パネルの作成
        add_control(WSPanel_Animation.new(220, 8, 240, 240), :c_panel_animation)
        c_panel_animation.add_handler(:change){ start_preview }
        add_control(WSPanel_AnimationLayer.new(220, 8, 120, @height - 16), :c_panel_animation_layer)
        c_panel_animation_layer.add_handler(:change){ start_preview }
        ### ドック内容の作成 ###
        # リストの作成
        dock.add_handler(:resize){ @layout.auto_layout }
        dock.client.add_control(WSSortableList.new(0, 0, 200, @height - 16, @list, "アニメーションリスト"), :c_list)
        dock.client.c_list.add_handler(:select, method(:select_list))
        dock.client.add_control(WSSortableList.new(0, 0, 200, @height - 16, [], "レイヤーリスト"), :c_layer_list)
        dock.client.c_layer_list.add_handler(:select, method(:select_layer_list))
        # ドックのオートレイアウト
        dock.client.layout(:hbox) do
          set_margin(0,0,0,0)
          add obj.c_list
          add obj.c_layer_list  
        end
        
        # アニメーションプレビュー領域の作成
        add_control(WS::WSPreviewArea.new(0, 0, 128, 128) ,:c_preview)
        #add_control(WS::WSButton.new(508, 16, 128, 20, "プレビュー再生"), :c_btn_preview)
        #c_btn_preview.add_handler(:click){ start_preview }
        # コメント領域の作成
        #add_control(WS::WSComment.new(@width - 204, 12, 196, 24, "", true), :c_animation_info)
        # プレビュー用スプライトの作成
        #@animation = Game_Animation.new(Game::Animation.new)
        #@animation.set_pos(c_preview.client.width / 2, c_preview.client.height / 2)
        #c_preview.set_sprite(@animation)
        # オートレイアウト
        layout(:hbox) do
          self.set_margin(8,8,8,8)
          self.space = 8
          add obj.c_dock, false, true
          layout do
            self.resizable_width = false
            self.width = 8
          end
            
          layout(:vbox) do 
            set_margin(0, 0, 0, 0)
            self.resizable_width = false
            self.width = 200
            add obj.c_panel_animation, true, false
            layout do
              self.resizable_height = false
              self.height = 8
            end
            add obj.c_panel_animation_layer, true, true
          end
          add obj.c_preview, true, true
        end
        # 初期項目の選択
        select_list(c_dock.client.c_list, 0)
        select_layer_list(c_dock.client.c_layer_list, 0)
      end 

      ### リスト操作 ###
      # ライブラリの変更
      def change_library
        @list = NFX.current_library.animation
      end
      
      # リスト項目の選択
      def select_list(obj, cursor)
        if obj.current_item
          # コントロールの有効化
          c_panel_animation.enabled = true
          # 項目のセット
          c_panel_animation.set_edit_data(obj.current_item)
          c_dock.client.c_layer_list. set_items(obj.current_item.layer_list)
        else
          # コントロールの無効化
          c_panel_animation.enabled = false
          c_panel_animation_layer.enabled = false
        end
        #@animation.set_new_animation(obj.current_item)
      end
      
      # レイヤーリスト項目の選択
      def select_layer_list(obj, cursor)
        if obj.current_item
          c_panel_animation_layer.enabled = true
          c_panel_animation_layer.set_edit_data(obj.current_item)
        else
          c_panel_animation_layer.enabled = false
        end
      end
      
      ### プレビュー ###
      def start_preview
        #@animation.set_up
      end      
      
      ### 更新 ###
      def update
        #@animation.update
        super
      end
      
      ### 描画 ###
      def draw 
        #draw_preview
        super
      end
      
      # プレビュー領域のグリッドの描画
      def draw_preview
        em = c_list.current_item
        
        pi = c_preview.client.image
        w  = c_preview.client.width / 2
        h  = c_preview.client.height / 2
        ew = em.width
        eh = em.height  
        
        pi.draw_line(w - 4, h ,w + 4, h, C_MAGENTA, self.z + 1)
        pi.draw_line(w, h - 4 , w, h + 4, C_MAGENTA, self.z + 1)
        pi.draw_line(w - ew / 2, h - eh / 2, w - ew / 2, h + eh / 2,C_RED, self.z + 1)
        pi.draw_line(w + ew / 2, h - eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
        pi.draw_line(w - ew / 2, h - eh / 2, w + ew / 2, h - eh / 2,C_RED, self.z + 1)
        pi.draw_line(w - ew / 2, h + eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
        c_animation_info.caption = @animation.emiter_info
        @animation.draw
      end      
        
      
      
      
      ### アニメーションパネルの定義 ###
      class WSPanel_Animation < WSPanel
        
        # 公開インスタンス
        attr_reader   :edit_data       
       
        # 初期化    
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "アニメーション設定")
          @edit_data = NFX::Animation.new(:none)
          create_controls
        end
  
        # コントロールの作成
        def create_controls
          lw = 96
          ch = 20
          
          label_name = add_control(WS::WSLabel.new(0, 0, lw, ch, "名前"))
          add_control(WS::WSTextBox.new(0,0, 32, ch), :c_name)
          c_name.add_handler(:change){ |obj, v| edit_data.name = v}
          
          client.layout(:vbox) do
            add label_name, true, false
            add obj.c_name, true,  false
            layout do
              self.resizable_height = false
              self.height = 22
            end
            layout
          end
          
        end
       
        # 編集データのセット
        def set_edit_data(data)
          @edit_data  = data
          set_parameters
        end
                 
        # アニメーション数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.value = edit_data.name
        end
      end
      
      
      
      
      ### レイヤーパネルの定義 ###
      class WSPanel_AnimationLayer < WSPanel
        
        # 公開インスタンス
        attr_reader   :edit_data       
       
        # 初期化    
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "レイヤー設定")
          @edit_data = NFX::Animation.new(:none)
          create_controls
        end
  
        # コントロールの作成
        def create_controls
          lw = 96
          ch = 20
          
          label_x = add_control(WS::WSLabel.new(0, 0, lw, ch, "X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_x)
          c_x.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}

          label_y = add_control(WS::WSLabel.new(0, 0, lw, ch, "Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_y)
          c_y.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}

          label_width = add_control(WS::WSLabel.new(0, 0, lw, ch, "幅"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_width)
          c_width.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}

          label_height = add_control(WS::WSLabel.new(0, 0, lw, ch, "高さ"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_height)
          c_height.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}
            
          label_z = add_control(WS::WSLabel.new(0, 0, lw, ch, "Z"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_z)
          c_z.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}

          label_max_object = add_control(WS::WSLabel.new(0, 0, lw, ch, "最大値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 32, ch), :c_max_object)
          c_max_object.add_handler(:change){|obj, v| edit_data.max_object = v ;signal(:change)}
          
          add_control(WS::WSButton.new(0, 0, 32, ch, "パーツ登録"), :c_btn_entry_parts)
          c_btn_entry_parts.add_handler(:click){ entry_parts }
          
          add_control(WS::WSButton.new(0, 0, 32, ch, "エミッター登録"), :c_btn_entry_emitter)
          c_btn_entry_parts.add_handler(:click){ entry_emitter }
         
          # オートレイアウト
          client.layout(:vbox) do
            self.space = 2
            layout(:hbox) do
              add label_x, false, false
              add obj.c_x, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_y, false, false
              add obj.c_y, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_width, false, false
              add obj.c_width, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_height, false, false
              add obj.c_height, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_z, false, false
              add obj.c_z, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_max_object, false, false
              add obj.c_max_object, true,  false
              self.resizable_height = false
              self.height = 22
            end

            add obj.c_btn_entry_parts, true, false
            add obj.c_btn_entry_emitter, true, false
            layout
          end  
          
        end
       
        # 編集データのセット
        def set_edit_data(data)
          @edit_data  = data
          set_parameters
        end
                 
        # アニメーション数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_x.value = @edit_data.x
          c_y.value = @edit_data.y
          c_z.value = @edit_data.z
          c_width.value = @edit_data.width
          c_height.value = @edit_data.height
          c_max_object.value = @edit_data.max_object
        end
      end
      
      
      
      
      ### ■要素選択ウィンドウの定義■ ###
      class WSElementSelectWindow < WSWindow
        
      
      end
      
      
      
      
    end
  end
  
end
