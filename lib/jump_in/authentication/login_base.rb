module JumpIn
  module Authentication
    module LoginBase
      def jumpin_callback(klass, callback, method_to_be_called)
        jumpin_constant = callback.upcase
        unless klass.constants.include?(jumpin_constant)
          klass.const_set(jumpin_constant, [])
        end
        list = klass.const_get(jumpin_constant)
        list << method_to_be_called
      end
    end
  end
end


