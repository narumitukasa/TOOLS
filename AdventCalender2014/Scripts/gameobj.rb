### ■粒子エフェクトを扱うクラス■ ###
class Game_Parts < Sprite_Base
  
  # Mix_In
  include RandTable
  include Coordinate
  include Easing
  
  # 定数
  LIMIT_WIDTH = 640 * 4
  LIMIT_HEIGHT = 480 * 4

  # 公開インスタンス変数
  attr_accessor :spin_speed
  attr_accessor :revise_x
  attr_accessor :revise_y
  attr_accessor :tone_red
  attr_accessor :tone_green
  attr_accessor :tone_blue
  attr_accessor :tone_gray
  attr_writer   :physics
  attr_writer   :path
  attr_writer   :with_emitter
  attr_reader   :finished

  # オブジェクト初期化
  def initialize(parts_data, rand_index = 0, target = nil)
    super(target)
    @edit = false
    @parts = parts_data
    @camera = nil
    @target = nil
    @next_frame   = false
    @with_emitter = false
    @finished     = true 
    # 位置・速度・角度
    @real_x = 0                               # 実座標 X
    @real_y = 0                               # 実座標 Y
    @last_real_x = 0                          # 1フレーム前の座標 X
    @last_real_y = 0                          # 1フレーム前の座標 Y
    @vector_x = 0                             # ベクトル X
    @vector_y = 0                             # ベクトル Y
    @speed = 0                                # 速度
    @max_speed = 0                            # 速度
    @acceleration = 0                         # 加速度   
    @real_angle = 0                           # 画像角度
    # 基本項目
    @weight = 0                               # 重さ(重力と風に影響)
    @friction = 0                             # 抵抗(風と空気抵抗に影響)
    @repeat = 0                               # アニメの繰り返し回数
    @spin = 0                                 # 回転設定
    @direction_to_spin = false                # 移動方向を回転方向に反映
    @spin_speed = 0                           # 回転速度
    @revise_x = 0                        # X座標修正値
    @revise_y = 0                        # Y座標修正値
    @count = 0                                # 経過時間
    @total_count = 0                          # 総合経過時間
    @update_count = 0                         # アップデート用カウント
    @pattern = 0                              # アニメーションパターン             
    @anime_count = 0                          # アニメカウント
    @repeat_count = 0                         # 繰り返した回数
    # 乱数設定
    init_rand
    @rand_index = rand_index
    # セットアップ
    set_up
  end

  # パーツの設定
  def set_new_parts(parts_data, rand_index = 0)
    finish
    @parts = parts_data
    @rand_index = rand_index
    @update_count = 0
    set_up
  end

  # 次のパーツに引き継ぐ 
  def set_next_frame(frame_data)
    @frame = frame_data
    set_motion
  end 

  # 初期設定
  def set_up
    @finished = false                           # 終了を解除
    @with_emitter = false
    set_basic
    set_frame                                 # フレームを初期化
    set_motion                                # モーション設定を初期化
  end
  
  # 基本設定を設定
  def set_basic
    @index = 1
    @total_count = 0
    self.angle = 0
    @random_mirror = random_mirror?           # ランダムで反転を行うか？
    @delay = @parts.delay                     # 処理のディレイ
    self.z = 0
  end

  # フレームを設定
  def set_frame
    @frame = @parts.frame_list[@index]
  end
 
  # モーションを設定
  def set_motion
    return if frame_empty?
    # イージング用ハッシュ
    easing = {}
    # 補完終点フレーム
    @target = next_frame
    # 画像を変更
    @parts_img = set_imgset
    # その他のパラメータ
    @weight          = @frame.weight           # 重さ(重力と風に影響)
    @friction        = @frame.friction         # 抵抗(風と空気抵抗に影響)
    @repeat          = @frame.repeat           # アニメの繰り返し回数
    @update_position = true                    # 位置情報の更新フラグ
    # 持続時間の初期設定
    @span = @frame.span * variance(@frame.span_variance) / 100
    # 持続時間が0なら終了
    return if @span <= 0
    # 画像の合成方法
    self.blend = @frame.blend
    # 回転の初期設定
    @direction_to_spin = false
    @spin = spin
    # 回転速度の初期設定
    @spin_speed = @frame.spin_speed
    easing[:spin_speed] = @target.spin_speed if @frame.spin_speed != @target.spin_speed
    # 反転の初期設定
    @mirror = @random_mirror ? (not @frame.mirror) : @frame.mirror 
    # 不透明度の初期設定
    self.alpha = @frame.alpha
    easing[:alpha] = @target.alpha if @frame.alpha != @target.alpha
    # 修正座標の初期設定
    @revise_x = @frame.revise_x     
    @revise_y = @frame.revise_y
    easing[:revise_x] = @target.revise_x if @frame.revise_x != @target.revise_x
    easing[:revise_y] = @target.revise_y if @frame.revise_y != @target.revise_y
    # 拡大率の初期設定
    self.scale_x = @frame.scale_x / 100.0
    self.scale_y = @frame.scale_y / 100.0
    easing[:scale_x] = @target.scale_x / 100.0 if @frame.scale_x != @target.scale_x
    easing[:scale_y] = @target.scale_y / 100.0 if @frame.scale_y != @target.scale_y
    # 色調の初期設定
    @tone_red   = @frame.tone_red
    @tone_green = @frame.tone_green
    @tone_blue  = @frame.tone_blue
    @tone_gray  = @frame.tone_gray
    self.tone(@tone_red, @tone_green, @tone_blue, @tone_gray)
    easing[:tone_red]   = @target.tone_red   if @frame.tone_red   != @target.tone_red
    easing[:tone_green] = @target.tone_green if @frame.tone_green != @target.tone_green
    easing[:tone_blue]  = @target.tone_blue  if @frame.tone_blue  != @target.tone_blue
    easing[:tone_gray]  = @target.tone_gray  if @frame.tone_gray  != @target.tone_gray
    @update_tone = (easing.key?(:tone_red) || easing.key?(:tone_blue) || easing.key?(:tone_green) || easing.key?(:tone_gray))
    # イージングのセット
    animate(easing, @span, :liner)
    # システム値の設定
    @count        = 0                               # 経過時間
    @pattern      = 0 if @frame.reset_anime         # アニメーションパターン             
    @anime_count  = 0                               # アニメカウント
    @repeat_count = 0                               # 繰り返した回数
    self.visible  = true                            # 可視状態
    # 画像の変更
    set_bitmap
  end

  # 角度の初期設定 
   def set_angle(value)
    self.angle = value
    @real_angle = value * 10
  end
  
  # 角度の修正 
  def adjust_angle(value)
    self.angle += value
    @real_angle += value * 10
  end

  # パーツの座標設定 
  def set_pos(px, py)
    @real_x = px * 8000
    @real_y = py * 8000
    update_sprite_pos
  end
  
  # パーツの実座標設定 
  def set_real_pos(px, py)
    @real_x = px * 1000
    @real_y = py * 1000
    update_sprite_pos
  end

  # パーツの修正座標設定 
  def adjust_pos(px, py)
    @real_x += px * 1000
    @real_y += py * 1000
    update_sprite_pos
  end

  # パーツの座標設定 
  def adjust_z(value)
    self.z += value
  end

  # 移動ベクトルの設定 
  def set_vector(x, y, acceleration = 0)
    @vector_x = x
    @vector_y = y
    @acceleration = 100 + acceleration
  end

  ### 参照関連(基本)
  # 実座標Ｘ
  def real_x
    @real_x / 1000
  end

  # 実座標Ｙ
  def real_y
    @real_y / 1000
  end

  ### 参照関連(フラグの参照・設定)
  # モーションが空か？
  def frame_empty?
    @finished = (@frame == nil or @frame.header?)
    @finished
  end
 
  # パーツの生存確認 
  def live?
    # 経過時間が寿命以下ならtrue
    (@count < @span)
  end

  # 終了しているか？
  def finish?
    @finished
  end

  # 終了
  def finish
    stop_animate
    self.visible = false
    @bitmap = nil
    @finished = true
  end

  # エディットモード
  def edit
    @edit = true
  end

  ### 参照関連(画像セットデータ)
  # 画像セット
  def set_imgset
    img_id = @frame.img_list[erand(@frame.img_list.size)]
    img_id ? $data_parts_image[img_id] : nil
  end
 
  # 画像セットの変更
  def change_imgset
    imgset = @frame.img_list
    return nil if imgset.empty?
    case @frame.change_type
    when 0 # なし
      return @parts_img
    when 1 # リスト順  
      @imgset_index = (@imgset_index + 1) % imgset.size
      return $data_parts_image[imgset[@imgset_index]]
    when 2 # ランダム順  
      @imgset_index = erand(imgset.size)
      return $data_parts_image[imgset[@imgset_index]]
    end  
  end
    
  ### 画像を設定
  def set_bitmap
    if @parts_img
      @column = @parts_img.column
      @number_of_pattern = @parts_img.number_of_pattern
      @bitmap = Cache.load_image(@parts_img.filename)
      @cw = @parts_img.width
      @ch = @parts_img.height
      @sx = @parts_img.start_pos_x
      @sy = @parts_img.start_pos_y
      self.center_x = @parts_img.ox 
      self.center_y = @parts_img.oy
      update_src_rect
    else
      @bitmap = Cache.load_image("")
    end
  end

  ### 参照関連(セットデータ)
  # 次のモーション
  def next_frame
    frames = @frame.frame_list
    # 次のモーションが空
    @next_frame = !frames.empty?
    # 次のモーションをセット
    @next_frame ? @parts.frame_list[frames[erand(frames.size)]] : @frame
  end

  ### 参照関連(画像・アニメデータ)
  ## 分散度
  def variance(value)
    100 + value / 2 - erand(value)
  end

  # 運動量がゼロになった場合停止
  def end_when_stop?
    @frame.end_when_stop
  end

  # 回転の設定
  def spin
    case @frame.spin
    when 0
      return 0
    when 1
      return @random_mirror ? 2: 1
    when 2
      return @random_mirror ? 1: 2
    when 3
      return 1 + erand(2)
    when 4  
      return 0 
    when 5
      @direction_to_spin = true
      return 0
    end
  end

  # 角度をランダムに決定するか？
  def random_angle?
    @parts.random_angle
  end

  # 角度を射出方向にあわせる
  def angle_of_emission?
    @parts.angle_from_emission
  end

  # 画像と回転の反転をランダムに行うか？
  def random_mirror?
    if @parts.random_mirror
      erand(2) == 0
    else
      false
    end
  end

  ### 更新関連 
  # フレーム更新 
  def update
    if @update_count == 0
      update_parts unless @finished             # パーツの更新 
      unless @finished
        super
        update_last_pos                         # 1フレーム前の位置を更新
        update_vector                           # ベクトルの更新
        update_path                             # パスの更新
        update_angle                            # 角度の更新
        update_position   if @update_position   # 位置情報の更新
        update_tone       if @update_tone       # 色調の更新
        update_animation  if @parts_img         # アニメーションの更新
        #valid?
      end
    end
    update_sprite_pos  unless @finished
    @update_count = (@update_count + 1) % @delay
  end

  # パーツの更新 
  def update_parts
    loop do
      # 停止した場合次のフレームへ
      if end_when_stop? && !@edit
        break_flag = (round_radius(@vector_x / 1000, @vector_y / 1000) < 10)
      end
      # パーツの消滅処理
      break if live? && !break_flag
      # 繰り返し回数が残っていれば繰り返す
      @repeat_count += 1
      if @repeat_count < @repeat && !break_flag
        @parts_img = change_imgset #画像の張替え
        @count = 0
      # 次のモーションに引き継ぐ
      elsif @next_frame
        set_next_frame(@target)
      # 終了
      else
        finish 
        break
      end
    end
    @count       += 1
    @total_count += @delay

  end

  # パーツが有効か？ 
  def valid?  
    if self.x < -LIMIT_WIDTH || self.x > 640 + LIMIT_WIDTH ||
      self.y < -LIMIT_HEIGHT || self.y > 480 + LIMIT_HEIGHT
      finish
    end
  end
 
  # アニメカウントの更新
  def update_animation
    # 画像がない場合終了する
    @anime_count = (@anime_count + 1) % @frame.anime_speed
    if @anime_count == 0 
      if @frame.random_anime
        @pattern = erand(@parts_img.number_of_pattern)     
      else
        @pattern = (@pattern + 1) % @parts_img.number_of_pattern
      end
      update_src_rect
    end
  end

  # 転送元矩形の更新
  def update_src_rect
    sx = @pattern % @column * @cw + @sx
    sy = @pattern / @column * @ch + @sy
    self.src_rect(sx, sy, @cw, @ch)
  end

  # 1フレーム前の座標の更新
  def update_last_pos
    @last_real_x = @real_x
    @last_real_y = @real_y
  end

  # ベクトル情報の更新
  def update_vector
    @vector_x = @vector_x * @acceleration / 100
    @vector_y = @vector_y * @acceleration / 100
  end

  # 位置情報の更新
  def update_position
    @real_x = @real_x + @vector_x / 10
    @real_y = @real_y + @vector_y / 10
  end

  # スプライト座標の更新
  def update_sprite_pos
    self.x = @real_x / 8000 + @revise_x
    self.y = @real_y / 8000 + @revise_y
  end
  
  # 回転速度の更新
  def update_spin_speed
    if @frame.spin_from_move
      @spin_speed = round_radius(@vector_x / 1000, @vector_y / 1000) * 10
    else
      @spin_speed = @original_spin_speed + @adjust_spin_speed * @count / @span
    end
  end

  # アングルの更新
  def update_angle
    # 移動方向を角度に反映
    if @direction_to_angle
      move_x = @real_x - @last_real_x 
      move_y = @real_y - @last_real_y 
      @real_angle = vector_to_angle(move_x, move_y, @real_angle / 100) * 100
    # アングルの更新
    else
      # アングルの更新
      case @spin
      when 1 # 時計回り
        @real_angle = (@real_angle - @spin_speed) % 3600
      when 2 # 反時計回り
        @real_angle = (@real_angle + @spin_speed) % 3600
      end
    end
    self.angle = 360 - (@real_angle / 10)
  end

  # 色調の更新
  def update_tone
    self.tone(@tone_red, @tone_green, @tone_blue, @tone_gray)
  end

  # フィジックス：パスの更新
  def update_path
    # エミッターに所属している場合終了
    if !@with_emitter && @path && !@path.valid?
      # パスの処理
      path_x, path_y = @path.proccess_path(real_x, real_y, @total_count)
      @real_x = path_x * 1000
      @real_y = path_y * 1000
      # 位置情報の更新を行わない
      @update_position = false
    end
  end
  
