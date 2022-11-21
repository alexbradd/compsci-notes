data Listtree a = Null
                | Cons a (Listtree a)
                | Branch (Listtree a) (Listtree a)
    deriving (Show, Eq)

leaf a = Cons a Null

instance Functor Listtree where
  fmap f Null =  Null
  fmap f (Cons x t) = Cons (f x) (fmap f t)
  fmap f (Branch l r) = Branch (fmap f l) (fmap f r)

instance Foldable Listtree where
  foldr f z Null = z
  foldr f z (Cons x t) = f x (foldr f z t)
  foldr f z (Branch l r) = foldr f (foldr f z r) l

x <++> Null = x
Null <++> x = x
(Cons v t) <++> y = Cons v (t <++> y)
x <++> y = Branch x y

ltconcat :: Foldable t => t (Listtree a) -> Listtree a
ltconcat = foldr (<++>) Null

ltconcatMap :: (Functor t, Foldable t) => (a -> Listtree b) -> t a -> Listtree b
ltconcatMap f t = ltconcat $ fmap f t

instance Applicative Listtree where
  pure = leaf
  fs <*> xs = ltconcatMap (\f -> fmap f xs) fs

---

type Log = [String]
data Logger a = Logger { getContent :: a
                       , getLog :: Log }

instance (Eq a) => Eq (Logger a) where
  (Logger x _) == (Logger y _) = x == y
instance (Show a) => Show (Logger a) where
  show (Logger d l) =  show d ++ "\nLog:\n" ++ foldr (\line acc -> "\n\t" ++ line ++ acc) "" l

instance Functor Logger where
  fmap f (Logger d l) = Logger (f d) l
instance Applicative Logger where
  pure x = Logger x []
  (Logger f fl) <*> (Logger x xl) = Logger (f x) (fl ++ xl)
instance Monad Logger where
  (Logger x l) >>= f =
    let Logger x' l' = f x
    in Logger x' (l ++ l')


