module CategoriesHelper

  def colour_for_availability(count, total_count)
    if count < 0
      '#AB0790'
    elsif count == 0
      '#ed3333'
    elsif count == total_count
      '#2edc1a'
    elsif count.to_f / total_count > 0.5
      '#b3ff0e'
    elsif count.to_f / total_count <= 0.1
      '#FFCA19'
    elsif count.to_f / total_count <= 0.5
      '#ffb01d'
    end
  end

end