end




### ■パーツを放出するエミッターのクラス■ ###
class Game_Emitter < Sprite_Base
  

  # Mix-In
  include RandTable
  include Coordinate

  # 公開インスタンス変数
  attr_accessor :real_x                   
  attr_accessor :real_y                   
  attr_accessor :z
  attr_accessor :angle
  attr_accessor :visible
  attr_accessor :path
  attr_reader   :parts_list
  attr_reader   :time
  
  # オブジェクト初期化
  def initialize(emitter_data, target = nil)
    super(target)
    init_rand
    @finish = true
    @emitter = emitter_data
    @parts_list = []
    @valid_list = []
    @finished_list = []
    @real_x = 0                               # 実座標 X
    @real_y = 0                               # 実座標 Y
    @z = 0                                    # 座標 Z
    @proccess_time = 0
    @max_time = 0
    set_up
  end
  
  # 初期設定
  def set_up
    # デバッグ用
    @time = @proccess_time
    @proccess_time = 0
    @max_time = 0
    # 数値の初期設定
    ew = @emitter.width
    eh = @emitter.height
    self.image.resize(ew, eh)
    self.image.ox = -ew / 2
    self.image.oy = -eh / 2
    self.center_x = ew / 2
    self.center_y = eh / 2
    #@draw_target = @emitter.draw_target
    @sprite = false                           # スプライトが設定されているか
    @rand_flag = (@emitter.rand_seed < 0)
    @rand_index = @emitter.rand_seed / 10
    @rand_coefficient = @emitter.rand_seed % 10 + 1
    @angle = 0                                # 画像角度
    @emit_angle = 0                           # 放出角度  
    @emit_range = 0                           # 射出範囲
    @visible = true                           # 可視状態
    @count = 0                                # 経過時間
    @finish = false                           # 終了フラグ
    @need_parts_sprite = false
    self
  end
  
  # 新しいエミッターを設定
  def set_new_emitter(emitter_data)
    # エフェクターの終了
    finish
    # パーツが設定されていない場合終了
    return if emitter_data.parts_list.empty?
    # 持続時間が0以下の場合終了
    return if emitter_data.span <= 0
    # 新しいエミッターデータの終了
    @emitter = emitter_data
    # セットアップ
    set_up
  end
  
  # 角度の修正 
  def adjust_angle(value)
    @angle += value
  end
  
  # エミッターの座標設定
  def set_pos(x, y)
    self.x = x
    self.y = y
  end
    
  # エミッターの座標修正 #*変更
  def adjust_pos(x, y)
    self.x += x
    self.y += y
  end

  # パーツの座標設定 
  def adjust_z(value)
    self.z += value
  end
  
  # エミッターの可視状態
  def visible=(value)
    @valid_list.each{|i| @parts_list[i].visible = value if @parts_list[i].nil?}
  end
  
  # エミッターの生存確認
  def live?
    # 経過時間が寿命以下ならtrue(寿命が10000の常にtrue)
    @emitter.span == 10000 || (@count <= @emitter.span) 
  end
  
  # エミッターの終了
  def finish
    @finish = true
    # 登録パーツを全て終了
    for parts in @parts_list
      next if parts.vanished?
      parts.finish
      parts.vanish
    end
    @parts_list.clear
    @valid_list.clear
    @finished_list.clear
  end
  
  # エミッターが終了しているか？
  def finish?
    @finish
  end
  
  ### 参照関連 ###
  # パーツオブジェクトの取得
  def parts_obj(index)
    $data_parts[index]
  end
    
  # 分散度
  def variance(value)
    100 + value / 2 - erand(value)
  end
  
  # 射出速度
  def velocity
    @emitter.velocity * variance(@emitter.velocity_variance) * 10
  end
  
  # 加速度
  def acceleration
    @emitter.acceleration * variance(@emitter.acceleration_variance) / 100
  end
  
  ### 更新関連 ###
  # フレーム更新 
  def update
    update_emitter    # エミッターの更新
    update_parts_list  # パーツの更新
  end
  
  # エミッターの更新 
  def update_emitter
    # エミッターの生存確認
    finish if !live? && @valid_list.empty?
    # 終了フラグが立っている場合終了
    unless finish?
      # カウントをするめる
      @count = (@count + 1) % 10000        
      # 更新
      update_emit_range       # 射出範囲の更新
      update_emit_angle
      update_path             # パスの更新
      emit_parts if live?  # パーツの射出
    end
  end
  
  # フレーム単位の値
  def frame_value(original, target)
    original + (target - original) * @count / @emitter.span
  end
  
  # 射出範囲の更新
  def update_emit_range
    @emit_range = frame_value(@emitter.emit_range, @emitter.target_emit_range)
  end
  
  # 射出角度の更新
  def update_emit_angle
    @emit_angle = frame_value(@emitter.target_emit_angle * 10000, @emitter.emit_angle * 10000) / 10000

  end
  
  # パーツの放出
  def emit_parts
    # 射出タイミングの場合パーツを射出
    if @count % @emitter.interval == 0
      @emitter.injection_number.times{|i| create_parts}
    end
  end
  
  # パーツデータの作成
  def create_parts
    # 新しいパーツをセット
    new_parts = set_new_parts
    return unless new_parts
    # ビューポートを設定
    new_parts.target = @draw_target ? self.image : self.target
    # Z座標を設定
    new_parts.z = @z
    # 可視状態を設定
    new_parts.visible = @visible
    # フィジックスを設定
    set_parts_physics(new_parts)
    # 位置情報を設定
    emit_pos_x = (@emitter.radius_x - 1 - (erand(@emitter.radius_x) + erand(@emitter.radius_x)))
    emit_pos_y = (@emitter.radius_y - 1 - (erand(@emitter.radius_y) + erand(@emitter.radius_y)))
    unless @draw_target
      emit_pos_x += self.x
      emit_pos_y += self.y
    end
    new_parts.set_pos(emit_pos_x, emit_pos_y)
    # 角度の決定
    emit_angle = (@emit_angle + @angle + @emit_range / 2 - erand(@emit_range + 1)) % 360
    if new_parts.random_angle?
      new_parts.set_angle(erand(360))
    elsif new_parts.angle_of_emission?
      new_parts.set_angle(emit_angle)
    end
    # ベクトルの決定 
    emit_speed = velocity
    vector_x = -(round_sin(emit_angle) * emit_speed).round
    vector_y = -(round_cos(emit_angle) * emit_speed).round
    # ベクトル情報をセット
    new_parts.set_vector(vector_x, vector_y, acceleration)
  end
  
  # 新しいパーツデータをセット
  def set_new_parts
    # パーツデータを読み出す
    index = @emitter.parts_list[erand(@emitter.parts_list.size)]
    return nil unless index
    new_parts_data = parts_obj(index)
    # パーツデータがない場合終了
    if new_parts_data
      # リサイクル可能なデータがある場合再利用する
      if !@finished_list.empty?
        i = @finished_list.pop 
        new_parts = @parts_list[i]
        new_parts.set_new_parts(new_parts_data, @rand_index)
        @valid_list.push(i)
      # 保持できる最大数以下ならパーツを格納する
      elsif @parts_list.size < @emitter.max_parts
        @valid_list.push(@parts_list.size)
        new_parts = Game_Parts.new(new_parts_data, @rand_index)
        @parts_list.push(new_parts)
      end
    end
    new_parts
  end
  
  # パーツにフィジックスを設定
  def set_parts_physics(parts_data)
    # フィジックスを設定
    parts_data.with_emitter = true
    parts_data.physics = @physics
  end
  
  # パーツセットの更新 
  def update_parts_list
    for i in @valid_list    # エミッターの更新
      parts = @parts_list[i]
      parts.update
      if parts.finished
        @finished_list.push(i)
        @valid_list.delete(i)
      end
    end
  end
  
  ### パス ###
  # パスの更新
  def update_path
    if @path
      # パスの処理
      path_x, path_y = @path.proccess_path(@real_x, @real_y, @count)
      @real_x = path_x
      @real_y = path_y
    end
  end
  
  # 描画
  def draw
    Sprite.draw(@parts_list)
    super
  end
  
  ### デバッグ関連 ###
  # エミッターの情報 
  
  def emiter_info
    "ps:#{@parts_list.size},vs:#{@valid_list.size},fs:#{@finished_list.size}"   
  end
  
