### ■データ管理用モジュール■ ###

require 'zlib'

module DataManager 
  
  # データベースの読み込み
  def self.load_effect
    $data_parts_image = load_data("./Data/PartsImage.dat")
    $data_parts       = load_data("./Data/Parts.dat")
    $data_emitter     = load_data("./Data/Emitter.dat")
    $data_animation   = load_data("./Data/Animation.dat")
  end
  
  # データベースの保存
  def self.save_effect
    save_data($data_parts_image, "./Data/PartsImage.dat")
    save_data($data_parts,       "./Data/Parts.dat")
    save_data($data_emitter,     "./Data/Emitter.dat")
    save_data($data_animation,   "./Data/Animation.dat")
    
  end
  
  # データベースの修復
  def self.repair_effect
    repair($data_parts_image)
    repair($data_parts)
    repair($data_emitter)
    repair($data_animation)
  end
  
end