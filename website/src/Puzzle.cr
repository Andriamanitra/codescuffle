# placeholder until database gets sorted out
PUZZLE = %[{
  "title": "FizzBuzz",
  "statement": "Print numbers from 1 to N, but if the number is divisible by F, print \\"Fizz\\", and if the number is divisible by B print \\"Buzz\\". If it is divisible by both print \\"FizzBuzz\\".",
  "inputDescription": "Three numbers N, F and B separated by a single space",
  "outputDescription": "N lines",
  "tests": [
    { "input": "7 2 3", "output": "1\\nFizz\\nBuzz\\nFizz\\n5\\nFizzBuzz\\n7" },
    { "input": "3 1 1", "output": "FizzBuzz\\nFizzBuzz\\nFizzBuzz" },
    { "input": "10 11 12", "output": "1\\n2\\n3\\n4\\n5\\n6\\n7\\n8\\n9\\n10"}
  ]
}]

class Puzzle
  def self.random : String
    PUZZLE
  end
end
