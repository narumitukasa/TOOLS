#coding: utf-8

module WS
  module FloatingWindow
    def priority
      (super + 2)
    end
  end
  
  class WSControl
    def priority
      activated? ? 1 : 0 
    end
  end
  
  class WSDesktop
    # システムフォーカスをセットする。
    def set_focus(obj)
      return obj if @system_focus == obj
      return nil if obj != nil and @children.index(obj) == nil
  
      @system_focus.on_leave if @system_focus
      @system_focus = obj
      obj.on_enter if obj
      @children.sort{|a,b| a.priority <=> b.priority} if obj
      obj
    end
  end  
end