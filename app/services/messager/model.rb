# frozen_string_literal: true

class Messager
    module Model
        def broadcast_replace(model)
            if model.respond_to?(:broadcast_replace_later_to)
                model.broadcast_replace_later_to model
            end

            self
        end
    end
end
