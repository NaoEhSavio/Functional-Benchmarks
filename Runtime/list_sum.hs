import Data.Word
import System.Environment

data List a = Nil | Cons a (List a)

-- Sums a list
summ :: List Word64 -> Word64
summ Nil         = 0
summ (Cons x xs) = x + summ xs

-- A list from 0 to n
range :: Word64 -> List Word64 -> List Word64
range 0 xs = xs
range n xs =
  let m = n - 1
  in range m (Cons m xs)

-- Sums a big list with sum
main :: IO ()
main = do
  n <- read.head <$> getArgs :: IO Word64
  let size = n * 1000000
  let list = range size Nil
  print $ summ list
