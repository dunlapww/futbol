module Manageable

  def ratio(numerator, denominator, rounding = 2)
    return 0 if denominator == 0
    (numerator.to_f / denominator).round(rounding)
  end

end
