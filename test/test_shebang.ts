#!/usr/bin/env deno run
console.log("This is a test")
const numbers = [1,2,3,4]
console.log(numbers.filter(n => n % 2 === 0))
