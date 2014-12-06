module WS
  ### アニメーションウィンドウ ### 
  class AnimationWindow
    ### パーツタブパネルの定義 ###  
    class WSTabPanel_Parts < WSTabPanel
      
      # 初期化
      def initialize(cx, cy, cw, ch)
        super
        @list = $data_parts
        create_controls
      end
      
      # データベースの作成
      def create_database
        tmp = [Game::Parts.new.header, Game::Parts.new]
        DataManager.save_data(tmp,"./Data/Parts.dat")
      end
      
      # コントロールの作成
      def create_controls
        add_control(WSPanel_Parts.new(220, 8, 240, 204), :c_panel_parts)
        add_control(WSPanel_PartsFrame.new(468, 8, 240, @height - 16), :c_panel_frame)
        c_panel_parts.add_handler(:change){ start_preview }
        c_panel_frame.add_handler(:change){ start_preview }
        # リストの作成
        add_control(WSSortableList.new(12, 8, 200, @height - 16, @list, "パーツリスト"), :c_list)
        add_control(WSSortableList.new(220, 22 * 8 + 44, 240, @height - 228, [], "キーフレームリスト"), :c_list_frame)
        c_list.add_handler(:select, method(:select_list))
        c_list_frame.add_handler(:select, method(:select_frame))
        # パーツプレビュー領域の作成
        add_control(WS::WSPreviewArea.new(716, 42, @width - 730 , @height - 48) ,:c_preview)
        add_control(WS::WSButton.new(756, 16, 128, 20, "プレビュー再生"), :c_btn_preview)
        c_btn_preview.add_handler(:click){ start_preview }
        # プレビュー用スプライトの作成
        @parts_sprite = Game_Parts.new(Game::Parts.new, 0)
        @parts_sprite.set_pos(c_preview.client.width / 2, c_preview.client.height / 2)
        @parts_sprite.edit
        c_preview.set_sprite(@parts_sprite)        
        # 初期項目の選択
        select_list(c_list, 0)
        # オートレイアウト
        layout(:hbox) do
          self.space = 8
          set_margin(8,8,8,8)
          add obj.c_list, false, true
          layout(:vbox) do
            self.space = 8
            self.width = 240
            self.resizable_width = false
            add obj.c_panel_parts, false, false
            add obj.c_list_frame, false, true
          
          end
          add obj.c_panel_frame, false, true
          add obj.c_preview, true, true
        end
      end 

      ### リスト操作 ###
      # リスト項目の選択
      def select_list(obj, cursor)
        c_panel_parts.set_edit_data(obj.current_item)
        c_panel_frame.set_frame_list(obj.current_item.frame_list)
        c_list_frame.set_items(obj.current_item.frame_list)
        select_frame(c_list_frame, 0)
        @parts_sprite.set_new_parts(obj.current_item)
      end
      
      # フレームの選択
      def select_frame(obj, cursor)
        c_panel_frame.set_edit_data(obj.current_item)
      end      

      ### プレビュー ###
      def start_preview
        @parts_sprite.set_up
      end      
      
      ### 更新 ###
      def update
        @parts_sprite.update
        super
      end
      
      ### 描画 ###
      def draw 
        draw_preview
        super
      end
      
      # プレビュー領域のグリッドの描画
      def draw_preview
        preview  = c_preview
        w = c_preview.client.width / 2
        h = c_preview.client.height / 2
          
        c_preview.client.image.draw_line(w - 4, h ,w + 4, h, C_MAGENTA, self.z + 1)
        c_preview.client.image.draw_line(w, h - 4 , w, h + 4, C_MAGENTA, self.z + 1)
      end      
        
      ### ■パーツパネルの定義■ ###
      class WSPanel_Parts < WSPanel
        attr_reader :edit_data        
        
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "パーツ設定")
          @edit_data = Game::Parts.new
          create_controls
        end
      
        def create_controls
          label_name = add_control(WS::WSLabel.new(0, 0, 128, 22, "名前"))
          add_control(WS::WSTextBox.new(0, 0, 128, 22), :c_name)
          c_name.add_handler(:change){ edit_data.name = c_name.text }

          label_delay = add_control(WS::WSLabel.new(0, 0, 128, 22, "ディレイ"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_delay)
          c_delay.add_handler(:change){ edit_data.delay = c_delay.value }
          c_delay.limit(1,60)
           
          add_control(WS::WSCheckBox.new(0, 0, 128,  "ランダムに反転"), :c_random_mirror)
          c_random_mirror.add_handler(:change){ edit_data.random_mirror = c_random_mirror.checked }
      
          add_control(WS::WSCheckBox.new(0, 0, 128,  "角度をランダムに"), :c_random_angle)
          c_random_angle.add_handler(:change){ edit_data.random_angle = c_random_angle.checked }
      
          add_control(WS::WSCheckBox.new(0, 0, 128,  "角度を射出方向に"), :c_angle_from_emission)
          c_angle_from_emission.add_handler(:change){ edit_data.angle_from_emission = c_angle_from_emission.checked }
          # オートレイアウト
          client.layout(:vbox) do
            self.space = 2
            add label_name, true, false
            add obj.c_name, true, false
            layout do
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_delay, false, false
              add obj.c_delay, true,  false
              self.resizable_height = false
              self.height = 22
            end
            layout do
              self.resizable_height = false
              self.height = 22
            end
            add obj.c_random_mirror, true, false
            add obj.c_random_angle, true, false
            add obj.c_angle_from_emission, true, false
            layout
          end
        
        end
        
        # 編集データのセット
        def set_edit_data(data)
          @edit_data = data
          set_parameters
        end
        
        
        # パーツ数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.text = @edit_data.name
          c_delay.value = @edit_data.delay
          c_random_mirror.checked = @edit_data.random_mirror
          c_random_angle.checked = @edit_data.random_angle
          c_angle_from_emission.checked = @edit_data.angle_from_emission
        end
      end
      
      ### ■パーツフレームパネルの定義■ ###
      class WSPanel_PartsFrame < WSPanel
        
        # 公開インスタンス
        attr_reader   :edit_data       
       
        # 初期化    
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "フレーム設定")
          @edit_data = Game::PartsFrame.new
          @frame_list = []
          create_controls
        end
  
        # コントロールの作成
        def create_controls
          label_name = add_control(WS::WSLabel.new(0, 0, 128, 22, "名前"))
          add_control(WS::WSTextBox.new(0, 0, 128, 22), :c_name)
          c_name.add_handler(:change){ edit_data.name = c_name.value }
          
          label_img_list = add_control(WS::WSLabel.new(0, 0, 128, 22, "画像セット"))
          add_control(WSItemSelector.new(0, 0, 128, 22, $data_parts_image, "パーツ画像を選択", true), :c_img_list)
          c_img_list.add_handler(:change){ edit_data.img_list = c_img_list.value; signal(:change) }
      
          add_control(WS::WSCheckBox.new(0, 0, 128,  "アニメをリセット"), :c_reset_anime)
          c_reset_anime.add_handler(:change){ edit_data.reset_anime = c_reset_anime.checked; signal(:change) }
      
          add_control(WS::WSCheckBox.new(0, 0, 128,  "画像の張替え"), :c_change_type)
          c_change_type.add_handler(:change){ edit_data.change_type = c_change_type.checked; signal(:change) }
      
          label_blend = add_control(WS::WSLabel.new(0, 0, 128, 22, "ブレンドタイプ"))
          add_control(WS::WSPullDownList.new(0, 0, 128, 22, ["通常","加算1","加算2","減算1"]), :c_blend)
          c_blend.add_handler(:change){ case c_blend.index
                                         when 0 
                                           edit_data.blend = :alpha
                                         when 1
                                           edit_data.blend = :add
                                         when 2
                                           edit_data.blend = :add2
                                         when 3
                                           edit_data.blend = :sub
                                         end
                                         ; signal(:change)}
                
          label_span = add_control(WS::WSLabel.new(0, 0, 128, 22, "持続時間"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_span)
          c_span.add_handler(:change){ edit_data.span = c_span.value; signal(:change) }
          
          label_span_variance = add_control(WS::WSLabel.new(0, 0, 128, 22, "持続時間分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_span_variance)
          c_span_variance.add_handler(:change){ edit_data.span_variance = c_span_variance.value; signal(:change) }
          c_span_variance.limit(0, 100)
          
          label_repeat = add_control(WS::WSLabel.new(0, 0, 128, 22, "繰り返し回数"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_repeat)
          c_repeat.add_handler(:change){ edit_data.repeat = c_repeat.value; signal(:change) }
      
          add_control(WS::WSCheckBox.new(0, 0, 128,  "速度0で消滅する"), :c_end_when_stop)  
          c_end_when_stop.add_handler(:change){ edit_data.end_when_stop = c_end_when_stop.value; signal(:change) }
      
              
=begin
          add_control(WS::WSLabel.new(0, 0, 128, 22, "抵抗値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_friction)
          c_friction.add_handler(:change){ edit_data.friction = c_friction.value }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "抵抗値分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_friction_variance)
          c_friction_variance.add_handler(:change){ edit_data.friction_variance = c_friction_variance.value }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "重さ"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_weight)
          c_weight.add_handler(:change){ edit_data.weight = c_weight.value }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "重さ分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_weight_variance)
          c_weight_variance.add_handler(:change){ edit_data.weight_variance = c_weight_variance.value }
=end      
                
          add_control(WS::WSLabel.new(0, 0, 128, 22, "透明度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_alpha)
          c_alpha.add_handler(:change){ edit_data.alpha = c_alpha.value; signal(:change) }
          c_alpha.limit(0, 255)
                
          add_control(WS::WSLabel.new(0, 0, 128, 22, "補正座標X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_revise_x)
          c_revise_x.add_handler(:change){ edit_data.revise_x = c_revise_x.value; signal(:change) }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "補正座標Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_revise_y)
          c_revise_y.add_handler(:change){ edit_data.revise_y = c_revise_y.value; signal(:change) }
            
          add_control(WS::WSLabel.new(0, 0, 128, 22, "拡大率X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_scale_x)
          c_scale_x.add_handler(:change){ edit_data.scale_x = c_scale_x.value; signal(:change) }
          c_scale_x.limit(-800, 800)
            
          add_control(WS::WSLabel.new(0, 0, 128, 22, "拡大率Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_scale_y)
          c_scale_y.add_handler(:change){ edit_data.scale_y = c_scale_y.value; signal(:change) }
          c_scale_y.limit(-800, 800)  
            
          add_control(WS::WSLabel.new(0, 0, 128, 22, "回転"))
          add_control(WS::WSPullDownList.new(0, 0, 128, 22, 
            ["回転なし","時計回り","半時計回り","ランダム","移動方向","射出方向"]), :c_spin)
          c_spin.add_handler(:change){ edit_data.spin = c_spin.index; signal(:change) }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "回転速度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_spin_speed)
          c_spin_speed.add_handler(:change){ edit_data.spin_speed = c_spin_speed.value; signal(:change) }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "回転速度分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_spin_variance)
          c_spin_variance.add_handler(:change){ edit_data.spin_variance = c_spin_variance.value; signal(:change) }
          c_spin_variance.limit(0, 100)
            
          add_control(WS::WSCheckBox.new(0, 0, 128,  "移動速度を参照"), :c_spin_from_move)  
          c_spin_from_move.add_handler(:change){ edit_data.spin_from_move = c_spin_from_move.value; signal(:change) }
          
          add_control(WS::WSCheckBox.new(0, 0, 128,  "画像反転"), :c_mirror)  
          c_mirror.add_handler(:change){ edit_data.mirror = c_mirror.value; signal(:change) }
          
                
          add_control(WS::WSLabel.new(0, 0, 128, 22, "色調R値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_tone_red)
          c_tone_red.limit(-255, 255)
          c_tone_red.add_handler(:change){ edit_data.tone_red = c_tone_red.value; signal(:change) }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "色調G値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_tone_green)
          c_tone_green.limit(-255, 255)
          c_tone_green.add_handler(:change){ edit_data.tone_green = c_tone_green.value; signal(:change) }
      
          add_control(WS::WSLabel.new(0, 0, 128, 22, "色調B値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_tone_blue)    
          c_tone_blue.limit(-255, 255)
          c_tone_blue.add_handler(:change){ edit_data.tone_blue = c_tone_blue.value; signal(:change) }
          
          add_control(WS::WSLabel.new(0, 0, 128, 22, "色調A値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_tone_gray)    
          c_tone_gray.limit(-255, 255)
          c_tone_gray.add_handler(:change){ edit_data.tone_gray = c_tone_gray.value; signal(:change) }
        
          add_control(WS::WSLabel.new(0, 0, 128, 22, "次のキーフレーム"))
          add_control(WSItemSelector.new(0, 0, 128, 22, @frame_list, "次のキーフレームを選択", true), :c_frame_list)
          c_frame_list.add_handler(:change){ edit_data.frame_list = c_frame_list.value; signal(:change) }
      
          # オートレイアウト
          client.layout(:vbox) do
            self.space = 2
            add label_name, true, false
            add obj.c_name, true, false
            layout do
              self.height = 22
              self.resizable_height = false
            end
            add label_img_list, true, false
            add obj.c_img_list, true, false
            add obj.c_reset_anime, true, false
            add obj.c_change_type, true, false
            layout do
              self.height = 22
              self.resizable_height = false
            end
            add label_blend, true, false
            add obj.c_blend, true, false
            layout(:hbox) do
               self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span_variance, false, false
              add obj.c_span_variance, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_repeat, false, false
              add obj.c_repeat, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              add label_span, false, false
              add obj.c_span, true, false 
              self.height = 22
              self.resizable_height = false
            end
            layout
          end
            
        end
       
        # 編集データのセット
        def set_edit_data(data)
          @edit_data  = data
          set_parameters
        end
 
        # 編集データのセット
        def set_frame_list(frame_list)
          c_frame_list.set_items(frame_list)
        end
                
        # パーツフレーム数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.value = edit_data.name
          c_img_list.value = edit_data.img_list
          c_reset_anime.value = edit_data.reset_anime
          c_change_type.value = edit_data.change_type
          c_blend.index = edit_data.blend == :add ? 1 : edit_data.blend == :add2 ? 2 : edit_data.blend == :sub ? 3 : 0
          c_span.value = edit_data.span
          c_span_variance.value = edit_data.span_variance
          c_repeat.value = edit_data.repeat
          c_end_when_stop.value = edit_data.end_when_stop
=begin
          c_friction.value = edit_data.friction
          c_friction_variance.value = edit_data.friction_variance
          c_weight.value.value = edit_data.weight
          c_weight_variance.value = edit_data.weight_variance
=end
          c_alpha.value = edit_data.alpha
          c_revise_x.value = edit_data.revise_x
          c_revise_y.value = edit_data.revise_y
          c_scale_x.value = edit_data.scale_x
          c_scale_y.value = edit_data.scale_y
          c_spin.index = edit_data.spin
          c_spin_speed.value = edit_data.spin_speed
          c_spin_variance.value = edit_data.spin_variance
          c_spin_from_move.value = edit_data.spin_from_move
          c_mirror.value = edit_data.mirror
          c_tone_red.value = edit_data.tone_red
          c_tone_green.value = edit_data.tone_green
          c_tone_blue.value = edit_data.tone_blue
          c_tone_gray.value = edit_data.tone_gray
          c_frame_list.value = edit_data.frame_list
        end
      end
    end
  end
  
end
