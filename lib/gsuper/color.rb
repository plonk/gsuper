require 'gtk2'

module GSuper

module Color
  def gdk_color(arr)
    raise 'format error' unless arr.size.between?(3,4) && arr.all? { |ch| ch.between?(0.0,1.0) }
    r, g, b, = arr
    return Gdk::Color.new(r * 65535, g * 65535, b * 65535)
  end
  module_function :gdk_color

  def gdk_alpha(arr)
    raise 'format error unless' unless arr.size == 4
    _, _, _, alpha = arr
    return alpha * 65535
  end
  module_function :gdk_alpha
end

end
