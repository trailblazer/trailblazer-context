module Trailblazer
  class Context
    class IndifferentAccess < Context
      def [](name)
        super(name.to_sym)
      end

      def []=(name, value)
        super(name.to_sym, value)
      end
    end
  end
end
