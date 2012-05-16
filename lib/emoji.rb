require 'tmpdir'
require 'emoji_helper'

module Emoji
  PATH = File.expand_path("..", __FILE__)

  def self.path
    PATH
  end

  def self.names
    @names ||= Dir["#{PATH}/assets/images/emoji/*.png"].sort.map { |fn| File.basename(fn, '.png') }
  end

  def self.replace(string)
    string.gsub(/:([a-z0-9\+\-_]+):/) do |message|
      name = $1.to_s.downcase
      if names.include?(name)
        %(<span class="emoji emoji-#{name}" title=":#{name}:"></span>)
      else
        message
      end
    end
  end

  def self.generate_sprite
    Dir.mktmpdir('emoji') do |path|
      output = ::File.join(path, 'emoji.png')
      system "montage", "#{Emoji.path}/assets/images/emoji/*.png",
         "-background", "transparent",
         "-tile", "x#{Emoji.names.size}",
         "-geometry", "20x20",
         output
      File.read(output)
    end
  end

  if defined? Rails::Engine
    class Engine < Rails::Engine
      initializer 'emoji.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          helper EmojiHelper
        end
      end
    end

    def self.image_path(context, path)
      context.asset_path(path)
    end
  else
    def self.image_path(context, path)
      "/images/#{path}"
    end
  end
end
