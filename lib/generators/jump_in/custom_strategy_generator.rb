module JumpIn::Generators
  class CustomStrategy < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)
    desc 'Creates template for custom strategies'

    def copy_initializer
      template 'custom_strategy.rb', 'lib/jump_in/jumpin_custom_strategy.rb'
      puts 'Created JumpIn custom strategy template.'
    end
  end
end