end


### ■パーツとエミッターを管理するエフェクターのクラス■ ###
class Game_Animation < Sprite_Base
  
  # Mix-In  
  include RandTable
  include Coordinate

  # オブジェクト初期化  
  def initialize(animation_data = nil)
    init_rand
    @target = nil
    @animation = animation_data
    @display_x = 0
    @display_y = 0
    @real_x = 0                               # 実座標 X
    @real_y = 0                               # 実座標 Y
    @parts_list = []
    @emitters = []
    @time = 0
    @time_count = 0
    set_up
  end
  
  # 初期設定  
  def set_up
    # 数値の初期設定
    #generate_path                             # パスの生成
    #generate_tag                              # 効果タグの生成
    @count = 0                                # 経過時間
    @visible = true                           # 可視状態
    @finish = false                           # 終了フラグ
    @easy_refresh = false
  end   
  
  
  
end


=begin
### ■パーツとエミッターを管理するエフェクターのクラス■ ###
class Game_Animation < Sprite_Base
    
  # Mix-In  
  include RandTable
  include Coordinate
  
  # 公開インスタンス変数  
  attr_accessor :real_x                   # マップ X 座標 (実座標 * 256)
  attr_accessor :real_y                   # マップ Y 座標 (実座標 * 256)
  attr_accessor :target
  attr_accessor :visible
  attr_reader   :display_x
  attr_reader   :display_y
  attr_reader   :zoom_rate
  attr_reader   :z
  attr_reader   :parts_list
  attr_reader   :emitters
  attr_reader   :physics
  attr_reader   :tag
  attr_reader   :animation
  attr_reader   :time
  
  # オブジェクト初期化  
  def initialize(animation_data = nil)
    init_rand
    @target = nil
    @animation = animation_data
    @display_x = 0
    @display_y = 0
    @zoom_rate = 10000
    @real_x = 0                               # 実座標 X
    @real_y = 0                               # 実座標 Y
    @z = 0
    @angle = 0
    @parts_list = []
    @emitters = []
    @time = 0
    @time_count = 0
    set_up
  end
  
  # 初期設定  
  def set_up
    # 数値の初期設定
    generate_path                             # パスの生成
    generate_tag                       # 効果タグの生成
    @count = 0                                # 経過時間
    @visible = true                           # 可視状態
    @finish = false                           # 終了フラグ
    @easy_refresh = false
  end 
  
  # 新しいエフェクターを設定   
  def set_new_animation=(animation_data)
    # エフェクターの終了
    finish
    # 新しいエフェクターデータ
    @animation = animation_data
    # セットアップ
    set_up
  end
  
  # 簡易リフレッシュ  
  def easy_refresh=(value)
    @easy_refresh = value
  end
  
  # 画面設定  
  def set_display(display_x, display_y, zoom_rate = 1.0)
    if @animation
      @display_x = @animation.fix_pos ? 0 : (display_x * 256).round
      @display_y = @animation.fix_pos ? 0 : (display_y * 256).round
      @zoom_rate = @animation.fix_zoom ? 10000 : (zoom_rate * 10000).round
    end
  end
  
  # エフェクターの座標設定  
  def set_pos(x, y)
    px = x - @real_x
    py = y - @real_y
    @real_x = x
    @real_y = y
    # パーツの位置調整
    @parts_list.each{|parts| parts.adjust_pos(px, py)}
    # エミッターの位置調整
    @emitters.each{|emitter| emitter.adjust_pos(px, py)}
  end
  
  # エフェクターのZ座標設定  
  def z=(value)
    revise_z = @z - value
    @z = value
    # パーツの位置調整
    @parts_list.each{|parts| parts.adjust_z(revise_z)}
    # エミッターの位置調整
    @emitters.each{|emitter| emitter.adjust_z(revise_z)}
  end
  
  # エフェクターの角度設定  
  def angle=(value)
    angle_temp = @angle - value
    @angle = value
    # パーツの位置調整
    @parts_list.each{|parts| parts.adjust_angle(angle_temp)}
    # エミッターの位置調整
    @emitters.each{|emitter| emitter.adjust_angle(angle_temp)}
  end
  
  # エフェクターの可視状態  
  def visible=(value)
    @visible = value
    # パーツの位置調整
    @parts_list.each{|parts| parts.visible = value}
    # エミッターの位置調整
    @emitters.each{|emitter| emitter.visible = value}
  end
  
  # エフェクターの解放  
  def vanish
    finish
  end
  
  # エフェクターの終了
  def finish
    @finish = true
    # 登録パーツを全て終了
    for parts in @parts_list
      next if parts.disposed?
      parts.finish
      parts.dispose
    end    
    @parts_list.clear
    # 登録エミッターを全て終了
    for emitter in @emitters
      emitter.finish
    end
    @emitters.clear
  end
  
  # エフェクターが終了しているか？ #*変更
  def finish?
    @finish
  end
  
  ### 参照関連  
  # エフェクターが保持できる最大パーツ数
  def object_max
    @animation.object_max
  end
  
  ### 更新関連 ###  
  # フレーム更新  
  def update
    time = Time.now
    if @animation && !@finish
      # メイン処理の更新
      update_animation    # エフェクターの更新
      update_tag  # エフェクトタグの更新
      update_emitters    # エミッターの更新
      update_parts_list   # パーツの更新
    end
    @time += Time.now - time
    @time_count = (@time_count + 1) % 60
    if @time_count == 0
      #p @time
      @time = 0
    end
  end
  
  # エフェクターの更新   
  def update_animation
    # カウントをするめる
    @count += 1         
    # 更新
    generate_emitters    # エミッターの生成
    generate_parts_list   # パーツの生成
  end
  
  ### パーツの生成 ###
  # パーツの作成  
  def generate_parts_list
    # 発生タイミングの場合パーツを射出
    for parts_data in @animation.parts_list
      next unless parts_data
      create_parts(parts_data) if @count == parts_data.start_time
    end
  end
  
  # パーツデータの作成  
  def create_parts(parts_data)
    # パーツデータを読み出す
    for index in parts_data.parts_list
      new_parts_data = @animation.parts_obj[index]
      # パーツデータがない場合終了
      next unless new_parts_data
      # パーツを格納する
      new_parts = Game_Particle.new(new_parts_data, self, erand(1024))
      @parts_list.push(new_parts)
      # ビューポートを設定
      new_parts.target = @target
      # 可視状態を設定
      new_parts.visible = @visible
      # Z座標を設定
      set_parts_z(parts_data, new_parts)
      # パスを設定
      set_parts_path(parts_data, new_parts)
      # 位置情報を設定
      set_parts_pos(parts_data, new_parts)
      # 角度情報を設定
      set_parts_angle(parts_data, new_parts)
    end
  end
  
  # パーツのZ座標を設定  
  def set_parts_z(parts_data, new_parts)
    # パスを設定
    new_parts.z = parts_data.z + @z
  end
  
  # パーツのパスを設定  
  def set_parts_path(parts_data, new_parts)
    # パスを設定
    new_parts.path = @paths[parts_data.path_list]
  end
  
  # パーツの位置を設定  
  def set_parts_pos(parts_data, new_parts)
    # 位置情報を設定
    new_parts.set_pos(@real_x + parts_data.x * 8, @real_y + parts_data.y * 8)
  end
  
  # 角度を設定  
  def set_parts_angle(parts_data, new_parts)
    # 角度の決定
    if new_parts.random_angle?
      angle_temp = erand(360)
      new_parts.set_angle(angle_temp)
    else
      new_parts.set_angle(parts_data.angle + @angle)
    end
  end
  
  # パーツセットの更新  
  def update_parts_list
    @parts_list.size.times do |i|
      parts = @parts_list[i]
      parts.update
      if parts.finish?
        parts.dispose
        @parts_list[i] = nil
      end
    end
    @parts_list.compact!
  end
  
  # 表示座標を差し引いた X 座標の計算
  def parts_adjust_x(x)
    (x - @display_x) * @zoom_rate / 10000
  end
  
  # 表示座標を差し引いた X 座標の計算  
  def parts_adjust_y(y)
    (y - @display_y) * @zoom_rate / 10000
  end
  
  # 表示座標を差し引いた X 座標の計算
  def parts_adjust_zoom(zoom)
    zoom * @zoom_rate / 10000
  end
  
  ### エミッターの生成  
  # エミッターの作成  
  def generate_emitters
    # 発生タイミングの場合エミッターを射出
    for emitter_data in @animation.emitter_list
      next unless emitter_data
      create_emitter(emitter_data) if @count == emitter_data.start_time
    end
  end
  
  # エミッターデータの作成  
  def create_emitter(emitter_data)
    # エミッターデータを読み出す
    for index in emitter_data.emitter_list
      new_emitter_data = @animation.emitter_obj[index]
      # エミッターデータがない場合終了
      next unless new_emitter_data
      # エミッターを格納する
      new_emitter = Game_Emitter.new(new_emitter_data, self)
      @emitters.push(new_emitter)
      # ビューポートを設定
      new_emitter.target = @target
      # 可視状態を設定
      new_emitter.visible = @visible
      # Z座標を設定
      set_emitter_z(emitter_data, new_emitter)
      # パスを設定
      set_emitter_path(emitter_data, new_emitter)
      # 位置情報を設定
      set_emitter_pos(emitter_data, new_emitter)
      # 角度情報を設定
      new_emitter.angle = emitter_data.angle + @angle
    end
  end
  
  # エミッターのZ座標を設定  
  def set_emitter_z(emitter_data, new_emitter)
    # パスZ座標を設定
    new_emitter.z = emitter_data.z + @z
  end
  
  # エミッターのパスを設定  
  def set_emitter_path(emitter_data, new_emitter)
    # パスを設定
    new_emitter.path = @paths[emitter_data.path_list]
  end
  
  # エミッターの位置を設定  
  def set_emitter_pos(emitter_data, new_emitter)
    # 位置情報を設定
    new_emitter.set_pos(@real_x + emitter_data.x * 8, @real_y + emitter_data.y * 8)
  end
  
  # エミッターセットの更新  
  def update_emitters
    @emitters.size.times do |i|
      emitter = @emitters[i]
      emitter.update
      @emitters[i] = nil if emitter.finish?
    end
    @emitters.compact!
  end
  
  ### パスの生成 ###
  # パスの作成
  
  def generate_path
    @paths = []
    # パスの作成
    @animation.path_list.each{|path_data| create_path(path_data)}
    # パスにパスを設定
    @paths.each{|path| set_path_path(path) if path}
  end
  
  # パスデータの作成  
  def create_path(path_data)
    if path_data
      # パスデータを作成
      new_path = Game_Path.new(path_data)
      @paths.push(new_path)
      # 位置情報を設定
      new_path.set_pos(@real_x, @real_y)
    end
  end
  
  # パスにパスを設定  
  def set_path_path(path)
    # パスを設定
    path.path = @paths[path.path_data.path_list]
  end
  
  ### 効果タグの生成 ###
  # 効果タグの作成
  def generate_tag
    @tag = []
    # 効果タグの作成
    @animation.tag_list.each{|tag| create_tag(tag) if tag}
  end
  
  # 効果タグデータの作成  
  def create_tag(tag_data)
    # 効果タグを作成
    new_tag = tag_data
    @tag.push(new_tag)
  end
  
  # 効果タグセットの更新  
  def update_tag
    for tag_data in @tag
      proccess_tag(tag_data) if tag_data
    end
  end
  
  # 効果タグの処理 
  
  def proccess_tag(tag_data)

  end
  
end
=end