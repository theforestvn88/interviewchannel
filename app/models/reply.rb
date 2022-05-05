class Reply < ApplicationRecord
  belongs_to :applying, touch: true
  belongs_to :user
end
