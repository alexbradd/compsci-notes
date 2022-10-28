fact :: Integer -> Integer -- arbitrary size integer
fact 0 = 1
fact n = n * fact (n - 1)

revers :: [a] -> [a]
revers = foldl (flip (:)) []

-- foldLeft implemented scheme-style
foldLeft :: (a -> b -> b) -> b -> [a] -> b
foldLeft f z [] = z
foldLeft f z (x:xs) = foldLeft f (f x z) xs

data TrafficLight = Red | Yellow | Green
instance Show TrafficLight where
  show Red = "Red"
  show Yellow = "Yellow"
  show Green = "Green"
instance Eq TrafficLight where
  Red    == Red    = True
  Yellow == Yellow = True
  Green  == Green  = True
  _      == _      = False
