module GSuper

# 字幕ウィンドウを表わすクラス。
class SuperWindow < Gtk::Window
  BACKGROUND_COLOR = [0.0, 1.0, 0.0]
  BACKGROUND_ALPHA = 0.5

  attr_reader :font_name, :text_color, :shadow_color, :text

  def initialize
    super()

    @font_name = 'Sans 12'
    @text_color = [1.0, 0.5, 0.0, 1.0]
    @shadow_color = [0.0, 0.0, 1.0, 1.0]
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

    signal_connect('screen-changed') do 
      screen_changed
    end

    # self.decorated = false

    self.set_default_size(640,480)

    @alpha_supported = false
    screen_changed

    # GDK window を作る。
    realize

    window.override_redirect = true
    zero = Gdk::Region.new(Gdk::Rectangle.new(0, 0, 0, 0))
    window.input_shape_combine_region(zero, 0, 0)
  end

  def font_name=(font)
    @font_name = font
    invalidate
  end

  def text_color=(color)
    @text_color = color
    invalidate
  end

  def shadow_color=(color)
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
      cr.set_source_rgba(*BACKGROUND_COLOR, BACKGROUND_ALPHA)
    else
      cr.set_source_rgb(*BACKGROUND_COLOR)
    end

    cr.set_operator(Cairo::OPERATOR_SOURCE)
    cr.paint

    draw_text(cr)

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
    p [:draw_text, font_name]
    # cr.select_font_face(font_name,
    #                     Cairo::FONT_SLANT_NORMAL,
    #                     Cairo::FONT_WEIGHT_NORMAL)
    desc = Pango::FontDescription.new(font_name)
    layout = create_pango_layout
    # require 'pry'
    # binding.pry
    layout.width = size[0] * Pango::SCALE
    layout.font_description = desc
    layout.text = text
    offset = (desc.size.fdiv Pango::SCALE) * (3.fdiv 50)
    cr.move_to(offset, offset)
    cr.set_source_rgba(0.0, 0.0, 5.0, 1.0)
    cr.show_pango_layout(layout)

    cr.move_to(0, 0)
    cr.set_source_rgba(1.0, 0.5, 0.0, 1.0)
    cr.show_pango_layout(layout)
  end

  def interactive?
    @interactive
  end

  def interactive=(flag)
    @interactive = flag
    invalidate
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end

  def screen_changed
    colormap = self.screen.rgba_colormap
    if colormap
      puts 'alpha channel supported'
      @alpha_supported = true
      self.colormap = colormap
    else
      puts 'alpha channel NOT supported'
      @alpha_supported = false
      self.colormap = self.screen.rgb_colormap
    end
  end
end

end
