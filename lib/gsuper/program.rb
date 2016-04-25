require 'gtk2'
require 'gsuper/settings'

=begin

+-------------------------------------------------+--------+
| gsuper                                          | _ [] X |
+-------------------------------------------------+--------+
| x: [  320]  y: [ 480]                                    |
| [font button] [color button] [color button] [X] outline  |
| +------------------------------------------------------+ |
| | blah blah blah blah blah...                          | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| |                                                      | |
| +------------------------------------------------------+ |
|                                               [   OK   ] |
+----------------------------------------------------------+

=end

require_relative 'color'

module GSuper

TEXT = <<EOT
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.
EOT

class Program
  include Gtk

  def create_popup_menu
    menu = Menu.new
    [MenuItem.new('終了').tap { |item|
       item.signal_connect('activate') {
         Gtk.main_quit
       }
     }].each do |item|
      menu.add(item)
    end
    menu.show_all
    return menu
  end

  def create_main_window(super_window)
    return Window.new.tap { |window|
      window.signal_connect("delete-event") {
        window.hide
        true
      }

      window.border_width = 18

      VBox.new(false, 18).tap { |vbox|
        HBox.new(false, 12).tap { |hbox|
          font_button = FontButton.new.tap { |font_button|
            font_button.font_name = @settings['font']
          }
          font_button.signal_connect('font-set') {
            @settings['font'] = super_window.font_name = font_button.font_name
          }
          color_hbox = HBox.new(true, 0).tap { |color_hbox|
            color_button1 = ColorButton.new.tap { |b|
              b.color = super_window.text_color
              b.signal_connect('color-set') {
                super_window.text_color = b.color
                @settings['text-color'] = Color::pango_triple(b.color)
              }
            }
            color_button2 = ColorButton.new.tap { |b|
              b.color = super_window.shadow_color
              b.signal_connect('color-set') {
                super_window.shadow_color = b.color
                @settings['shadow-color'] = Color::pango_triple(b.color)
              }
            }
            color_hbox.pack_start(color_button1, false)
            color_hbox.pack_start(color_button2, false)
          }

          toggle_button = ToggleButton.new("字幕操作")
          toggle_button.active = super_window.interactive?
          toggle_button.modify_bg(Gtk::STATE_ACTIVE, Color::gdk_color([0, 1.0, 0]))
          toggle_button.signal_connect('toggled') {
            toggle_button.active =
              super_window.interactive = !super_window.interactive?
          }

          hbox.pack_start(font_button, false)
          hbox.pack_start(color_hbox, false)
          hbox.pack_start(toggle_button, false)
          
          vbox.pack_start(hbox, false)
        }
        
        text_view = TextView.new
        text_view.wrap_mode = TextTag::WRAP_WORD_CHAR
        text_view.buffer.signal_connect('changed') {
          @settings['text'] = super_window.text = text_view.buffer.text
        }
        ScrolledWindow.new.tap { |sw|
          sw.hscrollbar_policy = POLICY_AUTOMATIC
          sw.vscrollbar_policy = POLICY_AUTOMATIC
          text_view.buffer.text = settings['text']

          sw.add(text_view)
          vbox.pack_start(sw)
        }

        window.add(vbox)
      }
    }
  end

  def create_status_icon(popup_menu, super_window, main_window)
    status_icon = StatusIcon.new
    status_icon.title = "gsuper"
    status_icon.tooltip = "gsuper"
    status_icon.pixbuf = Gdk::Pixbuf.new(File.dirname(__FILE__) + '/images/icon.png')
    status_icon.signal_connect("activate") {|s|
      main_window.present
      p [:activate, @present]
    }
    status_icon.signal_connect('popup-menu') do  |widget, button, time|
      p [:"popup-menu", widget, button, time]
      popup_menu.popup(nil, nil, button, time)
    end
    status_icon.signal_connect('scroll-event') do |widget, event|
      p [:"scroll-event", widget, event]
    end
    return status_icon
  end

  def run
    @present = true
    @settings = Settings.load

    at_exit {
      STDERR.puts "saving settings"
      Settings.save(@settings)
    }

    @super_window = SuperWindow.new
    @super_window.text = @settings['text']
    @super_window.font_name = @settings['font']
    @super_window.text_color = Color::gdk_color @settings['text-color']
    @super_window.shadow_color = Color::gdk_color @settings['shadow-color']
    @super_window.show

    @window = create_main_window(@super_window)
    menu = create_popup_menu
    @status_icon = create_status_icon(menu, @super_window, @window)
    
    @window.show_all

    Gtk.main
  end

end

end

if __FILE__ == $0
  GSuper::Program.new.run
end

