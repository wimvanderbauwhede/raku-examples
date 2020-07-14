{-# LANGUAGE RankNTypes #-}
module Main where

newtype MayBB b = MayBB {
    unMayBB :: forall a . 
    (b -> a) -- Just a
    -> a -- Nothing
    -> a
}

just x = \j' n' -> j' x
nothing = \j' n' -> n'

test :: Maybe Int -> String
test mb = case mb of
    Just n -> show n
    Nothing -> "NaN"
    

testBB :: MayBB Int -> String
testBB mb = (unMayBB mb) just nothing
    where
        just n = show n
        nothing = "NaN"
      
mb :: Maybe Int        
mb = Just 42
mbn :: Maybe Int
mbn = Nothing

mbb:: MayBB Int
mbb = MayBB $ just 42 -- \j n -> j 42

mbbn :: MayBB Int
mbbn = MayBB nothing -- $ \j n -> n

-- newtype BoolBB = BoolBB (forall a . a -> a -> a) 
newtype BoolBB = BoolBB {
    unBoolBB :: forall a . a -> a -> a
}

true = \t f -> t
false = \t f -> f

trueBB = BoolBB true
falseBB = BoolBB false

toBool :: BoolBB -> Bool
toBool (BoolBB tf) = tf True False

toBoolu :: BoolBB -> Bool
toBoolu b = (unBoolBB b) True False

newtype PairBB t1 t2 = PairBB {
    unPairBB :: forall a . (t1 -> t2 -> a) -> a
}

fstbb p = unPairBB p (\x y -> x)  
sndbb p = unPairBB p (\x y -> y)

bbp = PairBB $ \p -> p 42 "forty-two"

main =  do
    print $ testBB mbb
    print $ testBB mbbn
    print $ test mb
    print $ test mbn
    print $ fstbb bbp
    print $ toBool trueBB
    print $ toBoolu falseBB
