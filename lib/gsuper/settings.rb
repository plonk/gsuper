require "toml"

module GSuper

module Settings
  def default
    {
      "font" => "sans-serif",
      "super-x" => 0,
      "super-y" => 0,
      "super-width" => 640,
      "super-height" => 480,
      "text" => "",
      "text-color" => [1.0, 0.5, 0.0],
      "shadow-color" => [0.0, 0.0, 1.0],
    }
  end
  module_function :default

  def filepath
    ENV['HOME'] + '/.config/gsuper/settings.tml'
  end
  module_function :filepath

  def load
    begin
      user = TOML.load_file(filepath)
    rescue Errno::ENOENT
      # 設定ファイルが見付からないが、別に構わない
      user = {}
    rescue TOML::ParseError => e
      STDERR.puts "Error: corrupt settings file, ignoring"
      STDERR.puts e
      user = {}
    end
    return default.merge(user)
  end
  module_function :load

  def save(settings)
    difference = (settings.to_a - default.to_a).to_h
    toml = TOML.dump(difference)
    FileUtils.mkdir_p(File.dirname(filepath))
    File.open(filepath, "w") do |f|
      f.write(toml)
    end
  end
  module_function :save
end

end
