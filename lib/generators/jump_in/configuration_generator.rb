module JumpIn
  module Generators
    class Configuration < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates JumpIn initializer for your application'

      def copy_initializer
        template 'jump_in_configuration.rb', 'config/initializers/jump_in.rb'
        puts 'Initializer generated. You can now customize JumpIn defaults in your config/initializers/jump_in.rb.'
      end
    end
  end
end
