import Control.Monad.State
--------------
--- Stacks yee
--------------
type Stack = [Int]

pop :: Stack -> (Stack, Int)
pop [] = error "Empty" -- We could also use a Maybe
pop (x:xs) = (xs, x)

push :: Stack -> Int -> Stack
push xs i = i:xs

popM :: State Stack Int
popM = do
  stack <- get
  case stack of
    (x:xs) -> put xs >> return x
    [] -> error "Empty"

pushM :: Int -> State Stack ()
pushM x = do
  stack <- get
  put (x:stack)

