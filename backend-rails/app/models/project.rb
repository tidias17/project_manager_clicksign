class Project < ApplicationRecord
  validates :name,       presence: true
  validates :client,     presence: true
  validates :start_date, presence: true
  validates :end_date,   presence: true
  validate  :end_date_after_start_date

  validates :name, format: {
    with:    /\A\S+(\s+\S+)+\z/,
    message: "deve conter ao menos 2 palavras"
  }, allow_blank: true

  def as_json(options = {})
    {
      id:         id,
      name:       name,
      client:     client,
      startDate:  start_date,
      endDate:    end_date,
      coverImage: cover_image,
      isFavorite: is_favorite,
      createdAt:  created_at,
      updatedAt:  updated_at
    }
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, "deve ser maior que a data inicial") if end_date <= start_date
  end
end
