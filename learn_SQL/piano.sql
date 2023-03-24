--Your Function
--The function you are going to write is not actually going to help you with your piano playing, but just explore one of the patterns you're 
--experiencing: Given the number you stopped on, was it on a black key or a white key? For example, in the description of your piano exercise above, 
--if you stopped at 5, your left thumb would be on the fifth key of the piano, which is black. Or if you stopped at 92, you would have gone all the way 
--from keys 1 to 88 and then wrapped around, so that you would be on the fourth key, which is white.

--Your function will receive an integer between 1 and 10000 (maybe you think that in principle it would be cool to count up to, say, a billion, 
--but considering how many years it would take it is just not possible) and return the string "black" or "white" -- here are a few more examples:
SELECT 
  n,
  CASE
    WHEN (n - 1) % 88 % 12 IN (0,2,3,5,7,8,10) THEN 'white' 
    ELSE 'black'
    END as res
FROM pianokeys