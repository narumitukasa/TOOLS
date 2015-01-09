#coding: utf-8

module WS
  ### アニメーションウィンドウ ### 
  class AnimationWindow
    ### エミッタータブパネルの定義 ###  
    class WSTabPanel_Emitter < WSTabPanel
      
      # 初期化
      def initialize(cx, cy, cw, ch)
        super
        @list = []
        create_controls
      end
      
      # コントロールの作成
      def create_controls
        add_control(WSPanel_Emitter.new(220, 8, 240, 128), :c_panel_emitter)
        c_panel_emitter.add_handler(:change){ start_preview }
        # リストの作成
        add_control(WSSortableList.new(12, 8, 200, 128, @list, "エミッターリスト"), :c_list)
        c_list.add_handler(:select, method(:select_list))
        # エミッタープレビュー領域の作成
        add_control(WS::WSPreviewArea.new(468, 42, 128 , 128) ,:c_preview)
        add_control(WS::WSButton.new(468, 16, 128, 20, "プレビュー再生"), :c_btn_preview)
        c_btn_preview.add_handler(:click){ start_preview }
        # コメント領域の作成
        add_control(WS::WSComment.new(@width - 204, 12, 196, 24, "", true), :c_emitter_info)
        # オートレイアウト
        layout(:hbox) do 
          self.space = 8
          self.set_margin(8,8,8,8)
          add obj.c_list, false, true
          add obj.c_panel_emitter, false, true
          layout(:vbox) do
            self.space = 8
            layout(:hbox) do
              add obj.c_btn_preview
              layout
              add obj.c_emitter_info, false, false
              self.height = 22
              self.resizable_height = false
            end
            add obj.c_preview, true, true
          end      
        end  
        # プレビュー用スプライトの作成
        @emitter = Game_Emitter.new(NFX::Emitter.new(:none))
        @emitter.set_pos(c_preview.client.width / 2, c_preview.client.height / 2)
        c_preview.set_sprite(@emitter)
        # 初期項目の選択
        select_list(c_list, 0)     
      end 

      ### リスト操作 ###
      # ライブラリの変更
      def change_library
        @list = NFX.current_library.emitter
      end
      
      # リスト項目の選択
      def select_list(obj, cursor)
        if obj.current_item
          # コントロールの有効化
          c_panel_emitter.enabled = true
          # 項目のセット
          c_panel_emitter.set_edit_data(obj.current_item)
          @emitter.set_new_emitter(obj.current_item)
        else
          # コントロールの無効化
          c_panel_emitter.enabled = false
          # エミッターの停止
          @emitter.finish
        end
      end

      ### プレビュー ###
      def start_preview
        @emitter.set_up
      end      
      
      ### 更新 ###
      def update
        @emitter.update if visible
        c_emitter_info.caption = @emitter.emiter_info
        super
      end
      
      ### 描画 ###
      def render
        #render_preview
        super
      end
      
      # プレビュー領域のグリッドの描画
      def render_preview
        #em = c_list.current_item
        
        #pi = c_preview.client.image
        #w  = c_preview.client.width / 2
        #h  = c_preview.client.height / 2
        #ew = em.width
        #eh = em.height  
        
        #pi.draw_line(w - 4, h ,w + 4, h, C_MAGENTA, self.z + 1)
        #pi.draw_line(w, h - 4 , w, h + 4, C_MAGENTA, self.z + 1)
        #pi.draw_line(w - ew / 2, h - eh / 2, w - ew / 2, h + eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w + ew / 2, h - eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w - ew / 2, h - eh / 2, w + ew / 2, h - eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w - ew / 2, h + eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
      end      
        
      ### ■エミッターパネルの定義■ ###
      class WSPanel_Emitter < WSPanel
        
        # 公開インスタンス
        attr_reader   :edit_data       
       
        # 初期化    
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "エミッター設定")
          @edit_data = NFX::Emitter.new(:none)
          create_controls
        end
  
        # コントロールの作成
        def create_controls
          label_name = add_control(WS::WSLabel.new(0, 0, 128, 22, "名前"))
          add_control(WS::WSTextBox.new(0, 0, 128, 22), :c_name)
          c_name.add_handler(:change){ edit_data.name = c_name.value }
          
          label_parts_list = add_control(WS::WSLabel.new(0, 0, 128, 22, "パーツセット"))
          add_control(WSItemSelector.new(0, 0, 128, 22, $data_parts, "パーツを選択", true), :c_parts_list)
          c_parts_list.add_handler(:change){ edit_data.parts_list = c_parts_list.value; signal(:change) }

          label_rand_seed = add_control(WS::WSLabel.new(0, 0, 128, 22, "乱数種"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_rand_seed)
          c_rand_seed.add_handler(:change){|obj, v| edit_data.rand_seed = v; signal(:change) }
          c_rand_seed.limit(-1, 10230)
            
          label_span = add_control(WS::WSLabel.new(0, 0, 128, 22, "持続時間"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_span)
          c_span.add_handler(:change){ edit_data.span = c_span.value; signal(:change) }
          c_span.limit(1, 10000)
            
          label_span_variance = add_control(WS::WSLabel.new(0, 0, 128, 22, "持続時間分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_span_variance)
          c_span_variance.add_handler(:change){ edit_data.span_variance = c_span_variance.value; signal(:change) }
          c_span_variance.limit(0, 100)
        
          label_injection_number = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出数"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_injection_number)
          c_injection_number.add_handler(:change){ edit_data.injection_number = c_injection_number.value; signal(:change) }
          c_injection_number.limit(1, 128)
            
          label_injection_number_variance = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出数分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_injection_number_variance)
          c_injection_number_variance.add_handler(:change){ edit_data.injection_number_variance = c_injection_number_variance.value; signal(:change) }
          c_injection_number_variance.limit(0, 200)
              
          label_interval = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出間隔"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_interval)
          c_interval.add_handler(:change){ edit_data.interval = c_interval.value }
          c_interval.limit(1, 10000)
      
          label_max_parts = add_control(WS::WSLabel.new(0, 0, 128, 22, "最大値"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_max_parts)
          c_max_parts.add_handler(:change){ edit_data.max_parts = c_max_parts.value }
      
            
          label_radius_x = add_control(WS::WSLabel.new(0, 0, 128, 22, "半径X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_radius_x)
          c_radius_x.add_handler(:change){ edit_data.radius_x = c_radius_x.value }
      
          label_radius_y = add_control(WS::WSLabel.new(0, 0, 128, 22, "半径Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_radius_y)
          c_radius_y.add_handler(:change){ edit_data.radius_y = c_radius_y.value }
      
                
          label_velocity = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出速度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_velocity)
          c_velocity.add_handler(:change){ edit_data.velocity = c_velocity.value; signal(:change) }
          c_velocity.limit(0, 10000)
                

          label_velocity_variance = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出速度分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_velocity_variance)
          c_velocity_variance.add_handler(:change){ edit_data.velocity_variance = c_velocity_variance.value; signal(:change) }
          c_velocity_variance.limit(0, 200)
            
          label_acceleration = add_control(WS::WSLabel.new(0, 0, 128, 22, "加速度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_acceleration)
          c_acceleration.add_handler(:change){ edit_data.acceleration = c_acceleration.value; signal(:change) }
          c_acceleration.limit(-1023, 1024)
            
          label_acceleration_variance = add_control(WS::WSLabel.new(0, 0, 128, 22, "加速度分散度"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_acceleration_variance)
          c_acceleration_variance.add_handler(:change){ edit_data.acceleration_variance = c_acceleration_variance.value; signal(:change) }
          c_acceleration_variance.limit(0, 200)
            
          label_emit_angle = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出方向"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_emit_angle)
          c_emit_angle.add_handler(:change){ edit_data.emit_angle = c_emit_angle.value; signal(:change) }
          c_emit_angle.limit(0, 36000)  
            
          label_target_emit_angle = add_control(WS::WSLabel.new(0, 0, 128, 22, "目標射出方向"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_target_emit_angle)
          c_target_emit_angle.add_handler(:change){ edit_data.target_emit_angle = c_target_emit_angle.value; signal(:change) }
          c_target_emit_angle.limit(0, 36000)  
                
          label_emit_range = add_control(WS::WSLabel.new(0, 0, 128, 22, "射出範囲"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_emit_range)
          c_emit_range.add_handler(:change){ edit_data.emit_range = c_emit_range.value; signal(:change) }
          c_emit_range.limit(0, 360)
            
          label_target_emit_range = add_control(WS::WSLabel.new(0, 0, 128, 22, "目標射出範囲"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_target_emit_range)
          c_target_emit_range.add_handler(:change){ edit_data.target_emit_range = c_target_emit_range.value; signal(:change) }
          c_target_emit_range.limit(0, 360)
     
               
          label_width = add_control(WS::WSLabel.new(0, 0, 128, 22, "エミッター幅"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_width)
          c_width.add_handler(:change){ edit_data.width = c_width.value; signal(:change) }
          c_width.limit(1, 1920)
            
          label_height = add_control(WS::WSLabel.new(0, 0, 128, 22, "エミッター高さ"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, 22), :c_height)
          c_height.add_handler(:change){ edit_data.height = c_height.value; signal(:change) }
          c_height.limit(1, 1080)
     
          # オートレイアウト
          client.layout(:vbox) do
            self.space = 2
            add label_name, true, false
            add obj.c_name, true, false
            add label_parts_list, true, false
            add obj.c_parts_list, true, false
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false              
              add label_rand_seed, false, false
              add obj.c_rand_seed, true, false
            end
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false              
              add label_span, false, false
              add obj.c_span, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false              
              add label_span_variance, false, false
              add obj.c_span_variance, true, false
            end
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false              
              add label_injection_number, false, false
              add obj.c_injection_number, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false    
              add label_injection_number_variance, false, false
              add obj.c_injection_number_variance, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false  
              add label_interval,false, false
              add obj.c_interval, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_max_parts, false, false
              add obj.c_max_parts, true, false
            end
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false 
              add label_radius_x, false, false
              add obj.c_radius_x, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_radius_y, false, false
              add obj.c_radius_y, true, false
            end
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false       
              add label_velocity, false, false
              add obj.c_velocity, true, false
            end      
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_velocity_variance, false, false
              add obj.c_velocity_variance, true, false
            end  
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_acceleration, false, false
              add obj.c_acceleration, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false  
              add label_acceleration_variance, false, false
              add obj.c_acceleration_variance, true, false
            end      
            layout do
              self.height = 22
              self.resizable_height = false
            end      
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false  
              add label_emit_angle, false, false
              add obj.c_emit_angle, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false  
              add label_target_emit_angle, false, false
              add obj.c_target_emit_angle, true, false
            end      
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_emit_range, false, false
              add obj.c_emit_range, true, false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false  
              add label_target_emit_range, false, false
              add obj.c_target_emit_range, true, false
            end  
            layout do
              self.height = 22
              self.resizable_height = false
            end
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false     
              add label_width, false, false
              add obj.c_width, true, false
            end 
            layout(:hbox) do
              self.height = 22
              self.resizable_height = false
              add label_height, false, false
              add obj.c_height, true, false
            end
            layout
          end
          
        end
       
        # 編集データのセット
        def set_edit_data(data)
          @edit_data  = data
          set_parameters
        end
                 
        # エミッター数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.value = edit_data.name
          c_parts_list.value = edit_data.parts_list
          c_rand_seed.value = edit_data.rand_seed
          c_span.value = edit_data.span
          c_span_variance.value = edit_data.span_variance
          c_injection_number.value = edit_data.injection_number
          c_injection_number_variance.value = edit_data.injection_number_variance
          c_max_parts.value = edit_data.max_parts
          c_interval.value = edit_data.interval
          c_radius_x.value = edit_data.radius_x
          c_radius_y.value = edit_data.radius_y
          c_velocity.value = edit_data.velocity
          c_velocity_variance.value = edit_data.velocity_variance
          c_acceleration.value = edit_data.acceleration
          c_acceleration_variance.value = edit_data.acceleration_variance
          c_emit_angle.value = edit_data.emit_angle
          c_target_emit_angle.value = edit_data.target_emit_angle
          c_emit_range.value = edit_data.emit_range
          c_target_emit_range.value = edit_data.target_emit_range
          c_width.value = edit_data.width
          c_height.value = edit_data.height
        end
      end
    end
  end
  
end
