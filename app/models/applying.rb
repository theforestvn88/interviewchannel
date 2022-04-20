class Applying < ApplicationRecord
  belongs_to :message
  belongs_to :candidate
end
