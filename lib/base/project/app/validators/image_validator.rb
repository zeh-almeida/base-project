

class Base::Project::App::Validators::ImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.queued_for_write.blank? || value.queued_for_write[:original].blank?

    dimensions = Paperclip::Geometry.from_file(value.queued_for_write[:original].path)
    width = options[:width]
    height = options[:height]

    record.errors.add(attribute, I18n.t('activerecord.errors.image.width',  value: width)) if dimensions.width > width
    record.errors.add(attribute, I18n.t('activerecord.errors.image.height', value: height)) if dimensions.height > height
  end
end
