class Reply < ApplicationRecord
  belongs_to :applying
  belongs_to :user
end
