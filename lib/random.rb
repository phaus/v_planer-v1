module Random
  def randomise(size)
    str = ''
    0.upto(size) do
      pool = (('a'..'z').to_a | ('A'..'Z').to_a | ('0'..'9').to_a).shuffle
      str << pool[rand(pool.size-1)]
    end
    str
  end
end
