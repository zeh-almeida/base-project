
module ImageConcern
  extend ActiveSupport::Concern

  included do
    has_attached_file :image, default_url: ':style/missing.png',
                              path: ':class/:id/:style.:extension',
                              styles: { regular:  ['250x250#', :png],
                                        big:      ['500x500#', :png],
                                        medium:   ['300x300#', :png],
                                        small:    ['150x150#', :png],
                                        thumb:    ['50x50#',   :png] }

    validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }, size: { less_than: 2.megabytes }
  end
end
