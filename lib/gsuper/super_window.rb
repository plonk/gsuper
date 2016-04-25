require 'gsuper/color'

module GSuper

# 字幕ウィンドウを表わすクラス。
class SuperWindow < Gtk::Window
  include Color
  BACKGROUND_COLOR = Color::gdk_color([0.0, 1.0, 0.0])
  BACKGROUND_ALPHA = 0.5

  attr_reader :font_name, :text_color, :shadow_color, :text

  def initialize
    super()

    @font_name = 'Sans Bold 24'
    @text_color = Color::gdk_color([1.0, 0.5, 0.0])
    @shadow_color = Color::gdk_color([0.0, 0.0, 1.0])
    @text = ""

    @interactive = true

    self.app_paintable = true

    signal_connect('expose-event') do
      if @interactive
        exposed_interactive
      else
        exposed_noninteractive
      end
    end

    self.events = Gdk::Event::BUTTON_PRESS_MASK |
                  Gdk::Event::BUTTON_RELEASE_MASK |
                  Gdk::Event::POINTER_MOTION_MASK

    signal_connect('screen-changed') do 
      screen_changed
    end

    signal_connect('configure-event') do
      # p :configure
      invalidate
      set_responsive(interactive?)
      # exposeを誘発するためにfalseを返す
      false
    end

    button_pressed = false
    press_point = nil
    move = nil
    signal_connect('button-press-event') do |_, ev_button|
      button_pressed = true
      w, h = size
      if ev_button.x.between?(w - 30, w - 1) &&
         ev_button.y.between?(h - 30, h - 1)
        move = false
        press_point = [(w - ev_button.x), (h - ev_button.y)]
      else
        move = true
        press_point = [ev_button.x, ev_button.y]
      end
      # p :press
    end

    signal_connect('button-release-event') do
      button_pressed = false
      press_point = nil
      move = nil
      # p :release
    end

    signal_connect('motion-notify-event') do |_, ev_motion|
      if interactive? && button_pressed
        if move
          move(ev_motion.x_root - press_point[0], ev_motion.y_root - press_point[1])
        else
          w = ev_motion.x + press_point[0]
          h = ev_motion.y + press_point[1]
          resize([w, 100].max, [h, 100].max)
          # invalidate
          # set_responsive(true)
        end
      end
      # p :pointer_motion
    end

    # self.decorated = false

    self.set_default_size(640,480)

    @alpha_supported = false
    screen_changed

    # GDK window を作る。
    realize

    window.override_redirect = true
    set_responsive(true)
  end

  def font_name=(font)
    @font_name = font
    invalidate
  end

  def text_color=(color)
    raise TypeError unless color.is_a? Gdk::Color
    @text_color = color
    invalidate
  end

  def shadow_color=(color)
    raise TypeError unless color.is_a? Gdk::Color
    @shadow_color = color
    invalidate
  end

  def text=(str)
    @text = str
    invalidate
  end

  def exposed_interactive
    cr = window.create_cairo_context 

    if @alpha_supported
      cr.set_source_rgba(*pango_triple(BACKGROUND_COLOR), BACKGROUND_ALPHA)
    else
      cr.set_source_rgb(*pango_triple(BACKGROUND_COLOR))
    end

    cr.set_operator(Cairo::OPERATOR_SOURCE)
    cr.paint

    draw_text(cr)

    cr.set_source_rgb(0.5, 0.5, 0.5)
    w, h = size
    cr.fill do
      cr.rectangle(w - 30, h - 3, w, h)
      cr.rectangle(w - 3, h - 30, w, h)
    end

    cr.destroy

    return false
  end

  def exposed_noninteractive
    cr = window.create_cairo_context 

    if @alpha_supported
      cr.set_source_rgba(0.0, 0.0, 0.0, 0.0)
    else
      cr.set_source_rgb(0.0, 0.0, 0.0)
    end

    cr.set_operator(Cairo::OPERATOR_SOURCE)
    cr.paint

    draw_text(cr)

    cr.destroy

    return false
  end

  def draw_text(cr)
    # p [:draw_text, font_name]
    desc = Pango::FontDescription.new(font_name)

    layout = create_pango_layout
    layout.width = size[0] * Pango::SCALE
    layout.font_description = desc
    layout.text = text

    offset = shadow_offset(desc)

    cr.move_to(offset, offset)
    cr.set_source_rgba(*pango_triple(@shadow_color), 1.0)
    cr.show_pango_layout(layout)

    cr.move_to(0, 0)
    cr.set_source_rgba(*pango_triple(@text_color), 1.0)
    cr.show_pango_layout(layout)
  end

  # 右下に二度打ちで「影」を落とす。そのオフセットは線の太さの半分にし
  # たいとする。
  def shadow_offset(desc)
    raise TypeError unless desc.is_a? Pango::FontDescription
    dpi = window.screen.resolution

    font_px = pt_to_px(desc.size.fdiv(Pango::SCALE), dpi)
    return ( font_px * (1/12.0) * (desc.weight.to_i / 400.0) * (1/3.0) ).round
  end

  def pt_to_px(point, dpi)
    point / 72.0 * dpi
  end

  def interactive?
    @interactive
  end

  def interactive=(flag)
    @interactive = flag
    set_responsive(flag)
    invalidate
  end

  def set_responsive(responsive)
    if responsive
      width, height = size
      region = Gdk::Region.new(Gdk::Rectangle.new(0, 0, width, height))
    else
      region = Gdk::Region.new(Gdk::Rectangle.new(0, 0, 0, 0))
    end
    window.input_shape_combine_region(region, 0, 0)
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end

  def screen_changed
    colormap = self.screen.rgba_colormap
    if colormap
      # puts 'alpha channel supported'
      @alpha_supported = true
      self.colormap = colormap
    else
      STDERR.puts 'Warning: alpha channel NOT supported'
      @alpha_supported = false
      self.colormap = self.screen.rgb_colormap
    end
  end
end

end
