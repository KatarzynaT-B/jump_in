module JumpIn
  module Generators
    class Configuration < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates JumpIn initializer for your application'

      def copy_initializer
        template 'jump_in_initializer.rb', 'config/initializers/jump_in.rb'
        puts 'Initializer generated. You can now customize JumpIn defaults in your config/initializers/jump_in.rb.'
      end
    end

    class LastLoggedIn < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates template for LastLoggedIn strategy'

      def copy_initializer
        template 'last_logged_in.rb', 'app/jumpin/last_logged_in.rb'
        puts 'Created JumpIn::LastLoggedIn template.'
      end
    end

    class LastLoggedOut < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates template for LastLoggedOut strategy'

      def copy_initializer
        template 'last_logged_out.rb', 'app/jumpin/last_logged_out.rb'
        puts 'Created JumpIn::LastLoggedOut template.'
      end
    end

    class LoginsCounter < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates template for LoginsCounter strategy'

      def copy_initializer
        template 'logins_counter.rb', 'app/jumpin/logins_counter.rb'
        puts 'Created JumpIn::LoginsCounter template.'
      end
    end

    class CustomStrategy < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)
      desc 'Creates template for custom strategies'

      def copy_initializer
        template 'custom_strategy.rb', 'app/jumpin/jumpin_custom_strategy.rb'
        puts 'Created JumpIn custom strategy template.'
      end
    end

  end
end
