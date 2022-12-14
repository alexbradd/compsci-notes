----------------------------------------
--- Logger moand from previous excercise
----------------------------------------
type Log = [String]
data Logger a = Logger { getContent :: a
                       , getLog :: Log }

instance (Eq a) => Eq (Logger a) where
  (Logger x _) == (Logger y _) = x == y
instance (Show a) => Show (Logger a) where
  show (Logger d l) =  show d ++ "\nLog:" ++ foldr (\line acc -> "\n\t" ++ line ++ acc) "" l

instance Functor Logger where
  fmap f (Logger d l) = Logger (f d) l
instance Applicative Logger where
  pure x = Logger x []
  (Logger f fl) <*> (Logger x xl) = Logger (f x) (fl ++ xl)
instance Monad Logger where
  (Logger x l) >>= f =
    let Logger x' l' = f x
    in Logger x' (l ++ l')

putLog :: String -> Logger ()
putLog s = Logger () [s]

------------------------------------------------------------
-- Binary tree implementation from previous exercise session
------------------------------------------------------------
data BTree a = BEmpty
             | BNode a (BTree a) (BTree a)
bleaf a = BNode a BEmpty BEmpty

instance Show a => Show (BTree a) where
  show BEmpty = ""
  show (BNode v x y) = "<" ++ show x ++ " " ++ show v ++ " " ++ show y ++ ">"

bleafM x = do
  putLog $ "Created leaf " ++ show x
  return $ bleaf x

treeReplaceM :: (Eq a, Show a) => BTree a -> a -> a -> Logger (BTree a)
treeReplaceM BEmpty _ _ = return BEmpty
treeReplaceM (BNode v l r) x y = do
  newl <- treeReplaceM l x y
  newr <- treeReplaceM r x y
  if v == x then do
    putLog $ "Replaced " ++ show x ++ " with " ++ show y
    return $ BNode y newl newr
  else do
    return $ BNode y newl newr

buildTree :: Int -> Logger (BTree Int)
buildTree 0 = bleafM 0
buildTree x = do
  putLog $ "Added node " ++ show x
  l <- buildTree (x `div` 2)
  r <- buildTree (x `div` 2)
  return $ BNode x l r

--------------
--- TDE 170227
--------------
data LolStream a = LolStream Int [a]

isPeriodic :: LolStream a -> Bool
isPeriodic (LolStream n _) = n > 0

destream :: LolStream a -> [a]
destream (LolStream n l) = if n <= 0 then l else take n l

instance (Show a) => Show (LolStream a) where
  show lol@(LolStream n l)
    | not(isPeriodic lol) = "LolStream[...]"
    | otherwise           = "LolStream(" ++ show n ++ ") " ++  show (destream lol)

instance (Eq a) => Eq (LolStream a) where
  l == k = destream l == destream k

lolRepeat :: [a] -> [a]
lolRepeat l = l ++ lolRepeat l

lol2lolstream :: [[a]] -> LolStream a
lol2lolstream ls = let l = concat ls
                   in LolStream (length l) (lolRepeat l)

instance Functor LolStream where
  fmap f (LolStream n l) = LolStream n (fmap f l)

instance Foldable LolStream where
--  foldr f z (LolStream _ l) = foldr f z l
--  Variante pradella
  foldr f z ls = foldr f z (destream ls)

instance Applicative LolStream where
  pure x = lol2lolstream [[x]]
  -- fs <*> xs = let fs' = destream fs
  --                 xs' = destream xs
  --             in lol2lolstream [fs' <*> xs']
  f@(LolStream n fs) <*> x@(LolStream m xs) = if (n > 0) && (m > 0) then
      LolStream (n*m) (lolRepeat (destream f <*> destream x))
      else LolStream (-1) (fs <*> xs)

instance Monad LolStream where
  ls >>= fs = lol2lolstream [destream ls >>= (\x -> destream (fs x))]
