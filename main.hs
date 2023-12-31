import Data.Array (array)
import Control.Concurrent (threadDelay)
import Control.Monad (forever)

main :: IO ()
main = do
    let grid = initializeGrid 7 50
    
    runGame grid

runGame :: [[Int]] -> IO ()
runGame grid = do
    let newGrid = tick grid

    putStr "\ESC[2J"
    putStrLn (gridToString grid)
    threadDelay 250000
    runGame newGrid


gridLineToString :: [Int] -> String
gridLineToString (x:xs) = c ++ gridLineToString xs
    where c = if x == 1 then "\ESC[48;5;255m \x1b[1;0m" else "\ESC[48;5;232m \x1b[1;0m"
    
gridLineToString [] = ""

gridToString :: [[Int]] -> String
gridToString (x:xs) = gridLineToString x ++ "\n" ++ gridToString xs
gridToString [] = ""

initializeGrid :: Int -> Int -> [[Int]]
initializeGrid x y = [
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
    [0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
    [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
    [0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

slice :: Int -> Int -> [a] -> [a]
slice from to xs 
    | from >= 0 && to <= length xs - 1 = take (to - from + 1) (drop from xs)
    | from < 0 = slice (from + 1) to xs
    | to > length xs - 1 = slice from (to - 1) xs

countNeighbors :: [[Int]] -> Int -> Int -> Int
countNeighbors grid x y = sum (map (sum . slice (y - 1) (y + 1)) [firstLine, secondLine, thirdLine]) - cellValue
    where 
        firstLine = if x >= 1 then grid !! (x - 1) else [] 
        secondLine = grid !! x
        gridLength = length grid
        thirdLine = if x < (length grid - 1) then grid !! (x + 1) else []
        cellValue = (grid !! x) !! y

mapInd :: (a -> Int -> b) -> [a] -> [b]
mapInd f l = zipWith f l [0..]

tick :: [[Int]] -> [[Int]]
tick xs = mapInd (\row x -> mapInd (\k y -> 
        let neighbors = countNeighbors xs x y in
            if k == 1 && neighbors < 2 then 0
            else if k == 1 && neighbors == 2 || neighbors == 3 then 1
            else if k == 1 && neighbors > 3 then 0
            else if k == 0 && neighbors == 3 then 1
            else k
        ) row) xs
    