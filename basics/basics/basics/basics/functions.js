// Function declaration
function greet(name) {
  console.log(`Hello, ${name}!`);
}

greet("Hugh");

// Function with return value
function calculateArea(radius) {
  const PI = 3.14159;
  return PI * radius * radius;
}

let area = calculateArea(5);
console.log(`Area of circle: ${area}`);

// Function expression
const isEven = function (num) {
  return num % 2 === 0;
};

console.log("Is 4 even?", isEven(4));

// Arrow function
const square = (x) => x * x;
console.log("Square of 6:", square(6));

