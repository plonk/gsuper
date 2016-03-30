require 'gtk2'


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
    [MenuItem.new('Item 1'),
     MenuItem.new('Item 2'),
     MenuItem.new('終了').tap { |item|
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
      window.signal_connect("destroy") {
        Gtk.main_quit
      }

      window.border_width = 5

      VBox.new.tap { |vbox|
        HBox.new.tap { |hbox|
          font_button = FontButton.new.tap { |font_button|
            font_button.font_name = super_window.font_name
          }
          font_button.signal_connect('font-set') {
            super_window.font_name = font_button.font_name
          }
          color_button1 = ColorButton.new.tap { |b|
            b.use_alpha = true
            b.color = Color::gdk_color(super_window.text_color)
            b.alpha = Color::gdk_alpha(super_window.text_color)
          }
          color_button2 = ColorButton.new.tap { |b|
            b.use_alpha = true
            b.color = Color::gdk_color(super_window.shadow_color)
            b.alpha = Color::gdk_alpha(super_window.shadow_color)
          }

          hbox.pack_start(font_button, false)
          hbox.pack_start(color_button1, false)
          hbox.pack_start(color_button2, false)
          
          vbox.pack_start(hbox, false)
        }
        
        text_view = TextView.new
        super_window.text = text_view.buffer.text = TEXT

        vbox.pack_start(text_view)
        apply_button = Button.new('適用')
        apply_button.signal_connect('clicked') {
          super_window.text = text_view.buffer.text
        }
        vbox.pack_start(apply_button , false)

        window.add(vbox)
      }
    }
  end

  def create_status_icon(popup_menu, super_window)
    status_icon = StatusIcon.new
    status_icon.title = "gsuper"
    status_icon.tooltip = "gsuper"
    status_icon.pixbuf = Gdk::Pixbuf.new(File.dirname(__FILE__) + '/images/icon.png')
    status_icon.signal_connect("activate") {|s|
      super_window.interactive = !super_window.interactive?
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

    @super_window = SuperWindow.new
    @super_window.show
    @window = create_main_window(@super_window)
    menu = create_popup_menu
    @status_icon = create_status_icon(menu, @super_window)
    
    @window.show_all

    Gtk.main
  end

end

end

if __FILE__ == $0
  GSuper::Program.new.run
end

