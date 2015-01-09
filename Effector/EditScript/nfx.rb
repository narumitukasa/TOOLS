#coding: utf-8

module NFX 
  
  # クラス変数
  @@library = {}
  @@current_library = Library.new(:none)
  @@current_library_name = :none  
  
  def self.init_nfx_data
  end
    
  def self.create_library(name)
    @@library[name] = Library.new(name)
  end
    
  def self.current_library
    @@current_liblary
  end
    
  def self.current_library=(name)
    @@current_library_name = name
    @@current_liblary = @@library[name]
  end
    
  def self.current_library_name
    @@current_library_name
  end
  
end