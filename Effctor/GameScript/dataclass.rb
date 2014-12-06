# coding: utf-8

module Game
 
  ### ■パーツのデータクラス■ ###
  class Parts < DataBase
  
    # 公開インスタンス変数
    attr_accessor   :frame_list
    attr_accessor   :reset_angle
    attr_accessor   :angle_from_emission
    attr_accessor   :random_angle
    attr_accessor   :random_mirror
    attr_accessor   :delay
    attr_accessor   :fix_pos
    attr_accessor   :fix_zoom
    
    # オブジェクト初期化
    def initialize
      super
      # ヘッダーの作成
      header = PartsFrame.new
      header.header
      # 第一キーフレームの作成
      frame_data = PartsFrame.new
      frame_data.name = "start"
      frame_data.id = 1
      frame_data.no = 1
      frame_data.protect = true
      @frame_list = [header, frame_data]
      # パラメータの設定
      @reset_angle = false
      @angle_from_emission = false
      @random_angle = false
      @random_mirror = false
      @delay = 2
      @fix_pos = false
      @fix_zoom = false
    end
    
    # 修復
    def repair
      super
      for frame in @frame_list
        next if frame == nil
        frame.repair
      end
    end
  end
  
  
  
  
  ### ■パーツアニメのフレームを扱うデータクラスです■ ###
  class PartsFrame < DataBase
    
    # 公開インスタンス変数
    attr_accessor   :img_list
    attr_accessor   :reset_anime
    attr_accessor   :random_anime
    attr_accessor   :change_type
    attr_accessor   :blend
    attr_accessor   :repeat
    attr_accessor   :span
    attr_accessor   :span_variance
    attr_accessor   :end_when_stop
    attr_accessor   :anime_speed
    attr_accessor   :weight
    attr_accessor   :weight_variance
    attr_accessor   :friction
    attr_accessor   :friction_variance
    attr_accessor   :repellent
    attr_accessor   :revise_x
    attr_accessor   :revise_y
    attr_accessor   :scale_x
    attr_accessor   :scale_y
    attr_accessor   :scale_variance
    attr_accessor   :alpha
    attr_accessor   :spin
    attr_accessor   :spin_speed
    attr_accessor   :spin_variance
    attr_accessor   :spin_from_move
    attr_accessor   :tone_red
    attr_accessor   :tone_green
    attr_accessor   :tone_blue
    attr_accessor   :tone_gray
    attr_accessor   :mirror
    attr_accessor   :curvature
    attr_accessor   :frame_list
   
    # オブジェクト初期化
    def initialize
      super
      @img_list = []
      @change_type = false
      @blend = 0
      @repeat = 0
      @span = 60
      @span_variance = 0
      @end_when_stop = false
      @anime_speed = 1
      @reset_anime = true
      @random_anime = false
      @weight = 0
      @weight_variance = 0
      @friction = 0
      @friction_variance = 0
      @repellent = 1
      @revise_x = 0
      @revise_y = 0
      @scale_x = 100
      @scale_y = 100
      @scale_variance = 0
      @alpha = 255
      @spin = 0
      @spin_speed = 0
      @spin_variance = 0
      @spin_from_move = false
      @tone_red = 0
      @tone_green = 0
      @tone_blue = 0
      @tone_gray = 0
      @mirror = false
      @frame_list = []
      @curvature = 0       
    end
    
  end

  
  

  ### ■パーツ画像を扱うデータクラス■ ###
  class PartsImg  < DataBase
    
    # 公開インスタンス変数
    attr_accessor   :filename
    attr_accessor   :width
    attr_accessor   :height
    attr_accessor   :column
    attr_accessor   :ox
    attr_accessor   :oy
    attr_accessor   :start_pos_x
    attr_accessor   :start_pos_y
    attr_accessor   :number_of_pattern
     
    # オブジェクト初期化
    def initialize
      super
      @filename = ""
      @width  = 64
      @height = 48
      @column = 8
      @ox = 0
      @oy = 0
      @start_pos_x = 0
      @start_pos_y = 0
      @number_of_pattern = 1
    end
    
  end
  
  
  
  
  ### ■エミッターを扱うデータクラス■ ###
  class Emitter < DataBase

    # 公開インスタンス変数
    attr_accessor   :parts_list
    attr_accessor   :rand_seed
    attr_accessor   :draw_target
    attr_accessor   :injection_number
    attr_accessor   :injection_number_variance
    attr_accessor   :interval
    attr_accessor   :max_parts   
    attr_accessor   :span
    attr_accessor   :span_variance
    attr_accessor   :velocity
    attr_accessor   :velocity_variance
    attr_accessor   :acceleration   
    attr_accessor   :acceleration_variance   
    attr_accessor   :radius_x
    attr_accessor   :radius_y
    attr_accessor   :emit_angle
    attr_accessor   :target_emit_angle
    attr_accessor   :emit_range
    attr_accessor   :target_emit_range
    attr_accessor   :width
    attr_accessor   :height

    # 初期化
    def initialize
      super
      @parts_list = []
      @rand_seed = 0
      @draw_target = false
      @span = 20
      @span_variance = 0
      @injection_number = 0
      @injection_number_variance = 0
      @interval = 1
      @max_parts = 16
      @velocity = 0
      @velocity_variance = 0
      @acceleration = 0   
      @acceleration_variance = 0
      @radius_x = 1
      @radius_y = 1
      @emit_angle = 0
      @target_emit_angle = 0
      @emit_range = 0
      @target_emit_range = 0
      @width = 128
      @height = 128
      @shader = Game::Shader.new
    end
  end
   
  ### ■アニメーションのデータクラス■ ###
  class Animation < DataBase
    
    ### アニメーションレイヤーの定義 ###
    class Layer < DataBase
      attr_accessor   :x
      attr_accessor   :y
      attr_accessor   :z
      attr_accessor   :width
      attr_accessor   :height
      attr_accessor   :max_object                # オブジェクトの最大数
      attr_accessor   :visible
      attr_accessor   :parts_list             # パーティクルリスト
      attr_accessor   :emitter_list              # エミッターリスト
      attr_accessor   :path_list                 # パスリスト
      attr_reader     :canvas
      
      def initialize(name = "レイヤー", canvas = false)
        super()
        @name = name
        @x = 0
        @y = 0
        @z = 0
        @width = 128
        @height = 128
        @max_object = 128
        @canvas = canvas
        @visible = false  
        @parts_list = []
        @emitter_list = []
        @path_list = []
      end
      
      # 修復
      def repair
        super
        # パーツセットの修復
        for data_obj in @parts_list
          next if data_obj == nil
          data_obj.repair
        end
        # エミッターセットの修復
        for data_obj in @emitter_list
          next if data_obj == nil
          data_obj.repair
        end
        # パスの修復
        for data_obj in @path_list
          next if data_obj == nil
          data_obj.repair
        end  
      end
    end
    
    ### アニメーション要素の定義 ###
    class AnimationElement < DataBase
      attr_accessor   :x
      attr_accessor   :y
      attr_accessor   :z
      attr_accessor   :angle
      attr_accessor   :type
      attr_accessor   :start_time
      attr_accessor   :visible
      
      def initialize(type = :parts)
        super
        @x = 0
        @y = 0
        @z = 0
        @angle = 0
        @type = :parts
        @start_time = 0
        @visible = false  
        @element_list = []
        @path = nil 
      end
    end
    
    # 公開インスタンス
    attr_accessor   :layer_list
    attr_accessor   :physics_list              # エフェクターリスト
    attr_accessor   :tag_list                  # 効果タグセット
    attr_accessor   :pict_obj                  # 画像オブジェのリスト
    attr_accessor   :capture_w
    attr_accessor   :capture_h
    attr_accessor   :fix_pos
    attr_accessor   :fix_zoom
    attr_accessor   :delay
    
    # 初期化
    def initialize
      super
      @layer_list = [Game::Animation::Layer.new("キャンバス", true)]
      @physics_list = []
      @tag_list = []
      @width  = 128
      @height = 128
      @capture_w = 640
      @capture_h = 480 
      @fix_pos  = false
      @fix_zoom = false
      @delay = 2
    end

    # 修復
    def repair
      super
      # レイヤーデータの修復
      for data_obj in @layer_list
        next if data_obj == nil
        data_obj.repair
      end 
      # 環境効果の修復
      for data_obj in @physics_list
        next if data_obj == nil
        data_obj.repair
      end
      # タグの修復
      for data_obj in @tag_list
        next if data_obj == nil
        data_obj.repair
      end
    end
  end
  
  ### ■シェーダーのデータクラス■ ###
  class Shader < DataBase
    
    # 公開インスタンス
    attr_accessor   :symbol
    attr_accessor   :parameters
  
    # 初期化
    def initialize
      super
      @symbol = :none
      @parameters = {}
    end
  end 
  
end