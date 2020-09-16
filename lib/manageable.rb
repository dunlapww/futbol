module Manageable

  def ratio(numerator, denominator, rounding = 2)
    (numerator.to_f / denominator).round(rounding)
  end

end
