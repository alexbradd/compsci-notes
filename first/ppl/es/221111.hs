inc :: (Functor f, Num a) => f a -> f a
inc = fmap (+1)

------------------------------------------------------------------
-- Implemment a new Applicative list where apply works like this:
-- [(+1),(*2)] <*> [1,2] => [2,4]
------------------------------------------------------------------
data ZipList a = ZCons a (ZipList a)
               | ZEmpty
  deriving Eq

instance (Show a) => Show (ZipList a) where
  show ZEmpty       = "[]"
  show (ZCons a as) = "[" ++ showInner a as ++ "]"
      where showInner a ZEmpty = show a
            showInner a (ZCons b bs) = show a ++ ", " ++ showInner b bs

instance Functor ZipList where
  fmap f ZEmpty       = ZEmpty
  fmap f (ZCons x xs) = ZCons (f x) (fmap f xs)

instance Foldable ZipList where
  foldr f z ZEmpty       = z
  foldr f z (ZCons x xs) = f x (foldr f z xs)

instance Applicative ZipList where
  pure a = ZCons a ZEmpty

  _  <*> ZEmpty = ZEmpty
  ZEmpty <*> _ = ZEmpty
  (ZCons f fs) <*> (ZCons x xs) = ZCons (f x) (fs <*> xs)

toZipList :: [a] -> ZipList a
toZipList = foldr ZCons ZEmpty

--------------------
-- Binary trees yee
--------------------
data BTree a = BEmpty
             | BNode a (BTree a) (BTree a)
bleaf a = BNode a BEmpty BEmpty

instance Functor BTree where
  fmap f BEmpty = BEmpty
  fmap f (BNode v l r) = BNode (f v) (fmap f l) (fmap f r)

instance Foldable BTree where
  foldr f z BEmpty = z
  foldr f z (BNode v l r) = f v (foldr f (foldr f z r) l)

-- Simple zip-like applicative
-- instance Applicative BTree where
--   pure = bleaf
--   _ <*> BEmpty = BEmpty
--   BEmpty <*> _ = BEmpty
--   (BNode f lf rf) <*> (BNode x lx rx) = BNode (f x) (lf <*> lx) (rf <*> rx)

(+-+) :: BTree a -> BTree a -> BTree a
BEmpty +-+ t2 = t2
t1 +-+ BEmpty = t1
(BNode v1 l1 r1) +-+ t = BNode v1 l1 (r1 +-+ t)

btconcat :: Foldable t => t (BTree a) -> BTree a
btconcat = foldr (+-+) BEmpty

btconcatMap :: (Functor t, Foldable t) => (a -> BTree b) -> t a -> BTree b
btconcatMap f = btconcat . fmap f
